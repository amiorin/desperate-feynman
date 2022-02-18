FROM ubuntu:latest AS jdk
RUN apt update
RUN DEBIAN_FRONTEND="noninteractive"  apt install -y \
    gnupg \
    curl
RUN apt-key adv \
  --keyserver hkp://keyserver.ubuntu.com:80 \
  --recv-keys 0xB1998361219BD9C9
RUN curl -O https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb && \
    apt-get install /zulu-repo_1.0.0-3_all.deb && \
    rm /zulu-repo_1.0.0-3_all.deb
RUN apt update
RUN DEBIAN_FRONTEND="noninteractive"  apt install -y \
    zulu11-jdk-headless

FROM jdk AS builder
RUN DEBIAN_FRONTEND="noninteractive"  apt install -y \
    maven \
    git
RUN git clone --depth 1 --single-branch --branch desperate-feynman https://github.com/amiorin/OpenMetadata
WORKDIR /OpenMetadata
RUN --mount=type=cache,target=/root/.m2 mvn clean package -B -DskipTests

FROM jdk AS openmetadata
COPY --from=builder /OpenMetadata/openmetadata-dist/target/openmetadata-0.9.0-SNAPSHOT.tar.gz .
WORKDIR /opt/openmetadata
RUN tar zxf /openmetadata-0.9.0-SNAPSHOT.tar.gz --strip 1
RUN rm /openmetadata-0.9.0-SNAPSHOT.tar.gz

FROM jdk AS starburst
COPY downloads/starburst-enterprise-370-e.0.tar.gz /
WORKDIR /opt/starburst
RUN tar zxf /starburst-enterprise-370-e.0.tar.gz --strip 1
RUN rm /starburst-enterprise-370-e.0.tar.gz