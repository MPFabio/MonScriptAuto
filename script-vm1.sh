
# Autoriser l'accès aux service azure dans Maria DB


# Update et Upgrade

sudo apt -y update 

sudo apt -y upgrade

# Installer Apache

sudo apt -y install apache2

# Installer Maria DB Client

sudo apt -y install mariadb-client-10.1

# Installer PHP

sudo apt -y install php php-mysql

# Changer de dossier et installer wordpress

cd /tmp && wget https://wordpress.org/latest.tar.gz

tar -xvf latest.tar.gz

sudo cp -R wordpress /var/www/html/

sudo chown -R www-data:www-data /var/www/html/wordpress/

sudo chmod -R 755 /var/www/html/wordpress/

sudo mkdir /var/www/html/wordpress/wp-content/uploads

sudo chown -R www-data:www-data /var/www/html/wordpress/wp-content/uploads/

# Entrez dans le client

mysql --user=NomDeConnexionDeLAdministrateurDuServeur --password=MotDePasse --host=NomDuServeur -e "create database wordpress;"


# Copier et et modifier le fichier config


sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

sudo sed -i "s/database_name_here/wordpress/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/NomDeConnexionDeLAdministrateurDuServeur/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/MotDePasse/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/localhost/NomDuServeur/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/It works!/VM1/" /var/www/html/index.html

# Enjoy your Wordpress
