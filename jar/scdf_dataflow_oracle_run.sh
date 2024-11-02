#!/bin/bash

##[참고용] 해당 파일은 docker 로 연동하지 않고 직접 jar를 실행 하는 shell script

# 환경 변수 입력
DATABASE_HOST=localhost
DATABASE_PORT=1521
DATABASE_NAME=xe
DATABASE_USERNAME=
DATABASE_PASSWORD=
DATABASE_DRIVER_CLASS_NAME=oracle.jdbc.OracleDriver


# JDBC 드라이버 포함하여 SCDF 실행
java -jar "spring-cloud-dataflow-server-2.11.0.jar" \
--spring.datasource.url=jdbc:oracle:thin:@//$DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME \
--spring.datasource.username=$DATABASE_USERNAME \
--spring.datasource.password=$DATABASE_PASSWORD \
--spring.datasource.driver-class-name=$DATABASE_DRIVER_CLASS_NAME \
--spring.cloud.dataflow.features.streams-enabled=false \
--spring.flyway.enabled=false

exit 0

