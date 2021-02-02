FROM php:8-fpm

RUN apt-get update && apt-get install -y \
    cron \
    git \
    libmcrypt-dev \
    nano \
    libpq-dev \
    htop \
    postgresql-client

# composer install
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install php extentions
RUN docker-php-ext-install pdo_pgsql \
 && docker-php-ext-install pgsql \
 && docker-php-ext-install pcntl \
 && pecl install xdebug \
 && docker-php-ext-enable xdebug

# symlink for php73 command
#RUN ln -s /usr/local/bin/php /usr/local/bin/php8

# restart php-fpm
RUN kill -USR2 1

COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

WORKDIR /var/www

EXPOSE 9000
