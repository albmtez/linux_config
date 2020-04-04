@!/bin/bash

if [ -f /etc/disk_added_date ]
then
   echo "disk already added so exiting."
   exit 0
fi

sudo fdisk -u /dev/sda <<EOF
n
p
3


t
3
8e
w
EOF

sleep 4
partprobe
pvcreate /dev/sda3
vgextend systemvg /dev/sda3
lvextend -l +100%FREE /dev/systemvg/root

test=$(blkid -t TYPE=ext4 /dev/systemvg/root)
if [[ ! -z $test ]]; then
    resize2fs /dev/systemvg/root
fi

test=$(blkid -t TYPE=xfs /dev/systemvg/root)
if [[ ! -z $test ]]; then
    xfs_growfs /
fi

date > /etc/disk_added_date