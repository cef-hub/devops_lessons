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
COPY devops.nces.by.crt $CONF_DIR/devops.nces.by.crt
COPY devops.nces.by.key $CONF_DIR/devops.nces.by.key

RUN chown -R apache:apache /var/www

RUN mkdir -p $HOME_DIR/admin
COPY index.html $HOME_DIR/admin/index.html

EXPOSE 80 443

CMD ["httpd", "-D", "FOREGROUND", "-e", "info"]
