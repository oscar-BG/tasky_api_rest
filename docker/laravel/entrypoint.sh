#!/bin/sh

set -e

echo "Esperando conexión con la base de datos..."

until php artisan db:show > /dev/null 2>&1
do
    echo "Base de datos todavía no disponible..."
    sleep 2
done

echo "Base de datos disponible."

php artisan migrate --force

exec php artisan serve --host=0.0.0.0 --port=8000