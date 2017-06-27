# tripleo-undercloud-init-container

This has been tested on CentOS 7. Ensure that all updates are applied.
Currently SELinux also must be set to permissive.

TODO note about disk space. In Didi's case 20G in "/" was not enough, and adding 10G was enough.

Preparations for a minimal CentOS installation
==============================================

One way to use this project is on top of an undercloud VM created using
https://github.com/splitwood/tripleo-virt-quickstart .

If you do this, rest of current section should not be needed - you can
use the user 'stack' in this VM.

To use on minimal CentOS 7:

Create a non-root user, e.g. 'ironicbm':

    useradd -G wheel ironicbm
    passwd ironicbm
    su - ironicbm

Make sure this user can ssh to localhost without a password prompt, and
can sudo without a password prompt:

    ssh-keygen
    ssh-copy-id localhost
    sudo sh -c "echo 'ironicbm ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/ironicbm"

Set SELinux to Permissive mode:

    sudo setenforce 0

Make sure you have CentOS Extras repo enabled, e.g.:

    sudo yum install -y centos-release

Add tripleo repos:

    git clone https://git.openstack.org/openstack/tripleo-repos
    cd tripleo-repos
    sudo python setup.py install
    cd
    sudo tripleo-repos current

Install ironic client and ansible from tripleo repos:

    sudo yum install -y python2-ironicclient ansible

Installation
============

Install and start docker if not already done:

    sudo yum -y install docker
    sudo systemctl start docker

Create a custom environments dir and add this file there:

    export YOUR_CUSTOM_ENVS_DIR=$HOME/custom-environments
    mkdir -p $YOUR_CUSTOM_ENVS_DIR
    git clone https://github.com/splitwood/tripleo-undercloud-init-container.git
    cp tripleo-undercloud-init-container/ironic-standalone.yaml $YOUR_CUSTOM_ENVS_DIR
    cd tripleo-undercloud-init-container
    sudo docker build -t apb-tripleo-undercloud .
    sudo docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v $YOUR_CUSTOM_ENVS_DIR:/custom-environments \
      -ti apb-tripleo-undercloud provision

The installer will take a few minutes to run (typically 10-15 minutes). When
the docker run command exits, you can then watch the logs with:

    sudo docker logs -f undercloud-deploy

When successful, you will see "Deploy Successful" toward the end of the log.

Ironic CLI
==========

After the installation completes, the Ironic CLI can be used as shown. Replace
the IP address shown below with the actual IP address of your undercloud and
add the following to ~/.bashrc of the undercloud non-root user:

    export OS_AUTH_TOKEN=token
    export IRONIC_URL=http://192.168.23.18:6385
    export IRONIC_API_VERSION=1.31

    ironic node-list


Reinstalling the container
==========================

Just rerunning the docker run command for installation may result in errors.

I've found that first you have to clean up the old installation before
rerunning.

This is a destructive operation that will completely delete all containers on
the undercloud and remove any stateful data from the previous install!

    docker ps -q -a | xargs -tn1 docker stop
    docker ps -q -a | xargs -tn1 docker rm -f
    rm -rf /var/lib/mysql/* /var/lib/rabbitmq/* /var/lib/config-data/rabbitmq/etc/rabbitmq/*
    rm -rf /var/lib/ironic/* /var/lib/ironic-inspector/*

You're now ready to rerun the steps from the Installation section.
