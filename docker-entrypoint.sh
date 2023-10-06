#!/bin/sh
set -e

# Start prometheus_wireguard_exporter in the background
/app -p 51822 -s true -r true -d true &
# Start your Node.js application
exec node server.js
