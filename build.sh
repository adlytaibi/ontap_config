#!/usr/bin/env bash
cd ~
yum install python-pip git -y
pip install ansible netapp-lib
if [ -d ontap_config ]; then
  cd ontap_config
  git pull
else
  git clone https://github.com/adlytaibi/ontap_config.git
  cd ontap_config
fi
ansible-playbook build.yml
