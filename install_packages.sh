#!/bin/bash

set -ex

yum install -y \
    git \
    vim \
    sudo \
    docker \
    python-dev \
    python-setuptools

# Remove unnecessary packages
yum autoremove -y
yum clean all
