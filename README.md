## Intro
Try OpenMetadata with Starburst and SingleStore

```shell
# Downloads all software
./get-archive.sh
# Build and run all
docker compose up
# Enter the metadata cli container
docker exec -it metadata bash
# Import some some metadata from Starburst
metadata ingest -c /desperate-feynman/scripts/metadata/starburst.json
```
