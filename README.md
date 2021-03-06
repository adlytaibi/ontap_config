ontap_config
============

This playbook sets up ONTAP two SVMs for multi-protocol access in a minimalist way.
- One NFS SVM with `unix` security style volume sharing volume to NFS and CIFS clients.
- One CIFS SVM with `ntfs` security style volume sharing volume to CIFS and NFS clients.

Requirements and steps
----------------------

- Speedy way to deploy (all step-by-step commands below plus running the playbook)

```bash
ssh root@rhel1
curl -sSL https://raw.githubusercontent.com/adlytaibi/ontap_config/master/build.sh|bash
```

- Or step-by-step install Ansible and NetApp module

```bash
ssh root@rhel1
yum install python-pip git -y
pip install ansible netapp-lib
git clone https://github.com/adlytaibi/ontap_config.git
cd ontap_config
```

- Run playbook

The `vars.yml` file contains the variables if you wish to change.

```bash
ansible-playbook build.yml

PLAY [Multiprotocol SVMs] **************************************************************

TASK [Create aggregate] ****************************************************************
ok: [localhost]

TASK [Create nfs SVM] ******************************************************************
changed: [localhost]

TASK [Create nfs interface] ************************************************************
changed: [localhost]

TASK [change nfs status] ***************************************************************
changed: [localhost]

TASK [Setup dns for cifs SVM] **********************************************************
changed: [localhost]

TASK [Create cifs server] **************************************************************
changed: [localhost]

TASK [Setup default rules] *************************************************************
changed: [localhost]

TASK [Setup nfs export rules] **********************************************************
changed: [localhost]

TASK [Create nfs volume] ***************************************************************
changed: [localhost]

TASK [Create cifs share] ***************************************************************
changed: [localhost]

TASK [Setup cifs share ACLs] ***********************************************************
changed: [localhost]

TASK [Remove everyone from share ACLs] *************************************************
changed: [localhost]

TASK [Create unix user] ****************************************************************
changed: [localhost]

TASK [Name mapping for user to administrator] ******************************************
changed: [localhost]

TASK [Create cifs SVM] *****************************************************************
changed: [localhost]

TASK [change nfs status] ***************************************************************
changed: [localhost]

TASK [Create cifs interface] ***********************************************************
changed: [localhost]

TASK [Setup dns for cifs SVM] **********************************************************
changed: [localhost]

TASK [Create cifs server] **************************************************************
changed: [localhost]

TASK [Setup default rules] *************************************************************
changed: [localhost]

TASK [Setup cifs export rules] *********************************************************
changed: [localhost]

TASK [Create cifs volume] **************************************************************
changed: [localhost]

TASK [Create cifs share] ***************************************************************
changed: [localhost]

TASK [Setup cifs share ACLs] ***********************************************************
changed: [localhost]

TASK [Remove everyone from share ACLs] *************************************************
changed: [localhost]

TASK [Create unix user] ****************************************************************
changed: [localhost]

TASK [Name mapping for user to administrator] ******************************************
changed: [localhost]

PLAY RECAP *****************************************************************************
localhost : ok=27   changed=26   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

- On Linux mount both volumes and test access with both root and user access

```bash
mkdir /mnt/{cifs,nfs}
mount -overs=3,sec=sys 192.168.0.131:/nfs /mnt/nfs
mount -overs=3,sec=sys 192.168.0.132:/cifs /mnt/cifs
mkdir /mnt/nfs/user;chown user.user /mnt/nfs/user
date > /mnt/nfs/root.txt
su - user
date > /mnt/nfs/user/user.txt
date > /mnt/cifs/user.txt
exit
umount /mnt/*
```

- Turn on NFSv4 by editing idmapd.conf and service restart `systemctl restart rpcidmapd`

```bash
egrep -v "^$|^#" /etc/idmapd.conf
[General]
Domain = demo.netapp.com
[Mapping]
Nobody-User = nobody
Nobody-Group = nobody
[Translation]
Method = nsswitch
```

- After restarting rpcidmapd, you should be able to mount with NFSv4

```bash
mount -overs=4.0,sec=sys 192.168.0.131:/nfs /mnt/nfs
mount -overs=4.0,sec=sys 192.168.0.132:/cifs /mnt/cifs
```

- On Windows test access to both volumes

```bash
PS C:\Users\Administrator.DEMO> get-date | out-file \\192.168.0.131\nfs\admin.txt
PS C:\Users\Administrator.DEMO> get-date | out-file \\192.168.0.132\cifs\admin.txt
```

- Here is a summary of the files written to both volumes from NFS and CIFS clients

```bash
tree -p -f -i -u -g /mnt/nfs /mnt/cifs

/mnt/nfs
[-rwxr-xr-x root     bin     ]  /mnt/nfs/admin.txt
[-rw-r--r-- root     root    ]  /mnt/nfs/root.txt
[drwxr-xr-x user     user    ]  /mnt/nfs/user
[-rw-rw-r-- user     user    ]  /mnt/nfs/user/user.txt

/mnt/cifs
[-rwxrwxrwx root     bin     ]  /mnt/cifs/admin.txt
[-rwxrwxrwx user     user    ]  /mnt/cifs/user.txt

1 directory, 5 files
```

- Also included a teardown playbook

```bash
ansible-playbook teardown.yml

PLAY [Multiprotocol SVMs] **************************************************************

TASK [Delete nfs interface] ************************************************************
changed: [localhost]

TASK [Delete nfs volume] ***************************************************************
changed: [localhost]

TASK [Delete cifs server] **************************************************************
changed: [localhost]

TASK [Delete nfs SVM] ******************************************************************
changed: [localhost]

TASK [Delete cifs interface] ***********************************************************
changed: [localhost]

TASK [Delete cifs volume] **************************************************************
changed: [localhost]

TASK [Delete cifs server] **************************************************************
changed: [localhost]

TASK [Delete cifs SVM] *****************************************************************
changed: [localhost]

PLAY RECAP *****************************************************************************
localhost : ok=8    changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### Note: The computer in Active directory needs to be deleted manually.

- Delete the computers from active directory, open powershell on AD server or machine with tools.

```bash
PS C:\Users\Administrator> remove-adcomputer nfs
Confirm
Are you sure you want to perform this action?
Performing the operation "Remove" on target "CN=NFS,CN=Computers,DC=demo,DC=netapp,DC=com".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):

PS C:\Users\Administrator> remove-adcomputer cifs
Confirm
Are you sure you want to perform this action?
Performing the operation "Remove" on target "CN=CIFS,CN=Computers,DC=demo,DC=netapp,DC=com".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
PS C:\Users\Administrator>
```

License
-------

GPL

Author Information
------------------

- Adly Taibi

