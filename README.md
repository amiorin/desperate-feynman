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

## EC2
How to install docker on Ubuntu 20.04 on AWS.
```shell
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
docker run hello-world
cd desperate-feynman/
# locally
rsync --partial -av --progress . ubuntu:/home/ubuntu/desperate-feynman --exclude '*.tar.gz'
./get-archives.sh
export DOCKER_BUILDKIT=1
# build any container
docker build --target atlas .
# dump airflow database
docker exec -it mysql /usr/bin/mysqldump -u root --password=password airflow_db > airflow.sql
```