FROM php:7.4-fpm-alpine

# Requirements from https://flarum.org/docs/install.html#server-requirements
# are almost satisfied by php:7.4-fpm-alpine that satisfies the following deps:
# 
# ☑ curl
# ☐ dom
# ☐ gd
# ☐ json
# ☑ mbstring
# ☑ openssl
# ☐ pdo_mysql
# ☐ tokenizer
# ☑ zip
# 
# Reference for docker-php-ext-install
# https://gist.github.com/giansalex/2776a4206666d940d014792ab4700d80


RUN apk add libjpeg-turbo-dev libpng-dev freetype-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ \
                                --with-jpeg-dir=/usr/include/ &&\
    docker-php-ext-install -j$(nproc) \
                           dom \
			   gd \
			   json \
			   pdo_mysql \
			   tokenizer
