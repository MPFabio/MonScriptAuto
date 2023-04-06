
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

mysql --user=fabio@mdbserv315445887 --password=PIcciNO69200!MaRaTEa? --host=mdbserv315445887.mariadb.database.azure.com -e "create database wordpress;"


# Copier et et modifier le fichier config


sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

sudo sed -i "s/database_name_here/wordpress/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/fabio@mdbserv315445887/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/PIcciNO69200!MaRaTEa?/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/localhost/mdbserv315445887.mariadb.database.azure.com/" /var/www/html/wordpress/wp-config.php


# Enjoy your Wordpress
