# tripleo-undercloud-init-container

This has been tested on CentOS 7. Ensure that all updates are applied.
Currently SELinux also must be set to permissive.

Installation
============

Create a custom environments dir and add this file there:

    cat > $YOUR_CUSTOM_ENVS_DIR/ironic-standalone.yaml <<-EOF_CAT
    resource_registry:
      OS::TripleO::Undercloud::Net::SoftwareConfig: /opt/apb/tripleo-heat-templates/net-config-noop.yaml
      OS::TripleO::Services::IronicDnsmasq: templates/ironic-dnsmasq.yaml

    parameter_defaults:
      UndercloudServices:
        - OS::TripleO::Services::MySQL
        - OS::TripleO::Services::Apache
        - OS::TripleO::Services::RabbitMQ
        - OS::TripleO::Services::IronicApi
        - OS::TripleO::Services::IronicConductor
        - OS::TripleO::Services::IronicPxe
        - OS::TripleO::Services::IronicDnsmasq

      UndercloudExtraConfig:
          ironic::auth_strategy: noauth
          ironic::conductor::automated_clean: false
          ironic::drivers::ipmi::retry_timeout: 60
          ironic::config::ironic_config:
            dhcp/dhcp_provider:
              value: none


    EOF_CAT

    git clone https://github.com/splitwood/tripleo-undercloud-init-container.git
    cd tripleo-undercloud-init-container
    sudo docker build -t apb-tripleo-undercloud .
    sudo docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v $YOUR_CUSTOM_ENVS_DIR:/custom-environments \
      -ti apb-tripleo-undercloud provision

Ironic CLI
==========

After the installation completes, the Ironic CLI can be used as shown:

    export OS_AUTH_TOKEN=token
    export IRONIC_URL=http://192.168.23.18:6385
    export IRONIC_API_VERSION=1.31

    ironic node-list

Reinstalling the container
==========================

Just rerunning the docker run command for installation may result in errors.
These are the steps I use to clean up the old install first before rerunning
which usually works.

This is a destructive operation that will completely delete all containers on
the undercloud and remove any stateful data from the previous install!

    docker ps -q -a | xargs -tn1 docker stop
    docker ps -q -a | xargs -tn1 docker rm -f
    rm -rf /var/lib/mysql/* /var/lib/rabbitmq/* /var/lib/config-data/rabbitmq/etc/rabbitmq/*
