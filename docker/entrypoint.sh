#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

if [ ! -f .env ]; then
    cp .env.example .env
fi

php artisan key:generate --force || true
php artisan storage:link || true

if [ ! -d vendor ]; then
    composer install --no-interaction --prefer-dist --no-progress
fi

if [ ! -d node_modules ]; then
    npm install
fi

if [ ! -f database/database.sqlite ]; then
    touch database/database.sqlite
fi

php artisan migrate --force || true
php artisan db:seed --force --class=Database\\Seeders\\AuthTableSeeder || true
exec php artisan serve --host=0.0.0.0 --port=8000
