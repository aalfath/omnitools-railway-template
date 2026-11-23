# Changelog

## 0.7.0 (2026-11-23)

- First release of the Railway template: OmniTools 0.7.0, official image pinned by version and digest (`iib0011/omni-tools:0.7.0@sha256:85f0e052…ec9fa`).
- nginx listens on `PORT` (default 8080, IPv4 and IPv6), with an open `/healthz` health path, gzip, and cache headers for hashed assets.
- nginx runs 2 worker processes, so it fits Railway's 0.5 GB plans.
- Optional HTTP basic auth with `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` (both needed; one alone stops the deploy with an error).
