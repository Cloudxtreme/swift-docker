#! /bin/bash -l
docker build -t swift-dev .
docker run -dit --name swift-dev -v $(PWD)/../:/var/swift swift-dev