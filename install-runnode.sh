#!/bin/bash
export CORDA_NODE=$1;
export CORDA_LOCATION=$2;
export CORDA_CURRENCY=$3;
#export CORDA_NOTARY_IP=50.112.19.229;
#export CORDA_LONDON_IP=18.237.44.123;
#export CORDA_NEW_YORK_IP=34.217.122.211;
#export CORDA_PARIS_IP=18.237.35.221;
echo Setting up $CORDA_NODE;
cordaHome=/opt/corda;
sudo mkdir $cordaHome;
sudo systemctl stop corda;
sudo systemctl stop corda-webserver;
sudo rm -R $cordaHome/*;
sudo sh gradlew deployNodesProd;
sudo mkdir $cordaHome/$CORDA_NODE;
sudo cp ./java-source/build/nodes/runnodes $cordaHome/runnodes;
sudo cp ./java-source/build/nodes/runnodes.jar $cordaHome/runnodes.jar;
sudo cp ./java-source/build/nodes/whitelist.txt $cordaHome/whitelist.txt;
sudo cp -R ./java-source/build/nodes/$CORDA_NODE/* $cordaHome/$CORDA_NODE/;
sudo chmod -R 777 $cordaHome;
sudo rm /etc/systemd/system/corda.service;
sudo rm /etc/systemd/system/corda-webserver.service;
sudo ufw allow 10004
sudo echo "
    [Unit]
    Description=Corda Node - $CORDA_NODE
    Requires=network.target

    [Service]
    Type=simple
    Group=root
    User=ubuntu
    WorkingDirectory=$cordaHome
    ExecStart=$cordaHome/runnodes
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target" >> /etc/systemd/system/corda.service;
sudo chown ubuntu:root /etc/systemd/system/corda.service;
sudo chmod 644 /etc/systemd/system/corda.service;
sudo systemctl daemon-reload;
sudo systemctl enable --now corda;
sudo systemctl start corda;