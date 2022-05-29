#!/bin/bash

sudo yum update -y
sudo yum install -y nfs-utils
sudo yum install git -y

#FILE_SYSTEM_ID
FILE_SYSTEM_ID=fs-0f094f34eb85182b3

AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone )
REGION=${AVAILABILITY_ZONE:0:-1}
MOUNT_POINT=/var/www/html
sudo mkdir -p ${MOUNT_POINT}
sudo chown ec2-user:ec2-user ${MOUNT_POINT}
#echo ${FILE_SYSTEM_ID}.efs.${REGION}.amazonaws.com:/ ${MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0 >> /etc/fstab
echo ${FILE_SYSTEM_ID}.efs.${REGION}.amazonaws.com:/ ${MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0 | sudo tee -a /etc/fstab

sudo mount -a -t nfs4
sudo chmod -R 755 /var/www/html

sudo yum update 
#Download package for LAMP Server
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server

#Start and Enable Apache
sudo systemctl enable httpd
sudo systemctl start httpd

#Add ec2-user to apache group
sudo usermod -a -G apache ec2-user

#Change /var/www directory ownership
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;

#Add group write permission
find /var/www -type f -exec sudo chmod 0664 {} \;


#Change directory to /var/www/html
cd /var/www/html/

#Start and Enable Mariadb
sudo systemctl enable mariadb
sudo systemctl start mariadb

#Restart Apache and php-fpm
sudo systemctl restart httpd
sudo systemctl restart php-fpm

sudo cd /var/www/html

sudo git clone https://github.com/kunleawsudemy/Pre-Clixx-Deployment.git

#Enable and start MariaDB
sudo systemctl enable mariadb
sudo systemctl start mariadb

sudo systemctl restart mariadb

cd /var/www/html/

sudo cp -r /Pre-Clixx-Deployment/* /var/www/html

#Set Permission for apache on /var/www
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www

#Restart Apache and MariaDB
sudo systemctl restart httpd
sudo systemctl restart mariadb


#Enabling jemalloc for MySQL and restart MariaDB
sudo yum install jemalloc -y

sudo systemctl restart mariadb

mysql -h wordpressinstance1.cajxzpaxghlr.us-east-1.rds.amazonaws.com -u admin -pabcd1234!!<<EOF
use wordpressdb;
UPDATE wp_options SET option_value = "My-LB-2052678953.us-east-1.elb.amazonaws.com" WHERE option_value LIKE 'http%';
EOF
