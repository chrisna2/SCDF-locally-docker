# OpenJDK 이미지 기반으로 사용
FROM openjdk:8-jdk-alpine

# 작업 디렉터리 설정
WORKDIR /app

# 사용자가 만든 JAR 파일을 컨테이너에 복사
COPY ./jar/spring-cloud-dataflow-server-2.11.0.jar /app/spring-cloud-dataflow-server.jar

# 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "/app/spring-cloud-dataflow-server.jar"]