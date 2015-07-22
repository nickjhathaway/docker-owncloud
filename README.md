# owncloud

An owncloud 8.0.4 container designed for a simple standalone deployment. Key features are:

1. The configuration/data is truly externalized, allowing container replacement/upgrading (`/owncloud-data`)


The configuration of the container was created following the support guide suggested by [owncloud's manual installation guide](https://doc.owncloud.org/server/8.0/admin_manual/).

Most features from origianl xetus-oss/docker-owncloud are now missing and might come back.  Mostly setup for ownsetup on own server, changes in future will change to change this to be abstracted out


## The owncloud-data volume

The externalized data directory contains 4 directories: `data`, `config`, `apps`, and `dotfiles`

 The `data`, `config`, and `apps` directory are all standard in an owncloud installation, so reference the owncloud documentation for those. `dotfiles` is a custom directory because owncloud stores certain configuration settings in the `.htaccess` and `.user.ini` files that should persist between container replacements.

## Caveats / Gotchas

#### The volume directory must be executable by `other`

In order for the apache processes in the container to properly read the files in the dotfiles directory (.htaccess, etc), the executable bit must be set on the volume folder in the host.



Pull requests/code copying is welcome.
