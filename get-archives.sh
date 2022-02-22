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

#
# Downloads HDFS/Hive/HBase/Kafka/.. archives to a local cache directory.
# The downloaded archives will be used while building docker images that
# run these services
#


#
# source .env file to get versions to download
#
source .env


downloadIfNotPresent() {
  local dirName=$1
  local fileName=$2
  local urlBase=$3

  if [ ! -f "${dirName}/${fileName}" ]
  then
    echo "downloading ${urlBase}/${fileName}.."

    curl -L ${urlBase}/${fileName} --output ${dirName}/${fileName}
  else
    echo "file already in cache: ${fileName}"
  fi
}

downloadIfNotPresent downloads starburst-enterprise-370-e.0.tar.gz https://s3.us-east-2.amazonaws.com/software.starburstdata.net/370e/370-e.0
downloadIfNotPresent downloads trino-cli-370-e.0-executable.jar https://s3.us-east-2.amazonaws.com/software.starburstdata.net/370e/370-e.0
downloadIfNotPresent downloads trino-jdbc-370-e.0.jar https://s3.us-east-2.amazonaws.com/software.starburstdata.net/370e/370-e.0
downloadIfNotPresent downloads apache-atlas-2.1.0-sources.tar.gz https://dlcdn.apache.org/atlas/2.1.0
downloadIfNotPresent downloads apache-atlas-2.2.0-sources.tar.gz https://dlcdn.apache.org/atlas/2.2.0
