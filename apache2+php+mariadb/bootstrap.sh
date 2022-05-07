#!/usr/bin/env/bash

apt-get update

#MariaDB 

apt-get install mariadb-server 

#Apache PHP
apt-get install apache2 libapache2-mod-php php php-mysql 


# configuration files live at /etc/apache2/
rm -rf /var/www
mkdir -p /vagrant/www
ln -fs /vagrant/www /var/www

# Add the Includes module
a2enmod include

# Add Includes, AddType and AddOutputFilter directives
mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.bak
cp /vagrant/default /etc/apache2/sites-available/default

# To allow includes in index pages
mv /etc/apache2/mods-available/dir.conf /etc/apache2/mods-available/dir.conf.bak
cp /vagrant/dir.conf /etc/apache2/mods-available/dir.conf

# restart apache2
apachectl -k graceful

# smoke test
# open a brower to http://127.0.0.1:8080 to test
echo '<html><head><title>SSI Test Page</title></head><body><!--#echo var="DATE_LOCAL" --></body></html>' > /vagrant/www/index.html