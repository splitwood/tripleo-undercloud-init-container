# tripleo-undercloud-init-container

Installation
============

    git clone https://github.com/splitwood/tripleo-undercloud-init-container.git
    cd tripleo-undercloud-init-container
    sudo docker build -t tripleo-undercloud-init-container .
    sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -ti tripleo-undercloud-init-container
