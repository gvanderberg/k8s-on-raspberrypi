#!/bin/bash

echo 1\) Install Docker

curl -fSLs https://get.docker.com | sh && \
usermod pi -aG docker

echo 2\) Disable swap

dphys-swapfile swapoff && \
dphys-swapfile uninstall && \
update-rc.d dphys-swapfile remove

echo 3\) Add repo lists \& install kubeadm

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
apt-get update -q && \
apt-get install -qy kubeadm

echo 4\) Adding " cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt

cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | tee /boot/cmdline.txt

echo 5\) Please reboot
