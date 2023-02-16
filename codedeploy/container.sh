#!/bin/bash

#workdir
cd app

#install docker
docker &>/dev/null
[ $? = 0 ] && yum erase docker -y 
yum upgrade && yum update -y
yum install docker -y
systemctl start docker

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
aws ecr-public get-login-password --region $AWS_DEFAULT_REGION | \
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
