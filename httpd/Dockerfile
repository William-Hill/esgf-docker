# ESGF node with Apache httpd and mod_wsgi

FROM esgfhub/esgf-node:devel

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install latest apache httpd
RUN yum -y update \
    && yum install -y httpd httpd-devel mod_ssl \
    && yum clean all

# install mod_wsgi
RUN cd /tmp
RUN wget 'https://pypi.python.org/packages/c3/4e/f9bd165369642344e8fdbe78c7e820143f73d3beabfba71365f27ee5e4d3/mod_wsgi-4.5.3.tar.gz' && \
    tar xvf mod_wsgi-4.5.3.tar.gz && \
    cd mod_wsgi-4.5.3 && \
    python setup.py install && \
    rm -rf /tmp/mod_wsgi*
RUN cd /etc/httpd/modules && \
    ln -s /usr/local/lib/python2.7/site-packages/mod_wsgi-4.5.3-py2.7-linux-x86_64.egg/mod_wsgi/server/mod_wsgi-py27.so ./mod_wsgi-py27.so

# by default PYTHON_EGG_CACHE=/var/www/.python-eggs 
RUN mkdir -p /var/www/.python-eggs && \
    chown -R apache:apache /var/www/.python-eggs

# configuration for standalone service
# (overridden by ESGF settings when running with docker-compose from parent directory)
COPY certs/ /etc/certs/
COPY html/ /var/www/html/
COPY conf/httpd.conf /etc/httpd/conf.d/httpd.conf
COPY conf/ssl.conf /etc/httpd/conf.d/ssl.conf

EXPOSE 80 443

# start httpd server
# parent process runs as 'root' to access port 80 and configuration files,
# but it does NOT serve client requests
# the child processes that serve user requests run as user 'apache'
ADD conf/supervisord.httpd.conf /etc/supervisor/conf.d/supervisord.httpd.conf
ADD scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
