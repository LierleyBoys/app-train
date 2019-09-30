FROM php:7.2
RUN apt-get update -y && apt-get install -y openssl zip unzip git libxml2-dev supervisor htop
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN docker-php-ext-install pdo pdo_mysql mbstring soap
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini


COPY . /usr/src/app-trains
WORKDIR /usr/src/app-trains

RUN composer install

RUN mkdir -p /var/log/supervisor
COPY ./config/app.conf /etc/supervisor/cong.d/
RUN supervisord -c /etc/supervisor/supervisord.conf && \
    supervisorctl reread && \
    supervisorctl update && \
    supervisorctl start app

# CMD [ "php", "./hello-world.php" ]
CMD php -S 0.0.0.0:80 -t public & supervisord -n -c /etc/supervisor/supervisord.conf
EXPOSE 80