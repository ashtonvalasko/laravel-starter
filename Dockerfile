FROM php:8.4-cli

ARG WWWGROUP=1000
ARG WWWUSER=1000
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        zip \
        libicu-dev \
        libonig-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libxml2-dev \
        libzip-dev \
        libsqlite3-dev \
        default-mysql-client \
        sqlite3 \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql pdo_sqlite bcmath gd intl zip exif pcntl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN groupadd --gid "$WWWGROUP" www-data || true \
    && useradd --uid "$WWWUSER" --gid "$WWWGROUP" --create-home --shell /bin/bash laravel || true

USER root

WORKDIR /var/www/html

COPY . .

RUN composer install --no-interaction --prefer-dist --no-progress \
    && npm install

RUN chown -R "$WWWUSER":"$WWWGROUP" /var/www/html \
    && chmod +x /var/www/html/docker/entrypoint.sh

USER www-data

EXPOSE 8000 5173

CMD ["/var/www/html/docker/entrypoint.sh"]
