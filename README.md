# Slim template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with the
official Slim 4 skeleton laid on top, served by FrankenPHP.

## Origin

    docker run --rm -u $(id -u):$(id -g) -v "$PWD":/w -w /w <php8.4 + composer:2 image> \
      composer create-project slim/slim-skeleton qode-slim-template-v1 --prefer-dist --no-interaction

Generated 2026-10-05 (slim/slim-skeleton, Slim 4 + PHP-DI + Monolog, PHP 8.4.26 — the PHP
the image runs). `vendor/` was removed; `composer.lock` is kept.

## Run it

**On the fleet** — nothing to do: `bin/run` (docker runtime) does `docker compose build`
then `docker compose up --remove-orphans` in the foreground. The app listens on
`0.0.0.0:$PORT`; `HEALTH_PATH=/health`; `/` says `Hello world!`; `/users` and
`/users/{id}` are the skeleton's sample actions.

**With docker**

    PORT=8080 bin/run              # or: docker compose up --build
    curl localhost:8080/health

**Without docker** (PHP 8.x, composer):

    FLEET_RUNTIME=process PORT=8080 bin/run
    # = composer install; php -S 0.0.0.0:$PORT -t public  (the skeleton's `composer start`)

| step | process runtime | docker runtime |
|---|---|---|
| install | `composer install --no-interaction` | — |
| build | — | `docker compose build` |
| start | `php -S 0.0.0.0:$PORT -t public` | `docker compose up --remove-orphans` |

## How the container works

- `Dockerfile`: `dunglas/frankenphp:1-php8.4-bookworm`, `composer install --no-dev`,
  non-root user `app` owning `var/` (PHP-DI's compiled container) and `logs/`.
  `docker=true` makes the skeleton's `app/settings.php` log to stdout.
- The command serves with FrankenPHP's stock Caddyfile on `SERVER_NAME=":$PORT"` (plain
  HTTP on the `$PORT` read when the container starts), document root `public/`.

## Deviations from the stock generator output, and why

- `app/routes.php`: a `/health` route returning `{"status":"ok"}` — the fleet's health check.
- The skeleton's `docker-compose.yml` (php:7-alpine, fixed `8080:8080`, bind mount) was
  removed: `compose.yaml` replaces it, and compose would otherwise see two files.
- The skeleton's own `.github/workflows/tests.yml` and `dependabot.yml` are kept; the
  fleet's `deploy.yml` and `manual-deploy.yml` were added beside them.
- Added `Dockerfile`, `compose.yaml`, `.dockerignore`, `fleet.conf`, `bin/`,
  `docs/fleet-lifecycle.md`; `.gitignore` gained `.fleet/`, `.fleet-deploy.log`, `*.log`.

## Verified

**Not verified yet.** The `docker compose build` / `verify.sh` run was never reached: on
2026-10-05 the shared docker host's disk sat at 0-2 GB free (98 GB volume at 99-100%)
for more than three hours, below the 6 GB gate builds wait for. Before trusting this
template, run `verify.sh <dir> <port>` (run, restart and stop must all pass).

What *was* checked: `migrate.py audit` → READY; `php -l` on every PHP file this template
added or changed, and `sh -n` on its shell scripts → clean.

See `docs/fleet-lifecycle.md` for the lifecycle scripts.
