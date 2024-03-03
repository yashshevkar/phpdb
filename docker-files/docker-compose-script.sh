sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo DOCKER_IMAGE=yshevkar/phprepo:v1$BUILD_NUMBER docker-compose -f /home/ec2-user/docker-files/docker-compose.yml up -d