#!/bin/bash

echo "$(date +'%m-%d-%y %H:%M:%S') Starting Container"
date 
echo "$(date +'%m-%d-%y %H:%M:%S') Environment Variables" 
env | sort 
echo "$(date +'%m-%d-%y %H:%M:%S') " 

echo "$(date +'%m-%d-%y %H:%M:%S') Starting" 

basenginxconf="/opt/containerfiles/base_nginx.conf"
derivednginxconf="/opt/containerfiles/derived_nginx.conf"
defaultrootlocation="/usr/share/nginx/html"

# nginx.conf

echo "$(date +'%m-%d-%y %H:%M:%S') Checking for nginx.conf BASE ENV($ENV_BASE_NGINX_CONFIG)" 
if [ -e $ENV_BASE_NGINX_CONFIG ]; then
    echo "$(date +'%m-%d-%y %H:%M:%S') -- Found nginx.conf BASE ENV($ENV_BASE_NGINX_CONFIG)" 
    basenginxconf="$ENV_BASE_NGINX_CONFIG"
else
    echo "$(date +'%m-%d-%y %H:%M:%S') Using Default nginx BASE ENV($basenginxconf)" 
fi

# derived nginx.conf

echo "$(date +'%m-%d-%y %H:%M:%S') Checking for nginx.conf DERIVED ENV($ENV_DERIVED_NGINX_CONFIG)" 
if [ -e $ENV_DERIVED_NGINX_CONFIG ]; then
    echo "$(date +'%m-%d-%y %H:%M:%S') -- Found Derived nginx configuration DERIVED ENV($ENV_DERIVED_NGINX_CONFIG)" 
    derivednginxconf="$ENV_DERIVED_NGINX_CONFIG"
else
    echo "$(date +'%m-%d-%y %H:%M:%S') Using Default nginx DERIVED ENV($derivednginxconf)" 
fi

# container-mounted volume for static assets

defrootvolume="/usr/share/nginx/html"
echo "$(date +'%m-%d-%y %H:%M:%S') Checking for Default Root Volume ENV($ENV_DEFAULT_ROOT_VOLUME)" 
if [ -d "$ENV_DEFAULT_ROOT_VOLUME" ]; then
    echo "$(date +'%m-%d-%y %H:%M:%S') -- Found Default Root Volume ENV($ENV_DEFAULT_ROOT_VOLUME)" 
    defrootvolume="$ENV_DEFAULT_ROOT_VOLUME"
else

    echo "$(date +'%m-%d-%y %H:%M:%S') Letting nginx start" 
    cur_count=0
    total_counts=10
    while [ $cur_count -lt $total_counts ];
    do
        if [ -d "$ENV_DEFAULT_ROOT_VOLUME" ]; then
            echo "$(date +'%m-%d-%y %H:%M:%S') -- Found Default Root Volume ENV($ENV_DEFAULT_ROOT_VOLUME) Retry($cur_count)" 
            cur_count=$total_counts
            defrootvolume="$ENV_DEFAULT_ROOT_VOLUME"
        else
            let cur_count=cur_count+1
            echo "$(date +'%m-%d-%y %H:%M:%S') Waiting on Retry($cur_count)" 
            sleep 1
        fi
    done

    echo "$(date +'%m-%d-%y %H:%M:%S') Using Root Volume ENV($defrootvolume)" 
fi

# Handle setting up the lets encrypt files with a vanilla nginx running
if [ "$ENV_USE_SSL" == "1" ]; then
    cp $basenginxconf /etc/nginx/nginx.conf
    cp /opt/containerfiles/derived_nginx.conf /etc/nginx/conf.d/default.conf

    echo ""
    echo "restore vanilla nginx with:"
    echo "cp $basenginxconf /etc/nginx/nginx.conf"
    echo "cp /opt/containerfiles/derived_nginx.conf /etc/nginx/conf.d/default.conf"
    echo "nginx &"
    echo ""

    chmod 666 /etc/nginx/nginx.conf
    chmod 666 /etc/nginx/conf.d/default.conf

    # Assign volumes for changing by certbot

    echo "$(date +'%m-%d-%y %H:%M:%S') Configuring Root Volume($defrootvolume) File(/etc/nginx/conf.d/default.conf)" 
    sed -i -e "s|CHANGE_TO_DEFAULT_ROOT_VOLUME|$defrootvolume|g" /etc/nginx/conf.d/default.conf
    sed -i -e "s|CHANGE_TO_ENV_BASE_FQDN|$ENV_BASE_FQDN|g" /etc/nginx/conf.d/default.conf
    sed -i -e "s|CHANGE_TO_ENV_SSL_CERT_FILE|$ENV_SSL_CERT_FILE|g" /etc/nginx/conf.d/default.conf
    sed -i -e "s|CHANGE_TO_ENV_SSL_KEY_FILE|$ENV_SSL_KEY_FILE|g" /etc/nginx/conf.d/default.conf

    echo "$(date +'%m-%d-%y %H:%M:%S') Starting nginx" 
    nohup nginx &
    echo "$(date +'%m-%d-%y %H:%M:%S') Done nginx" 

    existing_cert_filename=$(echo "${ENV_SSL_CERT_FILE}" | sed -e 's|/| |g' | awk '{print $NF}')
    existing_cert_path=${INT_MOUNTED_VOLUME}/${existing_cert_filename}
    existing_key_path=${INT_MOUNTED_VOLUME}/${existing_key_filename}
    existing_artifact_path=${INT_MOUNTED_VOLUME}/latest-certs.tgz

    echo "Checking for SSL(${existing_cert_path}) Args(${ENV_CERTBOT_REGISTER})" 
    echo "$existing_cert_path" 
    echo "$existing_key_path" 
    echo "$defrootvolume/$existing_cert_filename" 
    echo "$defrootvolume/$existing_key_filename" 
    echo "Artifact:" 
    echo "${existing_artifact_path}" 

    if [[ -e ${existing_artifact_path} ]]; then

        echo "Extracting: ${existing_artifact_path} to /etc/letsencrypt" 
        mkdir /opt/archive 
        pushd /opt/archive 
        echo "" 
        echo "Extracting:" 
        ls /opt/archive 
        tar xvf ${existing_artifact_path}
        echo "" 
        echo "Extracted:" 
        ls 
        mkdir -p -m 777 /etc/letsencrypt 
        cp -ra etc/letsencrypt /etc/ 
        popd

        ls /etc/letsencrypt 

        #cp $existing_cert_path $defrootvolume/$existing_cert_filename
        #cp $existing_key_path $defrootvolume/$existing_key_filename

        echo "$(date +'%m-%d-%y %H:%M:%S') Renewing Certs($ENV_CERTBOT_REGISTER)" 
        echo "$(date +'%m-%d-%y %H:%M:%S') /opt/containerfiles/certbot-auto renew --text" 
        /opt/containerfiles/certbot-auto renew --text
        echo "$(date +'%m-%d-%y %H:%M:%S') Done Renewing Certs($ENV_CERTBOT_REGISTER)" 
    else
        echo "$(date +'%m-%d-%y %H:%M:%S') Getting Certs($ENV_CERTBOT_REGISTER)" 
        echo "$(date +'%m-%d-%y %H:%M:%S') /opt/containerfiles/certbot-auto certonly $ENV_CERTBOT_REGISTER" 
        /opt/containerfiles/certbot-auto certonly $ENV_CERTBOT_REGISTER
        echo "$(date +'%m-%d-%y %H:%M:%S') Done Getting Certs($ENV_CERTBOT_REGISTER)" 
    fi

    echo "$(date +'%m-%d-%y %H:%M:%S') finding the latest certs: "
    ls -lt /etc/letsencrypt/live/
    newest_cert_full=$(ls -lt $(find /etc/letsencrypt/live/antinex.com-* -name "fullchain*.pem") | tail -1 | awk '{print $9}')
    newest_cert_priv=$(ls -lt $(find /etc/letsencrypt/live/antinex.com-* -name "privkey*.pem") | tail -1 | awk '{print $9}')
    nginx_cert_dir="/etc/letsencrypt/live/${ENV_BASE_FQDN}"

    echo "$(date +'%m-%d-%y %H:%M:%S') found the latest certs: ${newest_cert_full} ${newest_cert_priv}"
    if [[ ! -d ${nginx_cert_dir} ]]; then
        echo "$(date +'%m-%d-%y %H:%M:%S') - creating cert dir for nginx: ${nginx_cert_dir}"
        mkdir -p -m 777 ${nginx_cert_dir}
    fi
    echo "$(date +'%m-%d-%y %H:%M:%S') cp ${newest_cert_full} ${nginx_cert_dir}/fullchain.pem"
    echo "$(date +'%m-%d-%y %H:%M:%S') cp ${newest_cert_priv} ${nginx_cert_dir}/privkey.pem"
    cp ${newest_cert_full} ${nginx_cert_dir}/fullchain.pem
    cp ${newest_cert_priv} ${nginx_cert_dir}/privkey.pem
    ls -lrt ${nginx_cert_dir}
    echo "$(date +'%m-%d-%y %H:%M:%S') done installing certs"

    tar czpvf ${INT_MOUNTED_VOLUME}/latest-certs.tgz /etc/letsencrypt
    echo "$(date +'%m-%d-%y %H:%M:%S') Created Artifact: ${INT_MOUNTED_VOLUME}/latest-certs.tgz" 

    if [[ ! -e ${ENV_LETS_DIR} ]]; then
        echo "$(date +'%m-%d-%y %H:%M:%S') Creating Lets Encrypt dir: ${ENV_LETS_DIR}"
        mkdir -p -m 777 ${ENV_LETS_DIR}
    fi

    cp -ra $ENV_SSL_CERT_FILE ${INT_MOUNTED_VOLUME}/$existing_cert_filename
    cp -ra $ENV_SSL_KEY_FILE ${INT_MOUNTED_VOLUME}/$existing_key_filename

    if [[ "${ENV_START_NGINX}" == "1" ]]; then
        echo "$(date +'%m-%d-%y %H:%M:%S') Deploying robots.txt" 
        cp /opt/containerfiles/robots.txt $defrootvolume/robots.txt
    
        echo "$(date +'%m-%d-%y %H:%M:%S') Deploying production nginx config: /opt/nginx/nginx.conf"
        cp /opt/nginx/nginx.conf /etc/nginx/nginx.conf

        if [ "$ENV_USE_SSL" == "1" ]; then

            if [[ -f /tmp/firsttimerunning ]]; then
                echo "$(date +'%m-%d-%y %H:%M:%S') Stopping nginx" 
                kill -9 $(ps auwwx | grep nginx | awk '{print $2}') >> /dev/null 2>&1
                sleep 3
                echo "$(date +'%m-%d-%y %H:%M:%S') Initializing new nginx" 
                nohup /usr/sbin/nginx &
                echo "$(date +'%m-%d-%y %H:%M:%S') Done Initializing new nginx" 
                rm -f /tmp/firsttimerunning
            else
                echo "$(date +'%m-%d-%y %H:%M:%S') Reloading nginx" 
                /usr/sbin/nginx -s reload
                echo "$(date +'%m-%d-%y %H:%M:%S') Done Reloading" 
            fi
        else
            echo "$(date +'%m-%d-%y %H:%M:%S') Starting nginx" 
            nohup nginx & 
            echo "$(date +'%m-%d-%y %H:%M:%S') Done Starting"
        fi

        echo "$(date +'%m-%d-%y %H:%M:%S') Preventing the container from exiting"
        tail -f /opt/nginx/nginx.conf
        echo "$(date +'%m-%d-%y %H:%M:%S') Done preventing the container from exiting"
    else
        # auto-exit and let the host run nginx
        sleep 10
    fi

    exit 0

else
    echo "# Empty cronjob for running locally" > /var/spool/cron/root
    chmod 0644 /var/spool/cron/root
fi

exit 0

