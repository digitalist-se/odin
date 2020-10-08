FROM php:7.3-fpm

COPY . /usr/src/app/
WORKDIR /usr/src/app
ENV DOCKERIZE_VERSION 0.6.1

# Install dockerize, maybe use it later on.
RUN curl -s -f -L -o /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/v$DOCKERIZE_VERSION/dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz \
    && rm /tmp/dockerize.tar.gz

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        vim \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        libzip-dev \
        unzip \
        zip \
        nodejs \
        zlib1g-dev \ 
        libicu-dev \
        g++ \
    && docker-php-ext-configure gd \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
        gd \
        exif \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        pcntl \
        zip \
        intl 
RUN apt-get update && apt-get install -y nodejs gconf-service libasound2 libatk1.0-0 libc6 libcairo2 \
	libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 \
	libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 \
	libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 \
	libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates \
	fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget \
	&& npm install --global --unsafe-perm puppeteer \
	&& chmod -R o+rx /usr/lib/node_modules/puppeteer/.local-chromium \
        && rm -rf /var/lib/apt/lists/*;
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install

RUN chown -R www-data:www-data /usr/src/app/ \
	&& npm install
COPY .docker/laravel.ini /usr/local/etc/php/conf.d/laravel.ini
