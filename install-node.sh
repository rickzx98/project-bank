#!/bin/bash
export CORDA_NODE=London;
export CORDA_NOTARY_IP=54.190.42.1;
#export CORDA_LONDON_IP=18.237.44.123;
export CORDA_LONDON=localhost;
export CORDA_NEW_YORK_IP=34.217.122.211;
export CORDA_PARIS_IP=18.237.35.221;
echo Setting up $CORDA_NODE;
cordaHome=/opt/corda;
mkdir $cordaHome;
sudo sh gradlew deployNodesProd;
sudo cp -R ./java-source/build/nodes/$CORDA_NODE/* $cordaHome/;
sudo rm /etc/systemd/system/corda.service;
sudo rm /etc/init/corda.conf;
sudo echo "
    [Unit]
    Description=Corda Node - $CORD_NODE
    Requires=network.target

    [Service]
    Type=simple
    User=corda
    WorkingDirectory=$cordaHome
    ExecStart=/usr/bin/java -Xmx2048m -jar $cordaHome/corda.jar
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target" >> /etc/systemd/system/corda.service;
sudo chown ubuntu:root /etc/systemd/system/corda.service;
sudo chmod 644 /etc/systemd/system/corda.service;
sudo echo "
    [Unit]
    Description=Webserver for Corda Node - Bank of Breakfast Tea
    Requires=network.target

    [Service]
    Type=simple
    User=corda
    WorkingDirectory=/opt/corda
    ExecStart=/usr/bin/java -jar /opt/corda/corda-webserver.jar
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target" >> /etc/systemd/system/corda-webserver.service;
sudo chown ubuntu:root /etc/systemd/system/corda-webserver.service;
sudo chmod 644 /etc/systemd/system/corda-webserver.service;
sudo systemctl daemon-reload;
sudo systemctl enable --now corda;
sudo systemctl enable --now corda-webserver;