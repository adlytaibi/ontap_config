#!/usr/bin/env bash
cd ~
yum install python-pip git -y
pip install ansible netapp-lib
git clone https://github.com/adlytaibi/ontap_config.git
cd ontap_config
ansible-playbook build.yml
