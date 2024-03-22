[root@devops lesson6.docker-compose]# cat docker-compose.yml

version: '3'

services:
  # service1 lesson6 docker-compose веб-сервер HTTPD 2.4
  webserver:
    image: docker.io/library/httpd:2.4-alpine
    depends_on:
      - postgres
    environment:
      - TZ=Europe/Minsk
    restart: always
    ports:
      - "85:80"
      - "443:443"
    volumes:
      - ./web-content:/usr/local/apache2/htdocs
      - ./web-config:/usr/local/apache2/conf
      - ./web-logs:/usr/local/apache2/logs
    networks:
      - docker-compose
    configs:
      - httpd_config
      - admin_config
      - admin_vhost

  # service2 lesson6 docker-compose СУБД-сервер PostgreSQL 16.2
  postgres:
    image: docker.io/postgres:16.2-alpine3.19
    environment:
      - TZ=Europe/Minsk
    restart: always
    environment:
      POSTGRES_DB: docker-compose
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - ./postgres-data:/var/lib/postgresql/data
      - ./postgres-config:/var/lib/postgresql/data/conf
    networks:
      - docker-compose

networks:
  docker-compose:
    driver: bridge

configs:
  httpd_config:
    file: ./httpd.conf
  admin_config:
    file: ./admin.conf
  admin_vhost:
    file: ./admin-vhost.conf
volumes:
  postgres-data:
  web-content:
  web-config:
  web-logs:
  postgres-config:
  
[root@devops lesson6.docker-compose]# docker-compose --project-name net up -d
[+] Running 2/2
 ⠿ Container net-postgres-1   Started                                                                                                                                           0.7s
 ⠿ Container net-webserver-1  Started     
 
[root@devops lesson6.docker-compose]# docker ps -a
CONTAINER ID   IMAGE                      COMMAND                  CREATED          STATUS          PORTS                                                                      NAMES
9c986f1f11de   httpd:2.4-alpine           "httpd-foreground"       23 seconds ago   Up 20 seconds   0.0.0.0:443->443/tcp, :::443->443/tcp, 0.0.0.0:85->80/tcp, :::85->80/tcp   net-webserver-1
84703c5c94a8   postgres:16.2-alpine3.19   "docker-entrypoint.s…"   23 seconds ago   Up 21 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp                                  net-postgres-1
cc6322ed5278   wtf_httpd_docker:latest    "httpd -D FOREGROUND…"   11 minutes ago   Up 10 minutes   0.0.0.0:90->80/tcp, :::90->80/tcp, 0.0.0.0:444->443/tcp, :::444->443/tcp   my_httpd_container

[root@devops lesson6.docker-compose]# curl https://devops.nces.by
<!DOCTYPE html>
<html>
<head>
    <title>It's work I am Docker in Docker-compose</title>
</head>
<body>
    <h1>It's work I am Docker-compose</h1>
    <p>This is a simple Docker Apache HTTP Server.</p>
</body>
</html>
