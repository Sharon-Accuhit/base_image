#!/bin/bash

#workdir
cd app

#install docker
docker &>/dev/null
[ $? = 0 ] && yum erase docker -y 
yum upgrade && yum update -y
yum install docker -y
systemctl start docker

# update the AWS CLI version
yum remove awscli -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &>/dev/null
unzip -u awscliv2.zip &>/dev/null
bash ./aws/install --update
rm -f awscliv2.zip
rm -r aws
hash -r
/usr/local/bin/aws --version

#set variable
source config.txt

#remove the previous images
docker images | grep "public.ecr.aws/$ALIAS/$IMAGE_REPO_NAME" &>/dev/null
if [ $? = 0 ]
then
  docker images | grep "public.ecr.aws/$ALIAS/$IMAGE_REPO_NAME" | \
  cut -d " " -f 4 > tag.txt
  cat tag.txt | while read line
  do
    docker rmi -f public.ecr.aws/$ALIAS/$IMAGE_REPO_NAME:$line
  done
  rm tag.txt
fi

#pull image
echo Logging in to Amazon ECR...
/usr/local/bin/aws ecr-public get-login-password --region $AWS_DEFAULT_REGION | \
docker login --username AWS --password-stdin \
public.ecr.aws/$ALIAS
echo Pulling the Docker image...
docker pull public.ecr.aws/$ALIAS/$IMAGE_REPO_NAME:$IMAGE_TAG

#run container
docker ps -a | grep $CONTAINER &>/dev/null
[ $? = 0 ] && docker rm -f $CONTAINER
docker run --name=$CONTAINER --restart=always -itd \
public.ecr.aws/$ALIAS/$IMAGE_REPO_NAME:$IMAGE_TAG

#show the container is successfully running
docker logs $CONTAINER 

#remove the previous images
docker images | grep "none" &>/dev/null
if [ $? = 0 ]
then
  docker images | grep "none" | \
  cut -d " " -f 40 > tag.txt
  cat tag.txt | while read line
  do
    docker rmi -f $line
  done
  rm tag.txt
fi
