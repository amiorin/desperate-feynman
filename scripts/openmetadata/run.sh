#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -xe

cat <<EOF > /opt/openmetadata/conf/openmetadata.yaml
swagger:
  resourcePackage: org.openmetadata.catalog.resources

server:
  rootPath: '/api/*'
  applicationConnectors:
    - type: http
      port: ${SERVER_PORT:-8585}
  adminConnectors:
    - type: http
      port: ${SERVER_ADMIN_PORT:-8586}

# Logging settings.
# https://logback.qos.ch/manual/layouts.html#conversionWord
logging:
  level: INFO
  loggers:
    org.openmetadata.catalog.common: DEBUG
    io.swagger: ERROR
  appenders:
    - type: file
      threshold: TRACE
      logFormat: "%level [%d{HH:mm:ss.SSS}] [%t] %logger{5} - %msg %n"
      currentLogFilename: ./logs/openmetadata.log
      archivedLogFilenamePattern: ./logs/openmetadata-%d{yyyy-MM-dd}-%i.log.gz
      archivedFileCount: 7
      timeZone: UTC
      maxFileSize: 50MB

database:
  # the name of the JDBC driver, mysql in our case
  driverClass: com.mysql.cj.jdbc.Driver
  # the username and password
  user: ${MYSQL_USER:-openmetadata_user}
  password: ${MYSQL_USER_PASSWORD:-openmetadata_password}
  # the JDBC URL; the database is called openmetadata_db
  url: jdbc:mysql://${MYSQL_HOST:-localhost}:${MYSQL_PORT:-3306}/${MYSQL_DATABASE:-openmetadata_db}?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC

migrationConfiguration:
  path: "./bootstrap/sql/mysql"

elasticsearch:
  host: ${ELASTICSEARCH_HOST:-localhost}
  port: ${ELASTICSEARCH_PORT:-9200}
  scheme: ${ELASTICSEARCH_SCHEME:-http}

eventHandlerConfiguration:
  eventHandlerClassNames:
    - "org.openmetadata.catalog.events.AuditEventHandler"
    - "org.openmetadata.catalog.events.ChangeEventHandler"

airflowConfiguration:
  apiEndpoint: http://${AIRFLOW_HOST:-localhost}:${AIRFLOW_PORT:-8080}
  username: ${AIRFLOW_USERNAME:-admin}
  password: ${AIRFLOW_PASSWORD:-admin}
  metadataApiEndpoint: http://${SERVER_HOST:-localhost}:${SERVER_PORT:-8585}/api
  authProvider: "no-auth"

slackEventPublishers:
  - name: "slack events"
    webhookUrl: "slackIncomingWebhook URL"
    openMetadataUrl: http://${SERVER_HOST:-localhost}:${SERVER_PORT:-8585}
    filters:
      - eventType: "entityCreated"
        entities:
         - "*"
      - eventType: "entityUpdated"
        entities:
         - "*"
      - eventType: "entitySoftDeleted"
        entities:
         - "*"
      - eventType: "entityDeleted"
        entities:
         - "*"

# no_encryption_at_rest is the default value, and it does what it says. Please read the manual on how
# to secure your instance of OpenMetadata with TLS and encryption at rest.
fernetConfiguration:
  fernetKey: ${FERNET_KEY:-no_encryption_at_rest}

health:
  delayedShutdownHandlerEnabled: true
  shutdownWaitPeriod: 1s
  healthCheckUrlPaths: ["/api/v1/health-check"]
  healthChecks:
    - name: UserDatabaseCheck
      critical: true
      schedule:
        checkInterval: 2500ms
        downtimeInterval: 10s
        failureAttempts: 2
        successAttempts: 1
EOF

./bootstrap/bootstrap_storage.sh migrate
./bin/openmetadata.sh start

until [ "$OPENMETADATA_PID" -eq "$OPENMETADATA_PID" ] 2> /dev/null
do
  OPENMETADATA_PID=`ps -ef  | grep -v grep | grep -i "org.openmetadata.catalog.CatalogApplication server" | awk '{print $2}'`
  sleep 1
done

exec tail --pid ${OPENMETADATA_PID} -F /opt/openmetadata/logs/openmetadata.log