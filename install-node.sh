#!/bin/bash
export CORDA_NODE=Notary;
export CORDA_NOTARY_IP=54.190.42.1;
export CORDA_LONDON_IP=18.237.44.123;
export CORDA_NEW_YORK_IP=34.217.122.211;
export CORDA_PARIS_IP=18.237.35.221;

cordaHome=/opt/corda;
mkdir $cordaHome;
sh gradlew deployNodesProd;
cp  -i -R ./java-source/build/nodes/$CORDA_NODE/* $cordaHome/*;
echo "Setting up $CORDA_HOME";
echo "
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
echo "
    description "Corda Node - $CORDA_NODE"

    start on runlevel [2345]
    stop on runlevel [!2345]

    respawn
    setuid corda
    chdir $cordaHome
    exec java -Xmx2048m -jar $cordaHome/corda.jar" >>  /etc/init/corda.conf;
if [$CORDA_NODE != "Notary"]
then
    echo "
        description \"Webserver for Corda Node - $CORDA_NODE\"

        start on runlevel [2345]
        stop on runlevel [!2345]

        respawn
        setuid corda
        chdir $cordaHome
        exec java -jar $cordaHome/corda-webserver.jar
    " >> /etc/init/corda-webserver.conf;
fi 
