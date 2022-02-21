## Intro
Try OpenMetadata with Starburst and MySQL

```shell
# Downloads all software
./get-archives.sh
# Build and run all
docker compose up
# Enter the metadata cli container
docker exec -it metadata bash
# Import some some metadata from Starburst
metadata ingest -c /desperate-feynman/scripts/metadata/starburst.json
```

## Smoke tests
[GitHub action](https://github.com/amiorin/desperate-feynman/blob/main/.github/workflows/push.yml)

## Azure OAuth
Create a `.env` from the `.env.template`. Keep in mind that in OSX your container can reach
OpenMetadata running in Intellij with the hostname `host.docker.internal`. OAuth works with
http://localhost:9000 (no DNS and no TLS).