FROM docker.io/library/node:14-alpine@sha256:dc92f36e7cd917816fa2df041d4e9081453366381a00f40398d99e9392e78664 AS build_node_modules

# Copy Web UI
COPY src/ /app/
WORKDIR /app
RUN npm ci --production


FROM docker.io/library/node:14-alpine@sha256:dc92f36e7cd917816fa2df041d4e9081453366381a00f40398d99e9392e78664
COPY --from=build_node_modules /app /app

RUN mv /app/node_modules /node_modules
COPY --from=mindflavor/prometheus-wireguard-exporter:3.6.6 /usr/local/bin/prometheus_wireguard_exporter /usr/local/bin/
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
# Enable this to run `npm run serve`
RUN npm i -g nodemon

# Install Linux packages
RUN apk add -U --no-cache \
  wireguard-tools \
  dumb-init \
  screen

# Expose Ports
EXPOSE 51820/udp
EXPOSE 51821/tcp
EXPOSE 51822/tcp

# Set Environment
ENV DEBUG=Server,WireGuard
# Run Web UI
WORKDIR /app
RUN /usr/local/bin/prometheus_wireguard_exporter -p 51822 -s true -r true -d true &
CMD ["node", "server.js"]