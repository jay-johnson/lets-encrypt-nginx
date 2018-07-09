#!/bin/bash

git pull
docker stop nginx
docker rm nginx
if [[ -e /opt/antinex/certs/latest-certs.tgz ]]; then
    sudo rm -f /opt/antinex/certs/latest-certs.tgz
fi
./run.sh
docker logs nginx
echo ""
echo "certs will be found in:"
ls -l /opt/antinex/certs/release
echo ""

echo "tail the container with:"
echo "docker logs -f nginx"
