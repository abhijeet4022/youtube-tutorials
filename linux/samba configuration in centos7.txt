# Introduction
# Samba is an open-source software suite. Its primary function is to enable file and printer sharing among different operating systems within a network.
# Ex: If we want to share one file from linux os to Windows, we can use samba.



yum install samba cifs-utils -y
mkdir /common_share
chmod 777 /common_share
semanage fcontext -at samba_share_t "/common_share(/.*)?"
restorecon -Rv /common_share

setfacl -m u:user1:wrx /common_share

firewall-cmd --permanent --add-service=samba
firewall-cmd --reload

vim /etc/samba/smb.conf
[common_share]
    comment = Sharing directory
    browseable = yes
    path = /common_share
    valid users = user1
    write list = user1
    writeable = yes

testparm
useradd user1
passwd user1
smbpasswd -a user1
pdbedit -Lv

systemctl restart smb
systemctl restart nmb
systemctl enable smb
systemctl enable nmb

smbclient -L //localhost -U user1


