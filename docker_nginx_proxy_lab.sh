# This is a handy script to setup a web server proxy lab on CentOS 7/8
# https://github.com/jwilder/nginx-proxy

# Install stuff

yum -y update
yum -y install epel-release
yum -y update
yum -y install git nano nmap tcpdump wget
yum -y install yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y update
yum -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
yum -y install docker-ce

# Allow http through SELinux
setsebool -P httpd_can_network_connect 1

# Start and enable Docker
systemctl enable --now docker
usermod -aG docker $USER

# Define a bridge network
docker network create \
--driver=bridge \
--subnet=10.10.10.0/24 \
--gateway=10.10.10.1 \
-o "com.docker.network.bridge.enable_icc"="true" \
-o "com.docker.network.bridge.enable_ip_masquerade"="true" \
-o "com.docker.network.bridge.name"="br0" \
-o "com.docker.network.driver.mtu"="1500" \
br0

systemctl restart docker

# Allow network traffic through this bridge
firewall-cmd --permanent --zone=trusted --change-interface=br0
firewall-cmd --reload

# Start the proxy container and some arbitrary nginx boxes for testing/exampls

docker run --name proxy -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro --network=br0 --ip 10.10.10.2 --restart unless-stopped jwilder/nginx-proxy
docker run -d --name servera --expose 80 --network=br0 --ip 10.10.10.10 -e VIRTUAL_HOST=servera.com --restart unless-stopped nginx
docker run -d --name serverb --expose 80 --network=br0 --ip 10.10.10.11 -e VIRTUAL_HOST=serverb.com --restart unless-stopped nginx
docker run -d --name serverc --expose 80 --network=br0 --ip 10.10.10.12 -e VIRTUAL_HOST=serverc.com --restart unless-stopped nginx
