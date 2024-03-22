# Docker multi-stage
# Build stage
FROM golang:alpine AS build
WORKDIR /go/src/app

COPY web.go .
RUN go env -w GO111MODULE=auto
RUN go build -o go_webserver .

# Final stage
FROM alpine
WORKDIR /app

# Copy only the built binary from the previous stage
COPY --from=build /go/src/app/go_webserver .

CMD ["./go_webserver"]

# webapp on Golang

package main

import (
        "fmt"
        "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
        fmt.Fprint(w, "I am go_webserver and I am work!")
}

func main() {
        http.HandleFunc("/", handler)

        port := ":9090"

        fmt.Printf("Server is listening on %s...\n", port)
        err := http.ListenAndServe(port, nil)
        if err != nil {
                fmt.Println("Error:", err)
        }
}

# run Docker build and check
docker run -p 9090:9090 -d go_webserver
[root@devops lesson8.db]# curl http://172.16.0.131:9090
I am go_webserver and I am work!


# docker-compose all db install

[root@devops lesson8.db]# cat docker-compose.yml
version: '3.9'

services:

  postgres:
    image: postgres
    restart: always
    # set shared memory limit when using docker-compose
    shm_size: 128mb
    # or set shared memory limit when deploy via swarm stack
    #volumes:
    #  - type: tmpfs
    #    target: /dev/shm
    #    tmpfs:
    #      size: 134217728 # 128*2^20 bytes = 128Mb
    environment:
      POSTGRES_PASSWORD: example
      POSTGRES_USER: example
      POSTGRES_DB: example
      DATABASE_HOST: 127.0.0.1
    volumes:
      - ./docker_postgres_init.sql:/docker-entrypoint-initdb.d/docker_postgres_init.sql
    ports:
      - 5556:5432

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: "skruh@nces.by"
      PGADMIN_DEFAULT_PASSWORD: "cef"
    restart: always
    ports:
      - 5555:80

  mongo:
    image: mongo
    restart: always
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    ports:
     - 27017:27017
  mongo-express:
    image: mongo-express
    restart: always
    ports:
      - 4444:8081
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: root
      ME_CONFIG_MONGODB_ADMINPASSWORD: example
      ME_CONFIG_BASICAUTH_USERNAME: root
      ME_CONFIG_BASICAUTH_PASSWORD: example
      ME_CONFIG_MONGODB_SERVER: mongo

  mysql:
    image: mysql
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: example
      MYSQL_USER: example
      MYSQL_PASSWORD: example
      MYSQL_ROOT_HOST: 127.0.0.1
    ports:
     - 3306:3306

  adminer:
    image: adminer
    restart: always
    ports:
      - 3333:8080



# configuration file for PG docker_postgres_init.sql

[root@devops lesson8.db]# cat docker_postgres_init.sql
create user prod with password 'prod' createdb;
create database prod
 with owner prod
 encoding = 'utf8'
 LC_COLLATE = 'en_US.utf8'
 lc_ctype = 'en_US.utf8'
 tablespace = pg_default
 connection limit = -1;

