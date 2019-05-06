FROM alpine:3.9

ARG APP_USER=satisfy

ENV \
    COMPOSER_VERSION=1.8.5 \
    SATISFY_VERSION=3.1 \
    LD_PRELOAD=/usr/lib/preloadable_libiconv.so \
    PHP_INI_PATH=/etc/php7/php.ini \
    PHP_INI_SCAN_DIR=/etc/php7/conf.d \
    APP_ROOT=/app \
    APP_USER=${APP_USER}

LABEL \
      maintainer="Anastas Dancha <https://github.com/anapsix>" \
      com.php.composer.version="${COMPOSER_VERSION}" \
      playbloom.satisfy.version="${SATISFY_VERSION}"

RUN \
    apk upgrade --no-cache && \
    apk add --no-cache php7-apcu php7-bcmath php7-ctype php7-curl php7-dom php7-fileinfo \
      php7-iconv php7-json php7-mbstring php7-openssl php7-phar php7-session \
      php7-simplexml php7-xml php7-xmlwriter php7-tokenizer php7-opcache \
      nginx unit-php7 \
      procmail libxml2-dev inotify-tools jq zip curl openssh-client git unzip && \
    apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv && \
    apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gosu && \
    curl -o /usr/local/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && \
    chmod +x /usr/local/bin/composer && \
    rm -rf /var/cache/apk/* && \
    if [[ "$APP_USER" != "root" ]]; then adduser -h ${APP_ROOT} -D -H ${APP_USER}; fi

USER satisfy

WORKDIR ${APP_ROOT}

RUN \
    yes | composer create-project --no-dev playbloom/satisfy . ${SATISFY_VERSION} && \
    rm ${APP_ROOT}/app/config/parameters.yml && \
    echo "HTTP server is up" > ${APP_ROOT}/web/serverup.txt && \
    chown -R ${APP_USER}:${APP_USER} ${APP_ROOT}

EXPOSE 80


RUN composer global require hirak/prestissimo --prefer-dist --no-interaction \
    && composer require ramunasd/symfony-container-mocks --no-scripts --no-interaction

#RUN cat /app/app/config/parameters.yml
#RUN echo "    github.secret: ~" >> /app/app/config/parameters.yml

USER root

COPY config/parameters.yml /app/app/config/
COPY config/php.ini /etc/php7/conf.d/99_user.ini

COPY script/*.sh /
COPY config/unit.json /var/lib/unit/conf.json
COPY config/nginx.conf /etc/nginx/nginx.conf


ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "satisfy" ]

VOLUME "/app/.composer"
VOLUME "/app/.ssh"
VOLUME "/app/web"
