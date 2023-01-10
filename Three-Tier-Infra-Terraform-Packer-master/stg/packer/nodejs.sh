#!/bin/bash
sudo useradd -m app -s /bin/bash
sudo usermod --password $(openssl passwd -6 'app') app
echo "app  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/app
cd /home/app

#NodeJS Dependencies
sudo apt update
sudo apt install net-tools -y
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install gcc make -y
sudo apt install nodejs -y
sudo npm install pm2@latest -g
#AmazonCodeDeploy Agent
sudo apt update -y
sudo apt install ruby wget -y
cd /home/ubuntu
wget https://aws-codedeploy-ca-central-1.s3.ca-central-1.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
# # AmazonCloudWatch Agent
sudo apt update -y
sudo mkdir /tmp/cwa
cd /tmp/cwa
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip -O AmazonCloudWatchAgent.zip
sudo apt install -y unzip
sudo unzip -o AmazonCloudWatchAgent.zip
sudo ./install.sh
# sudo mkdir -p /usr/share/collectd/
# sudo touch /usr/share/collectd/types.db 
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux-ayush
# /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
systemctl status amazon-cloudwatch-agent.service
