#!/bin/sh
set -e

# Start prometheus_wireguard_exporter in the background
/app/prometheus_wireguard_exporter -p 51822 -s true -r true -d true -n /etc/wireguard/${WG_INTERFACE} &
# Start your Node.js application
exec node server.js
