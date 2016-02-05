#! /bin/bash -l
docker build -t swift-dev .
docker run -dit --name swift-dev -v $PWD/../:/var/swift --net=host swift-dev