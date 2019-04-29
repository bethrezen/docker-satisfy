#!/bin/bash
docker build -t bethrezen/docker-satisfy:latest .
docker push bethrezen/docker-satisfy:latest
docker ls bethrezen/docker-satisfy:latest

