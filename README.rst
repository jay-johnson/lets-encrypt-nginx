Nginx with Let's Encrypt
------------------------

This is a repository for deploying nginx with Let's Encrypt certificates inside a docker container. It uses an `nginx docker container <https://github.com/jay-johnson/docker-nginx>`__ that is configured to register and renew certs while utilizing the volume-mounted nginx.conf after installing valid Let's Encrypt certificates.

I use this container to secure my own projects:

- `Blog <https://jaypjohnson.com/>`__
- `AntiNex <https://api.antinex.com/docs>`__

Getting Started
---------------

#.  Clone

    ::

        git clone https://github.com/jay-johnson/lets-encrypt-nginx.git /opt/antinex/nginx

#.  Set Domain and Subdomains

    This repository uses environment variables in the file: `antinex.env <https://github.com/jay-johnson/lets-encrypt-nginx/blob/master/antinex.env>`__ for registering and renewing certificates. Please configure all subdomains as needed.

#.  Register 

    It can take a few tries to debug all the issues with registering certs for a new domain. Here is a script to make this easier to debug:

    ::
        
        ./initial_testing.sh

#.  Renew on Restart

    To restart nginx use `run.sh <https://github.com/jay-johnson/lets-encrypt-nginx/blob/master/run.sh>`__ to restart nginx and auto-renew the registered Let's Encrypt certificates.

    ::

        ./run.sh

Tail the Container Logs
=======================

::

    docker logs -f nginx

License
-------

Apache 2.0 - Please refer to the LICENSE_ for more details

.. _License: https://github.com/jay-johnson/lets-encrypt-nginx/blob/master/LICENSE
