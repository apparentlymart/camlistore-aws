#!/bin/bash

set -ex

sudo mv /tmp/camlistore-server-config.json /home/camlistore/.config/camlistore/server-config.json
sudo mv /tmp/camlistore-identity-secring.gpg /home/camlistore/.config/camlistore/identity-secring.gpg
sudo chown -R camlistore.camlistore /home/camlistore/.config/camlistore

cat >>/tmp/camlistored.service <<EOF
[Unit]
Description=camlistore server
After=network.target

[Service]
ExecStart=/usr/local/bin/camlistored
KillMode=process
Restart=on-failure
User=camlistore
Group=camlistore

[Install]
WantedBy=multi-user.target
Alias=camlistored.service
EOF

sudo mv /tmp/camlistored.service /lib/systemd/system/camlistored.service
sudo systemctl start camlistored
