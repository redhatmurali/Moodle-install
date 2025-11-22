#!/bin/bash
#
# Auto-Install Moodle on Ubuntu 20.04/22.04
# Includes Apache, PHP, MariaDB, Moodle, and Moodledata setup.
#
# Run as: sudo bash install_moodle.sh
#

echo "-------------------------------------------"
echo " Updating system packages"
echo "-------------------------------------------"
apt update && apt upgrade -y

echo "-------------------------------------------"
echo " Installing Apache"
echo "-------------------------------------------"
apt install apache2 -y
systemctl enable apache2
systemctl start apache2

echo "-------------------------------------------"
echo " Installing PHP & extensions"
echo "-------------------------------------------"

apt install -y php php-fpm php-cli php-xml php-zip php-curl php-gd php-intl php-mbstring php-soap php-ldap php-pspell php-readline php-bcmath php-mysql php-xmlrpc php-json php-opcache php-redis

echo "-------------------------------------------"
echo " Installing MariaDB Server"
echo "-------------------------------------------"
apt install mariadb-server -y
systemctl enable mariadb
systemctl start mariadb

echo "-------------------------------------------"
echo " Creating Moodle Database"
echo "-------------------------------------------"

DBPASS="StrongPassword123"

mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY '$DBPASS';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Database created with password: $DBPASS"

echo "-------------------------------------------"
echo " Downloading Moodle"
echo "-------------------------------------------"

cd /var/www/
git clone https://github.com/moodle/moodle.git
cd moodle
git checkout MOODLE_403_STABLE

echo "-------------------------------------------"
echo " Setting permissions"
echo "-------------------------------------------"

chown -R www-data:www-data /var/www/moodle
chmod -R 755 /var/www/moodle

mkdir /var/moodledata
chown -R www-data:www-data /var/moodledata
chmod -R 777 /var/moodledata

echo "-------------------------------------------"
echo " Creating Apache virtual host"
echo "-------------------------------------------"

cat <<EOF >/etc/apache2/sites-available/moodle.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/moodle

    <Directory /var/www/moodle>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/moodle_error.log
    CustomLog \${APACHE_LOG_DIR}/moodle_access.log combined
</VirtualHost>
EOF

a2ensite moodle
a2dissite 000-default
a2enmod rewrite
systemctl restart apache2

echo "-------------------------------------------"
echo " Moodle Installation Script Completed!"
echo "-------------------------------------------"
echo " Open your browser and visit:  http://YOUR-SERVER-IP"
echo " Continue installation via the web installer."
echo " Database info:"
echo "   DB Name: moodle"
echo "   DB User: moodleuser"
echo "   DB Pass: $DBPASS"
echo "-------------------------------------------"
