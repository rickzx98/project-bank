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
mkdir $cordaHome;
sudo chmod -R 777 $cordaHome;
sudo systemctl stop corda;
sudo systemctl stop corda-webserver;
sudo sh gradlew deployNodesProd;
sudo cp -R ./java-source/build/nodes/$CORDA_NODE/* $cordaHome/;
sudo rm /etc/systemd/system/corda.service;
sudo rm /etc/systemd/system/corda-webserver.service;
sudo rm /opt/corda/node.conf;
sudo echo "
basedir : \"$cordaHome\"
p2pAddress : \"0.0.0.0:10002\"
rpcAddress : \"0.0.0.0:10003\"
webAddress : \"0.0.0.0:10004\"
h2port : 11000
emailAddress : \"jerico.g.de.guzman@accenture.com\"
myLegalName : \"O=$1, L=$2, C=$3\"
keyStorePassword : \"cordacadevpass\"
trustStorePassword : \"trustpass\"
devMode : false
rpcUsers=[
    {
        user=user1  
        password=test
        permissions=[
            ALL
        ]
    }
]" >> $cordaHome/node.conf;
sudo echo "
    [Unit]
    Description=Corda Node - $CORDA_NODE
    Requires=network.target

    [Service]
    Type=simple
    Group=root
    User=ubuntu
    WorkingDirectory=$cordaHome
    ExecStart=/usr/bin/java -Xmx2048m -jar $cordaHome/corda.jar
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target" >> /etc/systemd/system/corda.service;
sudo chown ubuntu:root /etc/systemd/system/corda.service;
sudo chmod 644 /etc/systemd/system/corda.service;
sudo echo "
    [Unit]
    Description=Webserver for Corda Node - $CORDA_NODE
    Requires=network.target

    [Service]
    Type=simple 
    Group=root
    User=ubuntu
    WorkingDirectory=$cordaHome
    ExecStart=/usr/bin/java -jar /opt/corda/corda-webserver.jar
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target" >> /etc/systemd/system/corda-webserver.service;
sudo chown ubuntu:root /etc/systemd/system/corda-webserver.service;
sudo chmod 644 /etc/systemd/system/corda-webserver.service;
sudo systemctl daemon-reload;
sudo systemctl enable --now corda;
sudo systemctl enable --now corda-webserver;
sudo systemctl start corda corda-webserver;