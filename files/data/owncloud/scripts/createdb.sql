
CREATE USER ownclouduser WITH PASSWORD 'needcoffee';
CREATE DATABASE owncloud TEMPLATE template0 ENCODING 'UNICODE';
ALTER DATABASE owncloud OWNER TO owncloudUser;
GRANT ALL PRIVILEGES ON DATABASE owncloud TO owncloudUser;
