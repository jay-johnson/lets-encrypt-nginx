#!/bin/bash

domain="antinex.com"
imagename="certbot-nginx"
full_imagename="jayjohnson/${imagename}"
archive_dir="/opt/antinex/archive"
certs_dir="/opt/antinex/certs/release"
lets_encrypt_dir="/opt/antinex/letsencrypt/${domain}"
shared_dir="/opt/antinex/shared"
splunk_dir="/opt/antinex/splunk"
static_dir="/opt/antinex/static"
web_dir="/opt/antinex/web"

if [[ ! -d ${archive_dir} ]]; then
    echo "creating archive directory: ${archive_dir}"
    mkdir -p -m 777 ${archive_dir}
    if [[ "$?" != "0" ]]; then
        echo "Failed creating director: ${archive_dir}"
        echo ""
        echo "mkdir -p -m 777 ${archive_dir}"
        echo ""
        exit 1
    fi
fi

if [[ ! -d ${certs_dir} ]]; then
    echo "creating x509 certs directory: ${certs_dir}"
    mkdir -p -m 777 ${certs_dir}
    if [[ "$?" != "0" ]]; then
        echo "Failed creating director: ${certs_dir}"
        echo ""
        echo "mkdir -p -m 777 ${certs_dir}"
        echo ""
        exit 1
    fi
fi

if [[ ! -d ${lets_encrypt_dir} ]]; then
    echo "creating lets encrypt directory: ${lets_encrypt_dir}"
    mkdir -p -m 777 ${lets_encrypt_dir}
    if [[ "$?" != "0" ]]; then
        echo "Failed creating director: ${lets_encrypt_dir}"
        echo ""
        echo "mkdir -p -m 777 ${lets_encrypt_dir}"
        echo ""
        exit 1
    fi
fi

if [[ ! -d ${shared_dir} ]]; then
    echo "creating shared directory: ${shared_dir}"
    mkdir -p -m 777 ${shared_dir}
    if [[ "$?" != "0" ]]; then
        echo "Failed creating director: ${shared_dir}"
        echo ""
        echo "mkdir -p -m 777 ${shared_dir}"
        echo ""
        exit 1
    fi
fi

if [[ ! -d ${shared_dir}/logs ]]; then
    echo "creating shared logs directory: ${shared_dir}/logs"
    mkdir -p -m 777 /opt/shared/logs
    if [[ "$?" != "0" ]]; then
        echo "Failed creating director: ${shared_dir}/logs"
        echo ""
        echo "mkdir -p -m 777 ${shared_dir}/logs"
        echo ""
        exit 1
    fi
fi

if [[ ! -d ${splunk_dir} ]]; then
    echo "creating optional splunk assets directory: ${splunk_dir}"
    mkdir -p -m 777 ${splunk_dir}
    if [[ "$?" != "0" ]]; then
        echo "Failed creating director: ${splunk_dir}"
        echo ""
        echo "mkdir -p -m 777 ${splunk_dir}"
        echo ""
        exit 1
    fi
fi

if [[ ! -d ${static_dir} ]]; then
    echo "creating static directory: ${static_dir}"
    mkdir -p -m 777 ${static_dir}
    if [[ "$?" != "0" ]]; then
        echo "Failed creating director: ${static_dir}"
        echo ""
        echo "mkdir -p -m 777 ${static_dir}"
        echo ""
        exit 1
    fi
fi

if [[ ! -d ${web_dir} ]]; then
    echo "creating static assets directory: ${web_dir}"
    mkdir -p -m 777 ${web_dir}
    if [[ "$?" != "0" ]]; then
        echo "Failed creating director: ${web_dir}"
        echo ""
        echo "mkdir -p -m 777 ${web_dir}"
        echo ""
        exit 1
    fi
fi

echo ""
echo "Starting nginx docker container with Let's Encrypt"
echo ""
echo " - Archive dir:  ${archive_dir}"
echo " - x509s Certs dir:  ${certs_dir}"
echo " - Lets Encrypt dir: ${lets_encrypt_dir}"
echo " - Shared dir: ${shared_dir}"
echo " - Optional Splunk dir: ${splunk_dir}"
echo " - Static Assets Splunk dir: ${web_dir}"
echo ""
echo "On success the certs are stored in dir: ${lets_encrypt_dir}"
echo ""
docker-compose -f docker-compose.yml up -d

exit 0
