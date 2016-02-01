#! /bin/bash -l

go get -d github.com/zchee/docker-machine-driver-xhyve
cd $GOPATH/src/github.com/zchee/docker-machine-driver-xhyve
make
make install
echo "y" | docker-machine rm default
docker-machine create -d xhyve --xhyve-experimental-nfs-share --xhyve-disk-size=20000 --xhyve-cpu-count=8 --xhyve-memory-size=16384 default
eval $(docker-machine env default)

# One time only, run this to add docker to new shells: echo 'eval $(docker-machine env default 2> /dev/null)' >> ~/.profile