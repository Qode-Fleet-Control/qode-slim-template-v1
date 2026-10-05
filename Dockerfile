# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# Slim 4 skeleton on FrankenPHP (a Caddy-based PHP app server): docroot public/,
# served on 0.0.0.0:$PORT with the PORT read from the environment when the
# container STARTS.
FROM dunglas/frankenphp:1-php8.4-bookworm AS runtime
RUN install-php-extensions zip
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction
COPY . .
RUN composer dump-autoload --optimize --no-dev --no-interaction \
 && useradd -r -u 10001 -d /app app \
 && mkdir -p var/cache logs && chown -R app:app var logs /config/caddy /data/caddy
ARG BUILD_ID=""
# docker=true: the skeleton's app/settings.php then logs to stdout, not logs/app.log.
ENV PORT=8080 SERVER_ROOT=/app/public docker=true BUILD_ID=$BUILD_ID
USER app
EXPOSE 8080
CMD ["sh", "-c", "SERVER_NAME=\":${PORT}\" exec frankenphp run --config /etc/frankenphp/Caddyfile"]
