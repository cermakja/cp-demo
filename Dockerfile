#
# Copyright 2020 Confluent Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG REPOSITORY
ARG CP_VERSION

# Stage 1 -- install connectors
FROM $REPOSITORY/cp-server-connect:$CP_VERSION AS install-connectors

ENV CONNECT_PLUGIN_PATH: "/usr/share/confluent-hub-components,/usr/share/java"

# Install SSE connector
RUN confluent-hub install --no-prompt cjmatta/kafka-connect-sse:1.0

# Install FromJson transformation
RUN confluent-hub install --no-prompt jcustenborder/kafka-connect-json-schema:0.2.5

# Install Elasticsearch connector
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:11.0.0

COPY connect/csid-config-provider-gcloud/confluentinc-csid-secrets-provider-gcloud-1.0.9-SNAPSHOT.zip /home/appuser/
RUN confluent-hub install --no-prompt /home/appuser/confluentinc-csid-secrets-provider-gcloud-1.0.9-SNAPSHOT.zip
RUN rm -f /home/appuser/confluentinc-csid-secrets-provider-gcloud-1.0.9-SNAPSHOT.zip


# Stage 2 -- copy jars
FROM $REPOSITORY/cp-server-connect:$CP_VERSION

COPY --from=install-connectors /usr/share/confluent-hub-components/ /usr/share/confluent-hub-components/


# to compare the jar files, you can run
# $ ls -1 ./connect/workspace/csid-secrets-providers/gcloud/target/components/packages/confluentinc-csid-secrets-provider-gcloud-1.0.9-SNAPSHOT/confluentinc-csid-secrets-provider-gcloud-1.0.9-SNAPSHOT/lib
# $ docker exec -it connect sh -c 'ls -1 /usr/share/java/confluent-hub-client'
# $ docker exec -it connect sh -c 'ls -1  /usr/share/java/confluent-security/connect/'
#
# RUN rm -f /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/google-auth-library-credentials-1.16.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/google-auth-library-oauth2-http-1.16.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/google-http-client-1.43.1.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/google-http-client-gson-1.43.1.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/grpc-googleapis-1.54.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/proto-google-common-protos-2.17.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/proto-google-iam-v1-1.12.0.jar

# RUN rm -f /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/annotations-4.1.1.4.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/api-common-2.9.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/auto-value-annotations-1.10.1.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/checker-qual-3.32.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/commons-codec-1.15.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/commons-logging-1.2.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/error_prone_annotations-2.18.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/failureaccess-1.0.1.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/gax-2.26.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/google-auth-library-credentials-1.16.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/google-auth-library-oauth2-http-1.16.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/google-http-client-1.43.1.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/google-http-client-gson-1.43.1.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/grpc-context-1.54.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/gson-2.10.1.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/httpclient-4.5.14.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/httpcore-4.4.16.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/j2objc-annotations-1.3.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/jackson-annotations-2.15.2.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/jackson-core-2.15.2.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/jackson-databind-2.15.2.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/javax.annotation-api-1.3.2.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/jsr305-3.0.2.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/opencensus-api-0.31.1.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/opencensus-contrib-http-util-0.31.1.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/proto-google-common-protos-2.17.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/proto-google-iam-v1-1.12.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/protobuf-java-3.21.12.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/protobuf-java-util-3.21.12.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/re2j-1.6.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/threetenbp-1.6.8.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/gax-httpjson-0.111.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/opencensus-proto-0.2.0.jar \
# /usr/share/confluent-hub-components/confluentinc-csid-secrets-provider-gcloud/grpc-googleapis-1.54.0.jar
