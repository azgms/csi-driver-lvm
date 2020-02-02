#!/usr/bin/bash

mkdir ~/.minikube/files/etc/kubernetes/addons
cp -R deploy/minikube-addons/psp.yaml ~/.minikube/files/etc/kubernetes/addons/

minikube start --memory 4g --extra-config=apiserver.enable-admission-plugins=PodSecurityPolicy

minikube ssh 'for i in 0 1; do fallocate -l 1G loop${i} ; sudo losetup -f loop${i}; sudo losetup -a ; done'
minikube ssh 'sudo rm /sbin/losetup'
scp -o 'StrictHostKeyChecking=no' -i $(minikube ssh-key) /usr/sbin/losetup  docker@$(minikube ip):/tmp/losetup
minikube ssh 'sudo mv /tmp/losetup /sbin/losetup'
./deploy/kubernetes-1.17/deploy-lvm.sh
kubectl apply -f examples/csi-storageclass.yaml
