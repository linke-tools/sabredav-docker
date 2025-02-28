<?php

// Load configuration
$config = json_decode(file_get_contents(__DIR__ . '/config.json'), true);

if ($config === null) {
    die('Error loading configuration file');
}

// Set timezone from config
date_default_timezone_set($config['timezone']);

// Database connection using config
try {
    $pdo = new PDO(
        "mysql:host={$config['database']['host']};dbname={$config['database']['dbname']}",
        $config['database']['username'],
        $config['database']['password'],
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]
    );
} catch (PDOException $e) {
    die('Connection failed: ' . $e->getMessage());
}

// Files we need
require_once 'vendor/autoload.php';

// Backends
$authBackend = new Sabre\DAV\Auth\Backend\BasicCallBack(function($username, $password) {return true;});

$calendarBackend = new Sabre\CalDAV\Backend\PDO($pdo);
$principalBackend = new Sabre\DAVACL\PrincipalBackend\PDO($pdo);

// Directory structure
$tree = [
    new Sabre\CalDAV\Principal\Collection($principalBackend),
    new Sabre\CalDAV\CalendarRoot($principalBackend, $calendarBackend),
];

$server = new Sabre\DAV\Server($tree);

if (isset($baseUri)) {
    $server->setBaseUri($baseUri);
}

/* Server Plugins */
$authPlugin = new Sabre\DAV\Auth\Plugin($authBackend);
$server->addPlugin($authPlugin);

$aclPlugin = new Sabre\DAVACL\Plugin();
$server->addPlugin($aclPlugin);

/* CalDAV support */
$caldavPlugin = new Sabre\CalDAV\Plugin();
$server->addPlugin($caldavPlugin);

/* Calendar subscription support */
$server->addPlugin(
    new Sabre\CalDAV\Subscriptions\Plugin()
);

/* WebDAV-Sync plugin */
$server->addPlugin(new Sabre\DAV\Sync\Plugin());

// Support for html frontend
$browser = new Sabre\DAV\Browser\Plugin();
$server->addPlugin($browser);


$icsPlugin = new \Sabre\CalDAV\ICSExportPlugin();
$server->addPlugin($icsPlugin);

$server->start();
