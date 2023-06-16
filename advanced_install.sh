#!/bin/bash

# Étape 1 - Installation des composants depuis les référentiels Ubuntu
sudo apt update
sudo apt install -y python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools

# Étape 2 - Création d'un environnement virtuel Python
sudo apt install -y python3-venv
mkdir ~/myproject
cd ~/myproject
python3 -m venv myprojectenv
source myprojectenv/bin/activate

# Étape 3 - Configuration d'une application Flask
pip install wheel
pip install gunicorn flask

# Création de l'application Flask
cat <<EOF > ~/myproject/myproject.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "<h1 style='color:blue'>Hello There!</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0')
EOF

# Autorisation de l'accès au port 5000
sudo ufw allow 5000

# Exécution de l'application Flask
python ~/myproject/myproject.py &

# Création du point d'entrée WSGI
cat <<EOF > ~/myproject/wsgi.py
from myproject import app

if __name__ == "__main__":
    app.run()
EOF

# Étape 4 - Configuration de Gunicorn et du service systemd
cat <<EOF | sudo tee /etc/systemd/system/myproject.service > /dev/null
[Unit]
Description=Gunicorn instance to serve myproject
After=network.target

[Service]
User=vagrant
Group=www-data
WorkingDirectory=/home/vagrant/myproject
Environment="PATH=/home/vagrant/myproject/myprojectenv/bin"
ExecStart=/home/vagrant/myproject/myprojectenv/bin/gunicorn --workers 3 --bind unix:myproject.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
EOF

# Rechargement de systemd
sudo systemctl daemon-reload

# Démarrage et activation du service myproject
sudo systemctl start myproject
sudo systemctl enable myproject

# Vérification du statut du service myproject
sudo systemctl status myproject

# Désactivation de l'environnement virtuel
deactivate

# Étape 5 - Configuration de Nginx
sudo apt install -y nginx

# Création du fichier de configuration pour Nginx
sudo tee /etc/nginx/sites-available/myproject > /dev/null <<EOF
server {
    listen 80;
    server_name 192.168.59.10;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/vagrant/myproject/myproject.sock;
    }
}
EOF

# Activation du site Nginx
sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled/
sudo systemctl restart nginx
