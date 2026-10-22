# Docker version usage

## Image build

### With proxy between server and internet

```
proxy_url=http://yourproxy.url.org:port docker compose up --build
```

### Without proxy

- open Dockerfile and comment the following lines:

```
ARG proxy_url
ENV HTTP_PROXY=${proxy_url}
ENV HTTPS_PROXY=${proxy_url}
ENV NO_PROXY=localhost,127.0.0.1,.protezionecivile.fvg.it
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}
```

run the build with the command

```
proxy_url=http://yourproxy.url.org:port docker compose up --build
```

Leave the console (and the containers) running after the command

## App prepare

1. connect to the running container with:

```
docker exec -it pia-back-web-1 bash
```

2. Run the rake task for creating client secrets and admin user:

```
RAILS_ENV=production rake prepare:app[admin]
```

You can change the admin username with whaterver you need (i.e. : me@myorg.com)

## Start backend

Stop the console-running containers (Ctrl-C) and re-run them in daemon mode

```
docker compose up -d
```
