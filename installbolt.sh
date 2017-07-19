#!/bin/sh

# A script to install and configure Bolt CMS on Centos 7
# Fred Tesche 2017 fred@fakecomputermusic.com

# Run system updates and get some useful packages
yum -y update
yum -y install tcpdump nano wget

# Grab the Remi and Epel repos and enable
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm
rpm -Uvh epel-release-7*.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7*.rpm
sed -i -e '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo
sed -i -e '/\[remi-php56\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo
rm epel-release-7-9.noarch.rpm remi-release-7.rpm

# Install PHP, extensions, mariadb server, firewall, and phpmyadmin
yum -y install php php-pdo php-mysqlnd php-pgsql php-gd php-mbstring php-posix php-xml mariadb mariadb-server firewalld phpmyadmin

# Configure the firewall and enable httpd and mariadb
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
systemctl enable httpd.service
systemctl start httpd.service
systemctl enable mariadb.service
systemctl start mariadb.service

# Grab bolt, install, fix selinux
mkdir /var/www/bolt
chown apache:apache /var/www/bolt
cd /var/www/bolt
sudo -u apache curl -O https://bolt.cm/distribution/bolt-latest.tar.gz
sudo -u apache tar -xzf bolt-latest.tar.gz --strip-components=1
sudo -u apache php /var/www/bolt/app/nut setup:sync
rm bolt-latest.tar.gz
chcon -t httpd_sys_rw_content_t /var/www/bolt/ -R

# Add bolt apache configs
cat > /etc/httpd/conf.d/bolt.conf << EOL
<VirtualHost _default_:80>
        DocumentRoot /var/www/bolt/public
        <Directory /var/www/bolt/public>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                Allow from all
        </Directory>
</VirtualHost>
EOL

# Add phpmyadmin apache configs
cat > /etc/httpd/conf.d/phpMyAdmin.conf << EOL
# phpMyAdmin - Web based MySQL browser written in php
# 
# Allows only localhost by default
#
# But allowing phpMyAdmin to anyone other than localhost should be considered
# dangerous unless properly secured by SSL

Alias /phpMyAdmin /usr/share/phpMyAdmin
Alias /phpmyadmin /usr/share/phpMyAdmin

<Directory /usr/share/phpMyAdmin/>
	AddDefaultCharset UTF-8

	<IfModule mod_authz_core.c>
		# Apache 2.4
		Require all granted
		Order Deny,Allow
		Allow from 192.168.0.0/16
		Allow from 172.16.0.0/12
		Allow from 10.0.0.0/8
		Allow from 127.0.0.1
	</IfModule>
</Directory>

<Directory /usr/share/phpMyAdmin/setup/>
	<IfModule mod_authz_core.c>
		# Apache 2.4
		Require all granted
		Order Deny,Allow
		Allow from 192.168.0.0/16
		Allow from 172.16.0.0/12
		Allow from 10.0.0.0/8
		Allow from 127.0.0.1
	</IfModule>
</Directory>

# These directories do not require access over HTTP - taken from the original
# phpMyAdmin upstream tarball
#
<Directory /usr/share/phpMyAdmin/libraries/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>

<Directory /usr/share/phpMyAdmin/setup/lib/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>

<Directory /usr/share/phpMyAdmin/setup/frames/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>

# This configuration prevents mod_security at phpMyAdmin directories from
# filtering SQL etc.  This may break your mod_security implementation.
#
#<IfModule mod_security.c>
#    <Directory /usr/share/phpMyAdmin/>
#        SecRuleInheritance Off
#    </Directory>
#</IfModule>
EOL

systemctl restart httpd.service

