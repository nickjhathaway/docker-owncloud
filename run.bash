#!/bin/bash

#
# Owncloud container bootstrap. See the readme for usage.
#
source /data_dirs.env
FIRST_TIME_INSTALLATION=false
DATA_PATH=/owncloud-data

mkdir -p ${DATA_PATH}/dotfiles
chown www-data:www-data ${DATA_PATH}/dotfiles
mkdir -p ${DATA_PATH}/data
chown www-data:www-data ${DATA_PATH}/data

cd /opt/owncloud
for datadir in "${DATA_DIRS[@]}"; do
  if [ ! -e "${DATA_PATH}/${datadir}" ]
  then
    echo "Installing ${datadir}"
    if [ -e "${datadir}-template" ]
    then
      cp -pr ${datadir}-template ${DATA_PATH}/${datadir}
    else 
      mkdir -p ${DATA_PATH}/${datadir}
    fi
    chown www-data:www-data ${DATA_PATH}/${datadir}
    FIRST_TIME_INSTALLATION=true
  fi
done

for dotfile in "${DATA_DOT_FILES[@]}"; do
  if [ ! -e "${DATA_PATH}/dotfiles/${dotfile}" ]
  then
    echo "Installing ${dotfile}"
    if [ -e "${dotfile}-template" ]
    then
      cp -p ${dotfile}-template ${DATA_PATH}/dotfiles/${dotfile}
    else 
      touch ${DATA_PATH}/dotfiles/${dotfile}
    fi

    FIRST_TIME_INSTALLATION=true
  fi
done

SSL_SITE_CONF_TEMPLATE='<VirtualHost _default_:443>
  DocumentRoot /opt/owncloud
  SSLCertificateFile    $SSL_CERT
  SSLCertificateKeyFile $SSL_KEY
  $CHAIN_FILE_ENTRY
</VirtualHost>'

SITE_CONF_TEMPLATE='<VirtualHost *:80>
  DocumentRoot /opt/owncloud
</VirtualHost>'


if [ ! -e /._container_setup ]
then
  #
  # SSL configuration (optional, see readme)
  #
  # Varaibles:
  # - SSL_ENABLED
  # - SSL_CERT
  # - SSL_KEY
  # - SSL_CA
  DEFAULT_SSL_ENABLED=false
  if [[ -n "$SSL_CERT" || -n "$SSL_KEY" ]]
  then
    DEFAULT_SSL_ENABLED=true
  fi
  SSL_CERT=${SSL_CERT:-/${DATA_PATH}/ssl/crt.pem}
  SSL_KEY=${SSL_KEY:-/${DATA_PATH}/ssl/key.pem}
  SSL_ENABLED=${SSL_ENABLED:-$DEFAULT_SSL_ENABLED}
  if [ $SSL_ENABLED == true ]
  then
    echo "Enabling SSL"
    if [ -n "$SSL_CA" ]
    then
      CHAIN_FILE_ENTRY="SSLCertificateChainFile $SSL_CA"
    fi
    eval SSL_SITE_CONF_TEMPLATE=\""$SSL_SITE_CONF_TEMPLATE"\"
    echo "$SSL_SITE_CONF_TEMPLATE" > /etc/apache2/sites-enabled/default_ssl.conf
    
    if [[ ! -e "$SSL_CERT" && ! -e "$SS_KEY" ]]
    then
      echo "Generating self-signed certificate for HTTPS support"
      mkdir -p ${DATA_PATH}/ssl/
      openssl req -nodes -x509 -newkey rsa:4096\
        -keyout $SSL_KEY -out $SSL_CERT -days 3650\
        -subj "/CN=${HOSTNAME}/"
    fi
    chmod 600 $SSL_KEY
    chown www-data:www-data /etc/apache2/sites-enabled/default_ssl.conf
  fi

  #
  # Support the installation of an arbitrary number of ca certs
  #
  if [[ -n "$SSL_CA" && -e "$SSL_CA" ]]
  then
    cp $SSL_CA /usr/local/share/ca-certificates/${SSL_CA##*/}.crt
    update-ca-certificates
  fi
  if [ -n "$CA_CERTS_DIR" ]
  then
    find $CA_CERTS_DIR -type f \( -iname \*.crt -o -iname \*.pem \)
      -exec bash -c 'cp "$1" /usr/local/share/ca-certificates/"${RANDOM}_${1##*/}.crt"' _ {} \;
    update-ca-certificates
  fi
  
  echo "$SITE_CONF_TEMPLATE" > /etc/apache2/sites-available/000-default.conf 
  touch /._container_setup
fi

if [ $FIRST_TIME_INSTALLATION == true ]
then
  RANDOM_PASS=`date +%s | md5sum | base64 | head -c 8`
  export DB_TYPE=${DB_TYPE:-sqlite}
  export DB_NAME=${DB_NAME:-owncloud}
  export DB_HOST=${DB_HOST:-ocdb}

  export ADMIN_LOGIN=${ADMIN_LOGIN:-admin}
  if [ -z "$ADMIN_PASS" ]  
  then
    echo "The admin password will be set to: $RANDOM_PASS"
  fi
  export ADMIN_PASS=${ADMIN_PASS:-$RANDOM_PASS}
fi

apachectl -DFOREGROUND