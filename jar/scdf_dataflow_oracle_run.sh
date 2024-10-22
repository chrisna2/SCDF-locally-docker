#!/bin/bash

# 환경 변수 입력
source ../config.env

# JDBC 드라이버 포함하여 SCDF 실행
java -jar "spring-cloud-dataflow-server-2.11.5.jar" \
--spring.datasource.url=jdbc:oracle:thin:@//$DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME \
--spring.datasource.username=$DATABASE_USERNAME \
--spring.datasource.password=$DATABASE_PASSWORD \
--spring.datasource.driver-class-name=$DATABASE_DRIVER_CLASS_NAME \
--spring.cloud.dataflow.features.streams-enabled=false \
--spring.flyway.enabled=false

exit 0

