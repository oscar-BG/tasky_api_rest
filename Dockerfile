FROM php:8.3.33-fpm as dependencies

RUN apt-get update && apt-get install -y \
    unzip

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

WORKDIR /usr/src/app
COPY composer.json .
COPY composer.lock .
RUN composer install --no-scripts

FROM node:24-alpine3.23 as frontend
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY resources ./resources
COPY public ./public
COPY vite.config.js ./
RUN npm run build


FROM php:8.3.33-fpm as production

WORKDIR /usr/src/app
COPY . .
COPY --from=dependencies /usr/src/app/vendor ./vendor
COPY --from=frontend /app/public/build ./public/build

RUN apt-get update && apt-get install -y \
    unzip

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN composer run dev