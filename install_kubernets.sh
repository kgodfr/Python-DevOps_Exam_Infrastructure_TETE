#!/bin/bash

# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation des dépendances
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Ajout de la clé GPG officielle de Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Ajout du référentiel de Kubernetes au gestionnaire de paquets
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# Mise à jour du système après l'ajout du référentiel
sudo apt update

# Installation de Kubernetes
curl -sfL https://get.k3s.io | sh -
sudo apt install -y kubelet kubeadm kubectl

# Désactivation du swap pour Kubernetes
sudo swapoff -a

# Configuration de cgroup pour Kubernetes
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo "kubelet cgroup-driver=systemd" | sudo tee /etc/default/kubelet

# Redémarrage de kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Installation de minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Démarrage du cluster
minikube start

# Testez la connexion avec 
kubectl get nodes

# Affichage de la version 
kubectl version

# Bash completion
sudo apt install bash-completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ${HOME}/.bashrc

