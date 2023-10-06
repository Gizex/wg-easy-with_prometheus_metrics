FROM docker.io/library/node:14-alpine@sha256:dc92f36e7cd917816fa2df041d4e9081453366381a00f40398d99e9392e78664 AS build_node_modules

# Copy Web UI
COPY src/ /app/
WORKDIR /app
RUN npm install
RUN npm ci --production

# Copy build result to a new image.
# This saves a lot of disk space.
FROM mindflavor/prometheus-wireguard-exporter:multi-arch-dockerfile as prometheus_wireguard_exporter
RUN ls -la /app
FROM docker.io/library/node:14-alpine@sha256:dc92f36e7cd917816fa2df041d4e9081453366381a00f40398d99e9392e78664
COPY --from=build_node_modules /app /app
COPY --from=prometheus_wireguard_exporter /usr/local/bin/prometheus_wireguard_exporter /app/
# Move node_modules one directory up, so during development
# we don't have to mount it in a volume.
# This results in much faster reloading!
#
# Also, some node_modules might be native, and
# the architecture & OS of your development machine might differ
# than what runs inside of docker.
RUN mv /app/node_modules /node_modules
COPY --from=mindflavor/prometheus-wireguard-exporter:multi-arch-dockerfile /usr/local/bin/prometheus_wireguard_exporter /usr/local/bin/
RUN ls -la /usr/local/bin/
# Enable this to run `npm run serve`
RUN npm i -g nodemon

# Install Linux packages
RUN apk add -U --no-cache \
  wireguard-tools \
  dumb-init

# Expose Ports
EXPOSE 51820/udp
EXPOSE 51821/tcp
EXPOSE 51822/tcp
RUN ls -la

# Set Environment
ENV DEBUG=Server,WireGuard

# Run Web UI
WORKDIR /app
CMD ["node", "server.js"]