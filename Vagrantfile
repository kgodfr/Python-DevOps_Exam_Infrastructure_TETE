Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.define :master do |master|
    # Vagrant va récupérer une machine de base ubuntu 20.04 (focal) depuis cette plateforme https://app.vagrantup.com/boxes/search
    master.vm.box = "ubuntu/focal64"
    master.vm.hostname = "master"
    master.vm.network :private_network, ip: "192.168.59.10"   
    master.vm.provision :shell, privileged: false, inline: <<-SHELL
      sudo apt update
      sudo apt install python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools -y
      sudo apt install python3-venv -y
      mkdir ~/mymasterproject
      cd mymasterproject/
      python3 -m venv mymasterprojectenv
      source mymasterprojectenv/bin/activate
      pip install wheel
      pip install gunicorn flask
      sudo apt install mysql-server postfix supervisor nginx git -y    
      sudo apt-get update
      sudo apt-get install ca-certificates curl gnupg -y
      sudo install -m 0755 -d /etc/apt/keyrings -y
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      sudo chmod a+r /etc/apt/keyrings/docker.gpg
      echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
      curl -sfL https://get.k3s.io | sh -
  
    SHELL

  end
end