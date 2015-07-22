#!/bin/bash

# this assumes ""${NAME}"" is disposable!
# runs ${IMAGE} with external file systems mounted in.

export IMAGE="owncloud"
export NAME="owncloud"
export BASE="/data/docker/owncloud"


if [ "X$1" != "Xyes" ]; then
	echo
	echo "--------------------------------------------------------------------"
	echo "This script destroys existing container with name \"${NAME}\" and"
	echo "starts a new instance based on ${IMAGE}."
	echo
	echo "Run as '$0 yes' if this is what you intend to do."
	echo "--------------------------------------------------------------------"
	echo
	exit 0
fi

docker stop "${NAME}"
docker rm "${NAME}"

docker run \
	-v "${BASE}/owncloudInternals/var/lib/postgresql:/var/lib/postgresql" \
	-v "${BASE}/owncloudInternals/var/log:/var/log" \
	-v "${BASE}/owncloudData:/owncloud-data" \
	-e SSL_ENABLED=true  \
	-P -p 127.0.0.1:8000:80 \
	-p 127.0.0.1:8443:443 \
	-d --restart=always \
	--hostname="${NAME}" --name="${NAME}" "${IMAGE}"
	
	
	 