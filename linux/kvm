How to create vm in centos7 using kvm ?

Step 1: Check if your CPU supports hardware virtualization:

	egrep -c '(vmx|svm)' /proc/cpuinfo

	vmx: This extension refer Intel processors.
	svm: This extension refer AMD processors.

If the output is greater than zero, your CPU supports virtualization.



Step 2: Install KVM Packages

sudo yum install qemu-kvm libvirt virt-viewer virt-install bridge-utils -y

sudo systemctl enable libvirtd
sudo systemctl start libvirtd




Step 3: Download the CentOS 7 iso or mount the /dev/sr0 in a directory and use

echo /dev/sr0 /os iso9660 defaults 0 0 >> /etc/fstab

# cp -r /run/media/root/CentOS\ 7\ x86_64/ /tmp/CentOS_7_x86_64.iso

Step 4: Attach one disk and create lvm from that disk and use it for VM.

/vm_datastore/vm/centos   /dev/kvm_vg/kvm_lv

pvcreate /dev/sdb
vgcreate kvm_vg /dev/sdb
lvcreate -n kvm_lv -l +100%FREE /dev/kvm_vg
mkfs.xfs /dev/kvm_vg/kvm_lv
echo /dev/kvm_vg/kvm_lv /vm_datastore/vm xfs defaults 0 0 >> /etc/fstab
mkdir -p /vm_datastore/vm/centos
mount -a
cd /vm_datastore/vm/centos/
qemu-img create -f qcow2 /vm_datastore/vm/centos/centos.qcow2 20G
qemu-img delete -f qcow2 /vm_datastore/vm/centos/centos.qcow2 20G

mkdir -p /vm_datastore/vm/lan
qemu-img create -f qcow2 /vm_datastore/vm/lan/lan.qcow2 20G



Step 5: Set Up the bridge Networking

sudo nmcli conn add type bridge con-name br0 ifname br0
sudo nmcli conn add type bridge-slave con-name br0-slave-ens38 ifname ens38 master br0
sudo nmcli conn modify br0 ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1 ipv4.method manual
sudo nmcli conn up br0
sudo systemctl restart network
sudo systemctl restart NetworkManager




Step 6: Begin Installation Use virt-install to start the installation :



virt-install \
--name lan \
--memory 1024 \
--vcpus 1 \
--disk path=/vm_datastore/vm/lan/lan.qcow2,size=20 \
--os-variant centos7.0 \
--cdrom /tmp/CentOS-7-x86_64-Minimal-2009.iso \
--network bridge=br0 \
--graphics vnc,listen=0.0.0.0 \
--console pty \
--extra-args 'console=ttyS0,115200'


virsh console centos
virsh dumpxml lan > lan.xml