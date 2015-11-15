# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.

FROM phusion/baseimage:0.9.16
MAINTAINER Nicholas Hathaway <nicholas.hathaway@umassmed.edu>

# global env
ENV HOME=/root TERM=xterm

# set proper timezone
RUN echo America/New_York > /etc/timezone && sudo dpkg-reconfigure --frontend noninteractive tzdata

# update and upgrade 
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# install some... oh well ;-) generic stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget rsync emacs23-nox git

# install postgres for the user database.
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-9.3 postgresql-client-9.3 \
				postgresql-contrib-9.3 python-pip realpath libpq-dev python-dev \
				python-dateutil python-numpy python-pil; 

#
# Install all the pre-reqs for owncloud, 
#
RUN apt-get update && \
  apt-get install -y apache2 apache2-utils libapache2-mod-fcgid\
  libapache2-mod-php5 php5-apcu php5-ldap php5-mysql php5-pgsql\
  php5-sqlite php5-imagick php5-curl php5-intl php5-json php5-gd\
  php-net-ftp smbclient php5-mcrypt php5-pgsql php5-imagick openssl libreoffice winff && \
  php5enmod mcrypt && php5enmod pgsql && sudo a2enmod ssl && a2enmod rewrite



#
# Go get the owncloud version we'll installing
#
RUN OWNCLOUD_VERSION="8.1.4" && \
  cd /tmp && \
  curl -O https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 && \
  cd /opt && tar xjf /tmp/owncloud-${OWNCLOUD_VERSION}.tar.bz2



# add all the files necessary files from the files directory for misc operations
ADD /files/ /
RUN ln -s  /etc/apache2/conf-available/apache-owncloud.conf /etc/apache2/conf-enabled/apache-owncloud.conf
# setup adminpack in portgres
RUN /bin/bash -c '/usr/sbin/service postgresql start; echo "CREATE EXTENSION \"adminpack\";" | /usr/bin/sudo -u postgres /usr/bin/psql; /usr/sbin/service postgresql stop'


# create database 
RUN /bin/bash -c '/usr/sbin/service postgresql start; /usr/bin/sudo -u postgres /usr/bin/psql < /data/owncloud/scripts/createdb.sql ; /usr/sbin/service postgresql stop'

#
# Adjust ownership and do the baseline perms for security
#
RUN cd /opt && chown -R www-data:www-data owncloud && \
  find owncloud -type d -exec chmod 750 {} \; && \
  find owncloud -type f -exec chmod 640 {} \;
#
# Do system level configuration tweaks
#
RUN echo 'default_charset = UTF-8' >> /etc/php5/apache2/conf.d/charset.ini

#
# Perform the data directory initialization
#
# Sync calls are due to https://github.com/docker/docker/issues/9547
RUN cd / && chmod 755 /init.bash && \
  sync && /init.bash && \
  sync && rm /init.bash

#
# Make necessary scripts executable 
#

RUN chmod 755 /run.bash
RUN chmod 755 /etc/rc.local
RUN chmod 755 /root/copyfs.sh

#
# All data is stored on the root data volume. 
# The expected directories are: config, data, apps, dotfiles
#
VOLUME ["/owncloud-data"]

# Standard web ports exposted
EXPOSE 80/tcp 443/tcp

#set command as the init script so all running services (syslog, apache2, postgresql, etc)
CMD ["/sbin/my_init"]
