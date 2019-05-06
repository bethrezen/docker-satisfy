#!/bin/bash -e
docker build -t bethrezen/docker-satisfy:latest .
docker push bethrezen/docker-satisfy:latest
docker image ls bethrezen/docker-satisfy:latest

