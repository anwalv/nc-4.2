#!/bin/bash

CLIENT_IP=$SOCAT_PEERADDR

CREDENTIALS_FILE="/etc/authServer/credentials.txt"

if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "File does not exist!"
  exit 1
fi

echo "Enter authorization key for the IP $CLIENT_IP:"
read AUTH_KEY

AUTH_MATCH=$(grep -P "^$CLIENT_IP\s+$AUTH_KEY$" $CREDENTIALS_FILE)

if [ -n "$AUTH_MATCH" ]; then
  echo "Authorization successful for IP $CLIENT_IP."

  sudo iptables -D INPUT -p tcp --dport 21 -s $CLIENT_IP -j ACCEPT 2>/dev/null
  sudo iptables -D INPUT -p tcp --dport 21 -s $CLIENT_IP -j REJECT 2>/dev/null

  sudo iptables -I INPUT -p tcp --dport 21 -s $CLIENT_IP -j ACCEPT

  sudo netfilter-persistent save

  echo "IP $CLIENT_IP added to the list of allowed FTP access."
else

  echo "Incorrect authorization key for IP $CLIENT_IP."

  sudo iptables -D INPUT -p tcp --dport 21 -s $CLIENT_IP -j ACCEPT 2>/dev/null
  sudo iptables -D INPUT -p tcp --dport 21 -s $CLIENT_IP -j REJECT 2>/dev/null

  sudo iptables -A INPUT -p tcp --dport 21 -s $CLIENT_IP -j REJECT

  sudo netfilter-persistent save

  echo "IP $CLIENT_IP blocked from FTP access."
fi
