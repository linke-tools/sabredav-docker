FROM debian:latest

RUN apt-get update && apt-get -y install ca-certificates curl git wget unzip mariadb-client gettext

RUN curl --proto '=https' --tlsv1.2 -sSf  https://packages.sury.org/php/README.txt | bash && apt-get -y install php8.4 php8.4-fpm php8.4-common php-date php8.4-mbstring php8.4-xml php8.4-sqlite3 php8.4-curl php8.4-imap libxml2 php8.4-zip php8.4-mysql

COPY files/php-fpm.conf /etc/php/8.4/fpm/pool.d/www.conf

RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/f3108f64b4e1c1ce6eb462b159956461592b3e3e/web/installer -O - -q | php -- --quiet && mv composer.phar /usr/local/bin/composer

RUN useradd -d /sabredav -k /dev/null -m -s /bin/bash sabredav

USER sabredav

WORKDIR /sabredav

RUN composer require sabre/dav ~4.6.0

RUN git clone https://github.com/sabre-io/dav.git

USER root
COPY files/calendarserver.php .
RUN chown sabredav: calendarserver.php

COPY files/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9000
CMD ["/usr/sbin/php-fpm8.4","--nodaemonize","--fpm-config","/etc/php/8.4/fpm/php-fpm.conf"]

