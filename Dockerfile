# OmniTools for Railway: the official image, pinned by version and digest.
# Upstream: https://github.com/iib0011/omni-tools (MIT). Image: https://hub.docker.com/r/iib0011/omni-tools
FROM iib0011/omni-tools:0.7.0@sha256:85f0e052a97326396c753e39de0ef74631c0783999ccca81ebc36262903ec9fa

# Two nginx workers instead of "auto" (which counts the host's CPUs, not the service's).
RUN sed -i 's/^worker_processes .*/worker_processes  2;/' /etc/nginx/nginx.conf

# Runs from the upstream nginx entrypoint before nginx starts: writes the server
# block for $PORT, the /healthz path and optional basic auth. A failure stops the
# container with a non-zero exit code, so Railway restarts it.
COPY 40-railway.sh /docker-entrypoint.d/40-railway.sh
RUN chmod 755 /docker-entrypoint.d/40-railway.sh

ENV PORT=8080
EXPOSE 8080
STOPSIGNAL SIGQUIT
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
