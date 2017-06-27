#!/bin/sh

# A script to install and configure Bolt CMS on Centos 7
# Fred Tesche 2017 fred@fakecomputermusic.com

# Run system updates and get some useful packages
yum -y update
yum -y install tcpdump nano wget

# Grab the Remi and Epel repos and enable
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
rpm -Uvh epel-release-7*.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7*.rpm
sed -i -e '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo
sed -i -e '/\[remi-php56\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo
rm epel-release-7-9.noarch.rpm remi-release-7.rpm

# Install PHP and extensions
yum -y install php php-pdo php-mysqlnd php-pgsql php-gd php-mbstring php-posix php-xml

# Configure the firewall and enable httpd
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
systemctl start httpd
systemctl start httpd.service

# Grab bolt, install, fix selinux
mkdir /var/www/bolt
chown apache:apache /var/www/bolt
cd /var/www/bolt
sudo -u apache curl -O https://bolt.cm/distribution/bolt-latest.tar.gz
sudo -u apache tar -xzf bolt-latest.tar.gz --strip-components=1
sudo -u apache php /var/www/bolt/app/nut setup:sync
rm bolt-latest.tar.gz
chcon -t httpd_sys_rw_content_t /var/www/bolt/ -R

# Add bolt virtualhost and restart Apache
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
systemctl restart httpd.service

