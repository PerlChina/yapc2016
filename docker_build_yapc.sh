#!/bin/bash
docker build -f Dockerfile_yapc -t api6.hukaa.com:5000/hukaa_yapc:1.1 .
docker push api6.hukaa.com:5000/hukaa_yapc:1.1
