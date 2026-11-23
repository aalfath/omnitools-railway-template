[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/omnitools-2?utm_medium=integration&utm_source=button&utm_campaign=omnitools)

# OmniTools on Railway

A one-click Railway template for [OmniTools](https://github.com/iib0011/omni-tools) (MIT), a self-hosted collection of everyday tools for images, video, PDFs, text, lists, JSON, CSV, numbers and dates. Every file is processed in the visitor's browser: nothing is uploaded to the server.

**Version:** OmniTools `0.7.0`, official image `iib0011/omni-tools:0.7.0@sha256:85f0e052a97326396c753e39de0ef74631c0783999ccca81ebc36262903ec9fa` (pinned by version and digest in the [`Dockerfile`](Dockerfile)).

## What it deploys

One service, **OmniTools**, built from this repo's `Dockerfile`:

- the official OmniTools image (nginx serving the built web app);
- a small start step, [`40-railway.sh`](40-railway.sh), that makes nginx listen on Railway's `PORT` (IPv4 and IPv6), adds an open health path `/healthz`, turns on gzip and long cache headers for the hashed assets, and switches on optional HTTP basic auth;
- nginx limited to 2 worker processes, so it fits Railway's smallest plan (it uses about 10 MB of RAM).

There is no database and no volume: OmniTools keeps no data on the server. Files you open in a tool stay in your browser.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `8080` | Port nginx listens on; the public domain points at it. |

Nothing to fill in at deploy time. The public URL works as soon as the deploy is healthy.

**Optional login.** OmniTools has no accounts. To put the whole site behind a password, add both `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` to the service's variables and redeploy. The password is hashed (SHA-512 crypt) at start; `/healthz` stays open for Railway's health check. Setting only one of the two stops the deploy with an error, so a half-set login never leaves the site open by mistake.

## After you deploy

Open the service's public URL (Settings → Networking) and pick a tool. To use your own domain, add it under Settings → Networking → Custom Domain.

## Updates

This template builds from this GitHub repo. When a new OmniTools release is out, we bump the pinned image here and add an entry to [`CHANGELOG.md`](CHANGELOG.md). Railway then shows an "update available" notice on your project, and you choose when to apply it. Since there is no server-side data, an update can't lose anything.

## Running it elsewhere

```sh
docker build -t omnitools .
docker run --rm -p 8080:8080 omnitools
```

Upstream self-hosting docs: <https://github.com/iib0011/omni-tools#self-hostrun>.
