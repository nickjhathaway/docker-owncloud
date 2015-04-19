# owncloud

An owncloud 8.0.2 container designed for a simple standalone deployment. Key features are:

1. The configuration/data is truly externalized, allowing container replacement/upgrading (`/owncloud-data`)
2. Configurable SSL support is included, with the ability to add custom CA's at the OS level
3. Linked container support for postgres and mysql/mariadb using the `ocdb` alias

The configuration of the container was created following the support guide suggested by [owncloud's manual installation guide](https://doc.owncloud.org/server/8.0/admin_manual/).

## Quick Start

The command below will setup a running owncloud container with externalized data/configuration

```
 docker run -d --name owncloud -h owncloud -d -p 80:80 -v /owncloud_mnt:/owncloud-data xetusoss/owncloud
```

## Available Configuration Parameters

### Container parameters

The following parameters are used every time the container is replaced, regardless of the externalized configurations.

* __SSL_ENABLED__: Configure HTTPS support. Default is `true` if `SSL_CERT` and `SSL_KEY` are defined, otherwise `false`.
* __SSL_CERT__: The certificate path for the SSL certificate to use, must be in the PEM format. Default is `/owncloud-data/ssl/crt.pem`.
* __SSL_KEY__: The SSL key path to use, must be in the PEM format and have no password. Default is `/owncloud-data/ssl/key.pem`.
* __SSL_CA__: The CA cert path to us, must be in the PEM format. This cert will be added to the systems certificates, which are used by owncloud. No default value.
* __CA_CERTS_DIR__: A directory of CA certificates in the PEM format. These certificates will be installed into the container on host boot, useful for trusting non-standard CA's for various SSL tasks. No default.

### Initialization parameters

The following parameters are only used to setup the initial configuration. Once the configuration has been established, theses are not used. All the parameters here map to configuration values in the owncloud config.php.

See the [owncloud documentation](https://doc.owncloud.org/server/8.1/admin_manual/configuration_server/config_sample_php_parameters.html) for what each parameter does. The goal here is not to support every parameter, just those parameters
that you really would like to have in place before you get the the UI.


|Environment Variable|autoconfig.php   |Default                                |
|--------------------|-----------------|---------------------------------------|
|DB_TYPE             |dbtype           |sqlite                                 |
|DB_NAME             |dbname           |owncloud                               |
|DB_TABLE_PREFIX     |dbtableprefix    |                                       |
|DB_USER             |dbuser           |                                       |
|DB_PASS             |dbpass           |                                       | 
|DB_HOST             |dbhost           |                                       | 
|ADMIN_LOGIN         |adminlogin       |admin                                  |
|ADMIN_PASS          |adminpass        |(randomly generated, printed to stdout)|
|LANGUAGE            |default_language |                                       |
|PROXY               |proxy            |                                       |
|PROXY_USER_PASSWORD |proxyuserpwd     |                                       |


## Examples

#### (1) HTTPS Support (generated certificate)
Make sure /somepath/owncloud_mnt exists

```
 docker run --name owncloud -h owncloud -d -p 443:443\
  -e SSL_ENABLED=true -v /somepath/owncloud_mnt:/owncloud-data xetusoss/owncloud
```
#### (2) HTTPS Support (custom certificate included)


Create a public/private key pair and place them in data mount under `ssl/crt.pem` and `ssl/key.pem`. The locations can be changed using the __SSL_CERT__ and __SSL_KEY__ environment variables.

```
 docker run --name owncloud -h owncloud -d -p 443:443\
  -e SSL_ENABLED=true -v /somepath/owncloud_mnt:/owncloud-data xetusoss/owncloud
```

#### (3) Use a MYSQL db, with a linked container

The example below creates a owncloud container with the linked mysql db

```
docker run --name owncloud -h owncloud -p 443:443\
  -v /somepath/owncloud_mnt:/owncloud-data --link mysql:ocdb -e DB_TYPE="mysql"\
  -e DB_USER="SOMEUSER" -e DB_PASS="SOMEPASS" -e SSL_ENABLED=true xetusoss/owncloud
```

#### (4) Use a MYSQL db, with an external host

The example below creates a owncloud container using an external db

```
docker run --name owncloud -h owncloud -p 443:443\
  -v /somepath/owncloud_mnt:/owncloud-data -e DB_TYPE="mysql" -e DB_HOST="db.example.com:3306"\
  -e DB_USER="SOMEUSER" -e DB_PASS="SOMEPASS" -e SSL_ENABLED=true xetusoss/owncloud
```

## The owncloud-data volume

The externalized data directory contains 4 directories: `data`, `config`, `apps`, and `dotfiles`

 The `data`, `config`, and `apps` directory are all standard in an owncloud installation, so reference the owncloud documentation for those. `dotfiles` is a custom directory because owncloud stores certain configuration settings in the `.htaccess` and `.user.ini` files that should persist between container replacements.


## Why another owncloud container?

We went through each of the 130+ owncloud containers available on docker hub, and we (amazingly) couldn't find a container that both properly externalized the data/configuration and supported SSL with custom CA certificates. Since this is such a pleasantly simple task, we decided to just our own.

Pull requests/code copying is welcome.