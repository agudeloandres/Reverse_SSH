#!/bin/bash
if [ -z "$SUDO_USER" ]; then
    echo "$0 must be called from sudo. Try: 'sudo ${0}'"
    exit 1
fi

SCRIPT_LOCATION="/etc/network/if-up.d/reverse_ssh_tunnel"

echo "Creating file in $SCRIPT_LOCATION"
echo "Installing openssh-server and autossh"
apt-get install openssh-server autossh
echo "Randomly creating port numbers (edit these in the file to change if you want)"

PORT_NUMBER=$[ ( $RANDOM % 10000 )  + 10000 ]
MONITORING_PORT_NUMBER=$[ ( $RANDOM % 10000 )  + 20000 ]

echo "PORT_NUMBER: ${PORT_NUMBER}"
echo "MONITORING_PORT_NUMBER: ${MONITORING_PORT_NUMBER}"
echo "Enter servername or IP address for the middleman server"
read MIDDLEMAN_SERVER
echo "Enter username to use for logging into $MIDDLEMAN_SERVER:[$SUDO_USER]"
read MIDDLEMAN_USERNAME
if [[ -z $MIDDLEMAN_USERNAME ]]; then
  MIDDLEMAN_USERNAME=$SUDO_USER
fi
echo "Checking to see if we can login using public key authentication: ssh $MIDDLEMAN_USERNAME@$MIDDLEMAN_SERVER (TODO, TO BE IMPLEMENTED!)"
su $SUDO_USER -c "ssh $MIDDLEMAN_USERNAME@$MIDDLEMAN_SERVER \"echo I am in\""

echo "Checking to see if GatewayPorts is set on $MIDDLEMAN_SERVER"
su $SUDO_USER -c "ssh $MIDDLEMAN_USERNAME@$MIDDLEMAN_SERVER \"cat /etc/ssh/sshd_config | grep 'GatewayPorts yes'\""

echo "Do you want to upload your public key to the middleman and setup public key authentication? ([y]/n)"
read COPY_KEY

if [ ! "${COPY_KEY}" = "n" ]; then
  su $SUDO_USER -c "ssh-copy-id $MIDDLEMAN_USERNAME@$MIDDLEMAN_SERVER"
fi
