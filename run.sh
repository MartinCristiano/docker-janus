#!/bin/bash

# Patch Config to enable Event Handler
#CFG_EVENT='/root/janus/etc/janus/janus.eventhandler.sampleevh.cfg'
#sed 's/enabled = no/enabled = yes/1' -i $CFG_EVENT
#echo 'backend = http://localhost:7777' >> $CFG_EVENT
CFG_JANUS='/root/janus/etc/janus/janus.cfg'
sed 's/; broadcast = yes/broadcast = yes/1' -i $CFG_JANUS
CFG_HTTPS='/root/janus/etc/janus/janus.transport.http.cfg'
sed 's/https = no/https = yes/1' -i $CFG_HTTPS
sed 's/;secure_port = 8889/secure_port = 8889/1' -i $CFG_HTTPS
CFG_WSS='/root/janus/etc/janus/janus.transport.websockets.cfg'
sed 's/wss = no/wss = yes/1' -i $CFG_WSS
sed 's/;wss_port = 8989/wss_port = 8989/1' -i $CFG_WSS

# Generate Certs
openssl req -x509 -newkey rsa:4086 \
  -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
  -keyout "/usr/share/key.pem" \
  -out "/usr/share/cert.pem" \
  -days 3650 -nodes -sha256

# Start demo server
npm install http-server -g
ln -s /usr/bin/nodejs /usr/bin/node
http-server /root/janus/share/janus/demos/ --key /usr/share/key.pem --cert /usr/share/cert.pem -d false -p 9080 -c-1 --ssl &

# Start Evapi Demo
npm install http -g
nodejs /evapi.js >> /var/log/meetecho &

# Start Janus Gateway in forever mode
CMD="/root/janus/bin/janus -L /var/log/meetecho"
until $CMD
do
    :
done

tail -f /var/log/meetecho

