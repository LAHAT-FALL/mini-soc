#!/usr/bin/env bash
sudo apt update
sudo apt install -y zeek
sudo sed -i 's/interface=.*/interface=wlp3s0/' /opt/zeek/etc/node.cfg
sudo zeekctl deploy
