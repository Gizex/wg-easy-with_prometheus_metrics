#!/bin/sh
set -e

# Start prometheus_wireguard_exporter in the background
screen -d -m -S prometheus_wireguard_exporter /usr/local/bin/prometheus_wireguard_exporter -p 51822 -s -r

# Start your Node.js application
exec node server.js