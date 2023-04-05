# Autoriser l'accès aux service azure dans Maria DB

# Update et Upgrade

sudo apt -y update 

sudo apt -y upgrade

# Install Apache

sudo apt -y install apache2

# Install Maria DB Client

sudo apt -y install mariadb-client-10.1

# Install PHP

sudo apt -y install php php-mysql

# Move directory and install Wordpress

cd /tmp && wget https://wordpress.org/latest.tar.gz

tar -xvf latest.tar.gz

sudo cp -R wordpress /var/www/html/

sudo chown -R www-data:www-data /var/www/html/wordpress/

sudo chmod -R 755 /var/www/html/wordpress/

sudo mkdir /var/www/html/wordpress/wp-content/uploads

sudo chown -R www-data:www-data /var/www/html/wordpress/wp-content/uploads/

# Move Directory

cd /var/www/html/wordpress

# OFF SCRIPT

echo "CREATE DATABASE wordpress" > dbm.sql

mysql -u fabio@mdbserv282511204 -p PIcciNO69200!MaRaTEa? -h mdbserv282511204.mariadb.database.azure.com < dbm.sql

# OFF SCRIPT

# Copy and edit config file 


sudo cp wp-config.sample.php wp-config.php

sudo sed -i "s/database_name_here/wordpress/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/fabio@mdbserv282511204/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/PIcciNO69200!MaRaTEa?/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/localhost/mdbserv282511204.mariadb.database.azure.com/" /var/www/html/wordpress/wp-config.php


# Enjoy your Wordpress


# Répeter la même opération pour la seconde VM
