# alpine-nginx-php

1. Create a `docker-compose.yml`:

```yaml
version: '2'
  services:
    db:
      image: mariadb:latest
      volumes:
        - ./.data/db:/var/lib/mysql
      restart: always
      env_file: .env

    web:
      image: jalenconner/alpine-nginx-php:latest
      depends_on:
        - db
      links:
        - db
      ports:
        - 80:80
      env_file: .env
      volumes:
        - ./log:/var/log
        - ./log/craft:/app/craft/storage/runtime/logs
        - :/app/craft/config

```

2. Run `$ mkdir -P log/nginx log/php7 log/craft` in your project directory to create folders for your logs files

3. Make sure you config, templates, and plugins are mounted in the correct folder

4. build `$ docker-compose build` and run `$ docker-compose up` the container
