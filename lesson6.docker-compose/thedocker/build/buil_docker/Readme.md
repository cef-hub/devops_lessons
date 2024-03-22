[root@devops build]# docker builder prune
WARNING! This will remove all dangling build cache. Are you sure you want to continue? [y/N] y
ID                                              RECLAIMABLE     SIZE            LAST ACCESSED
wi5edvl7mtgiegkxb5op1650l*                      true            22.24kB         7 minutes ago
vlmm3a143w29bq02gwnxa621p                       true    249B            12 minutes ago
yi2ti1u5gjjbkb6oe933gml1g                       true    249B            10 minutes ago
npf6ixukj2s72d9jxtu2a8mp0*                      true    625B            7 minutes ago
anpo2f32w8cwlmzt8kydsqtju*                      true    0B              7 minutes ago
g5zpq3dzdmk34ecti45c9krfa                       true    3.322kB         7 minutes ago
dbbm6hvpftm46odphnuw1s9xu                       true    909B            10 minutes ago
hlkmyq00wjj0lvqnx65ign15q                       true    5.552kB         7 minutes ago
p49ti4d7disngdcugxb3b8pza                       true    909B            12 minutes ago
iwueq6mso2d96nujbm4lpkqor                       true    12.01kB         10 minutes ago
w4rbeowy035bb1x14c9cjo5q3                       true    12.01kB         12 minutes ago
1yfisne5ij69e32fvzyczbewb                       true    202B            7 minutes ago
xxpa6mh9lt2n5dei66vify8nn                       true    83.86MB         10 minutes ago
xoe7k6i8pca3y8h3zm1vch5dp                       true    0B              7 minutes ago
h33xe39zt6xsa4aoc9rllj1ox                       true    83.86MB         12 minutes ago
vkr0idrlk1jvd355t9eh12htt                       true    0B              7 minutes ago
nlbdt2k1g6dqkphylhw4x1y1z                       true    0B              7 minutes ago
ruwjowv7pkqydlo25l4m9t2ec                       true    249B            7 minutes ago
42s9c5lqow3j20ga1aq3plhjw                       true    909B            7 minutes ago
o94os90096tniw5gmq213btx9                       true    12.01kB         7 minutes ago
e8ph4x6am4m3lezsegbbcnj6o                       true    83.86MB         7 minutes ago
pc2wsqo8yfqpyqwpbtf8gegsl                       true    0B              7 minutes ago
k7ib6drsb4nqi9wylzvj3wtp3                       true    0B              13 minutes ago
Total:  251.7MB

[root@devops build]# nano Dockerfile

FROM dokken/centos-stream-9:latest

ENV HOME_DIR /var/www/localhost/htdocs
ENV LOG_DIR /var/www/logs
ENV CONF_DIR /etc/httpd

RUN dnf update && \
    dnf upgrade && \
    dnf install -y httpd mod_ssl

COPY httpd.conf $CONF_DIR/conf/httpd.conf
COPY admin.conf $CONF_DIR/conf.d/ssl.conf
COPY admin-vhost.conf $CONF_DIR/conf/admin-vhost.conf

WORKDIR $HOME_DIR
RUN mkdir -p admin
RUN chown -R apache:apache /var/www
COPY index.html $HOME_DIR/admin/index.html
COPY devops.nces.by.crt $CONF_DIR/devops.nces.by.crt
COPY devops.nces.by.key $CONF_DIR/devops.nces.by.key

EXPOSE 80 443

CMD ["httpd", "-D", "FOREGROUND", "-e", "info"]


[root@devops build]# docker build --no-cache -t wtf_httpd_docker:latest .

[+] Building 60.5s (16/16) FINISHED docker:default
=> [internal] load build definition from Dockerfile 0.0s
 => => transferring dockerfile: 657B 0.0s
 => [internal] load metadata for docker.io/dokken/centos-stream-9:latest 2.0s
 => [internal] load .dockerignore 0.0s
 => => transferring context: 2B 0.0s
 => [ 1/11] FROM docker.io/dokken/centos-stream-9:latest@sha256:5971386d56c9dcc47831ed18e5b7a2ff4b5cfbbf5f02c90a919470dc7b5a2f43 20.0s
 => => resolve docker.io/dokken/centos-stream-9:latest@sha256:5971386d56c9dcc47831ed18e5b7a2ff4b5cfbbf5f02c90a919470dc7b5a2f43 0.0s
 => => sha256:da5cac70b457c225b8eb034875c52200b4bf35e81afb7fa32f3c196420a2b104 49.57MB / 49.57MB 4.7s
 => => sha256:5971386d56c9dcc47831ed18e5b7a2ff4b5cfbbf5f02c90a919470dc7b5a2f43 1.61kB / 1.61kB 0.0s
 => => sha256:4c16fa60e4c9a56d3e74f75a7680514b36c53e237f04a3c25113f49dfd5d8aa3 675B / 675B 0.0s
 => => sha256:bbf46232f846a7741572cdcdf9f19c33755b7292d91aed01db5739c4ad38d4d9 4.51kB / 4.51kB 0.0s
 => => sha256:a4fce492bde6a3b94c488710eb004997076e9fe948efab1b38a79566d55714bb 57.77MB / 57.77MB 7.3s
 => => extracting sha256:a4fce492bde6a3b94c488710eb004997076e9fe948efab1b38a79566d55714bb 7.0s
 => => extracting sha256:da5cac70b457c225b8eb034875c52200b4bf35e81afb7fa32f3c196420a2b104 5.1s
 => [internal] load build context  0.0s
 => => transferring context: 22.55kB 0.0s
 => [ 2/11] RUN dnf update && dnf upgrade && dnf install -y httpd  34.9s
 => [ 3/11] COPY httpd.conf /etc/httpd/conf/httpd.conf 0.1s
 => [ 4/11] COPY ssl.conf /etc/httpd/conf.d/ssl.conf 0.0s
 => [ 5/11] COPY admin-vhost.conf /etc/httpd/conf.d/admin-vhost.conf 0.0s
 => [ 6/11] WORKDIR /var/www/localhost/htdocs 0.0s
 => [ 7/11] RUN mkdir -p admin 0.3s
 => [ 8/11] RUN chown -R apache:apache /var/www 1.4s
 => [ 9/11] COPY index.html /var/www/localhost/htdocs/admin/index.html 0.1s
 => [10/11] COPY devops.nces.by.crt /etc/httpd/devops.nces.by.crt 0.1s
 => [11/11] COPY devops.nces.by.key /etc/httpd/devops.nces.by.key 0.0s
 => exporting to image 1.3s
 => => exporting layers 1.3s
 => => writing image sha256:85980953216ae6e510ce45e397581cbec46ffe83a48b0be65aee48277787a118 0.0s
 => => naming to docker.io/library/wtf_httpd_docker:latest 
 
[root@devops build]# docker images

REPOSITORY         TAG               IMAGE ID       CREATED         SIZE
wtf_httpd_docker   latest            85980953216a   8 minutes ago   387MB
ussage             latest            1f4d4225d271   4 days ago      435MB
postgres           16.2-alpine3.19   09ac24c200ca   2 weeks ago     243MB
httpd              latest            2776f4da9d55   5 weeks ago     167MB
httpd              2.4-alpine        ad88fc1ec140   2 months ago    61.6MB
httpd              alpine3.19        ad88fc1ec140   2 months ago    61.6MB


[root@devops build]# docker run -d -p 90:80 -p 444:443 --name my_httpd_container -v /root/devops/lesson6.docker-compose/thedocker/build/httpd-htdocs:/var/www/localhost/htdocs -v /root/devops/lesson6.docker-compose/thedocker/build/httpd-logs:/var/www/logs  wtf_httpd_docker:latest
cc6322ed527824e8e836443b7ed84c6a3d2b59fa2ff676165ea0327492a13bc9

[root@devops build]# docker ps -a
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                                                                      NAMES
cc6322ed5278   wtf_httpd_docker:latest    "httpd -D FOREGROUND…"   3 seconds ago   Up 3 seconds   0.0.0.0:90->80/tcp, :::90->80/tcp, 0.0.0.0:444->443/tcp, :::444->443/tcp   my_httpd_container


[root@devops build]# curl https://devops.nces.by:444
<!DOCTYPE html>
<html>
<head>
    <title>It's work I am Docker in Docker</title>
</head>
<body>
    <h1>It's work I am Docker</h1>
    <p>This is a simple Docker Apache HTTP Server.</p>
</body>
</html>
[root@devops build]# curl https://devops.nces.by:444
<!DOCTYPE html>
<html>
<head>
    <title>It's work I am Docker in Docker</title>
</head>
<body>
    <h1>It's work I am Docker</h1>
    <p>This is a simple Docker Apache HTTP Server.</p>
</body>
</html>
