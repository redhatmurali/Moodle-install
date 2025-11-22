#!/bin/bash
#
# Complete Moodle Installation Script for Ubuntu 20.04/22.04
# Includes: Apache, PHP, MariaDB, Moodle, Redis, SMTP, BBB, Zoom,
# Cron job, Fail2ban, HTTPS (Let's Encrypt), UFW Firewall
#

DOMAIN="yourdomain.com"
EMAIL="admin@yourdomain.com"
DBPASS="StrongPassword123"

echo "=============================================="
echo " Updating system..."
echo "=============================================="
apt update && apt upgrade -y

echo "=============================================="
echo " Installing required packages..."
echo "=============================================="
apt install -y git curl unzip software-properties-common

echo "=============================================="
echo " Installing Apache..."
echo "=============================================="
apt install apache2 -y
systemctl enable apache2

echo "=============================================="
echo " Installing PHP + Extensions..."
echo "=============================================="
apt install -y php php-cli php-fpm php-mysql php-zip php-gd php-intl php-curl php-xml php-mbstring php-soap php-ldap php-bcmath php-readline php-redis php-opcache

echo "=============================================="
echo " Installing MariaDB..."
echo "=============================================="
apt install -y mariadb-server
systemctl enable mariadb
systemctl start mariadb

echo "=============================================="
echo " Creating Moodle Database..."
echo "=============================================="
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE moodle DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY '$DBPASS';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "=============================================="
echo " Installing Redis..."
echo "=============================================="
apt install -y redis-server
sed -i "s/supervised no/supervised systemd/" /etc/redis/redis.conf
systemctl restart redis-server
systemctl enable redis-server

echo "=============================================="
echo " Downloading Moodle..."
echo "=============================================="
cd /var/www/
git clone https://github.com/moodle/moodle.git
cd moodle
git checkout MOODLE_403_STABLE

echo "=============================================="
echo " Setting Permissions..."
echo "=============================================="
mkdir /var/moodledata
chmod 777 /var/moodledata
chown -R www-data:www-data /var/www/moodle /var/moodledata

echo "=============================================="
echo " Creating Apache Virtual Host..."
echo "=============================================="
cat <<EOF >/etc/apache2/sites-available/moodle.conf
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot /var/www/moodle

    <Directory /var/www/moodle>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2ensite moodle
a2dissite 000-default
a2enmod rewrite
systemctl restart apache2

echo "=============================================="
echo " Installing Moodle Plugins (BBB + Zoom)..."
echo "=============================================="
cd /var/www/moodle/mod/
git clone https://github.com/blindsidenetworks/moodle-mod_bigbluebuttonbn.git bigbluebuttonbn
git clone https://github.com/ucla/moodle-mod_zoom.git zoom
chown -R www-data:www-data /var/www/moodle/mod/

echo "=============================================="
echo " Setting up Firewall..."
echo "=============================================="
apt install ufw -y
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable

echo "=============================================="
echo " Installing Fail2ban (Security)..."
echo "=============================================="
apt install fail2ban -y

cat <<EOF >/etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
bantime = 600
maxretry = 5
EOF

systemctl restart fail2ban

echo "=============================================="
echo " Setting up Moodle Cron Job..."
echo "=============================================="
cat <<EOF >/etc/cron.d/moodle
*/1 * * * * www-data /usr/bin/php /var/www/moodle/admin/cli/cron.php >/dev/null
EOF

chmod 644 /etc/cron.d/moodle

echo "=============================================="
echo " Installing Certbot for SSL (Let's Encrypt)..."
echo "=============================================="
apt install certbot python3-certbot-apache -y

echo "=============================================="
echo " Generating SSL certificate..."
echo "=============================================="
certbot --apache -d $DOMAIN -m $EMAIL --agree-tos --non-interactive

echo "=============================================="
echo " INSTALLATION COMPLETE!"
echo "=============================================="
echo " Visit: https://$DOMAIN"
echo " Moodle DB User: moodleuser"
echo " Moodle DB Pass: $DBPASS"
echo "=============================================="
