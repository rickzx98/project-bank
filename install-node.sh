#!/bin/bash
cordaHome=/opt/corda
mkdir $cordaHome;
sh gradlew deployNodesProd
cp  -i -R -y ./java-source/build/node/$CORDA_NODE/* $cordaHome/

echo `
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
    WantedBy=multi-user.target` >  /etc/systemd/system/corda.service
echo `
    description "Corda Node - $CORDA_NODE"

    start on runlevel [2345]
    stop on runlevel [!2345]

    respawn
    setuid corda
    chdir $cordaHome
    exec java -Xmx2048m -jar $cordaHome/corda.jar` >  /etc/init/corda.conf



if [$CORDA_NODE != 'Notary']
then
    echo `
        description "Webserver for Corda Node - $CORDA_NODE"

        start on runlevel [2345]
        stop on runlevel [!2345]

        respawn
        setuid corda
        chdir $cordaHome
        exec java -jar $cordaHome/corda-webserver.jar
    `
fi 
