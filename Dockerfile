FROM amazonlinux:2018.03
# Comments
# groupinstall "Development Tools" is necessary for xdebug

RUN yum remove php5* httpd24 php-* php-cli-* php-common-5.* php-common-5.3.29-1.8.amzn1.x86_64 php-cli-5.3.29-1.8.amzn1.x86_64 php-xml-5.3.29-1.8.amzn1.x86_64

# update amazon software repo
RUN yum -y update && yum -y install shadow-utils yum-utils\
    && yum-config-manager --enable remi-php73 && yum -y update

#configure time zone
RUN ln -f -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

#Intall utilites
RUN yum -y install vim wget git && yum -y groupinstall "Development Tools"

RUN yum remove httpd24 && yum remove httpd24-tools

#Install apache
RUN yum install -y httpd24 httpd24-tools mod24_ssl

#Auto start service
RUN chkconfig httpd on
RUN service httpd start

#Install php
RUN yum install -y php73.x86_64  php73-devel.x86_64 php73-cli.x86_64 php73-common.x86_64 php73-gd.x86_64 php73-intl.x86_64\
    php73-mbstring.x86_64 php73-mysqlnd.x86_64 php73-pdo.x86_64 php73-soap.x86_64 php73-xml.x86_64 php73-xmlrpc.x86_64

#Configurações adicionais do php
RUN echo 'include_path = ".:/usr/local/etc/php/"' >> /etc/php.ini

#Configuration XDebug
RUN echo 'zend_extension=/usr/lib64/php/7.3/modules/xdebug.so' >> /etc/php.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer



RUN yum install poppler-utils -y

RUN yum install perl-core zlib-devel php73-pecl-redis.x86_64 htop -y

# Install cairo
RUN yum install -y  cairo cups libSM

# Install LibreOffice
RUN wget https://p21-bkp-app.s3.amazonaws.com/LibreOffice_6.4.4_Linux_x86-64_rpm.tar.gz
RUN tar -xvf LibreOffice_6.4.4_Linux_x86-64_rpm.tar.gz
RUN yum install -y LibreOffice_6.4.4.2_Linux_x86-64_rpm/RPMS/*.rpm --skip-broken
RUN ln -s /opt/libreoffice6.4/program/soffice /usr/local/bin/
RUN rm -rf LibreOffice_6.4.4.2_Linux_x86-64_rpm/

# Install libxml2 dependency
#RUN yum remove libxml2-python27-2.9.1-6.* -y
#RUN yum install -y libxml2-python27-2.9.1-6.3.52.amzn1.x86_64
#
## Install libxml2
#RUN wget https://p21-bkp-app.s3.amazonaws.com/libxml2-2.9.1-6.3.52.amzn1.x86_64.rpm
#RUN rpm -Uvh libxml2-2.9.1-6.3.52.amzn1.x86_64.rpm --force

## Quality tools
RUN USERNAME=$('whoami') && composer global require squizlabs/php_codesniffer=*  phpcompatibility/php-compatibility=*

##Blackfire.io
#RUN mkdir "/conf.d" && version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
#    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
#    && mkdir -p /tmp/blackfire \
#    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
#    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so \
#    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > /etc/php/7.3/fpm/conf.d/blackfire.ini

EXPOSE  80

ENTRYPOINT ["/usr/sbin/httpd","-D","FOREGROUND"]