#!/usr/bin/env bash
set -e

# Setup docker with new bridge
kill "$(cat /var/run/docker.pid)"
while kill -0 "$(cat /var/run/docker.pid)" ; do sleep 1 ; done
nohup /usr/local/bin/dockerd --experimental --bip '192.168.242.1/24' --host=unix:///var/run/docker.sock --host=tcp://127.0.0.1:2375 --storage-driver=overlay2 &
timeout 15 sh -c "until docker info; do echo .; sleep 1; done"

# Setup clamav
apt-get update -y
apt-get install clamav -y
echo -e "DatabaseMirror https://pivotal-clamav-mirror.s3.amazonaws.com\nDNSDatabaseInfo disabled" > /etc/clamav/freshclam.conf
freshclam
apt-get install clamav-daemon -y
service clamav-daemon start
service clamav-daemon status

# Setup terraform and terragrunt
curl -qL -o /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"
chmod +x /usr/local/bin/terragrunt
curl -qL -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip terraform.zip -d /usr/bin/
chmod +x /usr/bin/terraform
rm -f terraform.zip

# Install python dependencies
pip install poetry coverage
make install
