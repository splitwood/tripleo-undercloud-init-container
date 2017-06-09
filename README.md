# tripleo-undercloud-init-container

This has been tested on CentOS 7. Ensure that all updates are applied.
Currently SELinux also must be set to permissive.

Installation
============

    git clone https://github.com/splitwood/tripleo-undercloud-init-container.git
    cd tripleo-undercloud-init-container
    sudo docker build -t tripleo-undercloud-init-container .
    sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -ti tripleo-undercloud-init-container

Ironic CLI
==========

After the installation completes, the Ironic CLI can be used as shown:

    export OS_AUTH_TOKEN=token
    export IRONIC_URL=http://192.168.23.18:6385
    export IRONIC_API_VERSION=1.31

    ironic node-list
