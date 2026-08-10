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
WORKDIR /usr/src/app
COPY package.json .
COPY package-lock.json .
RUN npm install && npm run build

FROM php:8.3.33-fpm as runner
WORKDIR /usr/src/app
COPY . .
COPY --from=dependencies /usr/src/app /usr/src/app
COPY --from=frontend /usr/src/app/build /usr/src/app/public/build
RUN composer run dev