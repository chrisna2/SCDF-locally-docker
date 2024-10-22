# Docker Compose를 사용한 Spring Cloud Data Flow 로컬 머신 설치


이 저장소는 Docker Compose를 사용하여 로컬 컴퓨터에서 Spring Cloud Data Flow(SCDF)를 쉽게 설정할 수 있는 방법을 제공, 
제공된 구성 파일을 사용하면 SCDF를 실행하는 데 필요한 서비스를 빠르게 시작할 수 있으며, 
데이터 처리 파이프라인의 개발 및 테스트를 바로 시작할 수 있다.

## 사전 요구 사항

- Docker (window, Docker Desktop) 설치
- Docker Compose 설치
- Git (optional, for cloning the repository)
- (WIMDOWS) GNU Make (http://gnuwin32.sourceforge.net/packages/make.htm) - 설치 후 환경 변수(path) 설정 필요

## 빠른 설치 진행

1. 해당 주소의 Git repository에서 clone 진행:

```bash
git clone https://github.com/chrisna2/SCDF-locally-docker.git
```

    2024-10-17 연구 진행 상황 업데이트>
    1) SCDF 사용의 목적을 Batch 모니터링 및 Task관리를 위해 사용하기 위해 선택과 집중
        - skipper-compose.yml, local-compose.yml, broker-compose.yml, database-compose.yml 삭제 
        - dataflow-compose.yml, Makefile 수정 
        - 배치 job을 구성할 scdf-batch 프로젝트 생성 (해당 소스는 git에 올리지 않음.) 

2. 인텔리J 사용시 Terminal 오픈, PowerShell이 아닌 리눅스 계열 터미널 사용. GIT을 설치한 경우 git Bash 활용 권장
   (이유는 makefile이 리눅스 기반의 명령어로 구성됨) 


3. 프로젝트 디렉터리 경로 확인
```bash
cd SCDF-locally-docker
```

4. docker-desktop 실행 확인

5. 초기 설치 시 (또는 배치 수정 시) 아래 명령어 실행 :

```bash
make dataflow-build-and-up
```

5. 서비스가 시작될 때까지 기다린 후, SCDF 대시보드에 접속 http://localhost:9393/dashboard.

6. 데이터 플로우 환경 서비스 종료, 아래 명령어 실행 :

```bash
make dataflow-down
```

## 설정

환경 변수를 config.env 파일과 Docker Compose 파일에서 수정하여 설정을 사용자 정의할 수 있다. 
예컨데 , DATAFLOW_VERSION 및 SKIPPER_VERSION 변수를 업데이트하여 SCDF와 Skipper 버전을 변경할 수 있다.

## 서비스

이 설정에는 다음 서비스들이 포함:

* `dataflow-server`: Spring Cloud Data Flow 서버

> 2024-10-17 연구 진행 상황 업데이트
>
> →  아래 서버는 현재 연구 과제의 목적과 거리가 있어 연구 진행에서 제외
>* `skipper-server`: Spring Cloud Skipper 서버
>* `app-import-stream`: Stream 애플리케이션을 가져오기 위한 유틸리티 컨테이너
>* `app-import-task`: Task 애플리케이션을 가져오기 위한 유틸리티 컨테이너

## SCDF 서버의 구성

1. Data Flow Server (dataflow-server) :
   Data Flow Server는 애플리케이션 및 데이터 파이프라인을 정의하고 관리하는 역할을 담당. 사용자와의 상호작용을 위한 대시보드와 API를 제공하며, 파이프라인과 애플리케이션의 상태를 모니터링.

   - 어플리케이션 관리: Data Flow Server는 주로 사용자 인터페이스와 REST API를 통해 파이프라인과 애플리케이션을 관리. 여기서 파이프라인을 정의하고, 이를 배포 및 모니터링함.
   - 파이프라인 정의: 사용자 또는 개발자는 Data Flow Server를 통해 스트림 애플리케이션(데이터 처리 애플리케이션)과 작업 애플리케이션(배치 처리 애플리케이션)을 정의함.
   - 애플리케이션 등록: 애플리케이션이 Data Flow Server에 등록되어야 하며, 이를 통해 실행할 스트림과 작업을 구성할 수 있음.
   - 대시보드와 모니터링: 웹 대시보드와 API를 통해 파이프라인 상태를 모니터링하고, 데이터 흐름을 시각적으로 관리함.


- 주요 기능:
  - 사용자 인터페이스 제공
  - REST API를 통한 애플리케이션 관리 및 배포
  - 데이터 파이프라인 구성 및 관리
  - ##### 배치 서비스에 진행 상황 모니터링 및 작업 제어 (본 연구과제의 목적)

> 2024-10-17 연구 진행 상황 업데이트
> 
> →  아래 서버는 현재 연구 과제의 목적과 거리가 있어 연구 진행에서 제외
> 2. Skipper Server (skipper-server) :
>  Skipper Server는 실제 애플리케이션 배포와 관리를 담당. Data Flow Server에서 정의된 파이프라인을 실제 클러스터에 배포하고, 애플리케이션 버전 관리 및 배포 작업을 처리.
>
>  - 배포 관리: Skipper Server는 주로 애플리케이션의 배포를 담당. Data Flow Server에서 정의된 파이프라인을 실제로 실행하기 위해 Skipper Server가 필요.
>  - 버전 관리: Skipper는 애플리케이션 버전 관리를 통해, 다양한 버전의 애플리케이션을 관리하고 배포 가능.
>  - 배포의 세부 관리: 애플리케이션을 클러스터에 배포하고, 배포 상태를 모니터링하며, 롤백과 같은 작업을 처리.
>
>- 주요 기능:
>  - 애플리케이션의 배포와 관리
>  - 애플리케이션 버전 관리
>  - 배포 작업의 세부 관리 및 롤백


## 이슈1) SCDF 서버, Spring batch 연동
- 배치 개발 구조 변경 필요
- 각각의 Task를 등록 하기 위해서는 현재 배치 Job은 독립된 jar 이거나, image가 되어 컨테이너화 되어야 한다.

## 이슈2) SCDF Dataflow 서버 오라클 연동
- 2024-10-14 ~ 2024-10-22일 까지 삽질의 기록
  - springcloud/spring-cloud-dataflow-server:2.11.0-SNAPSHOT 이미지 안됨 (아래는 마지막 시도 흔적)
    - ```dockerfile
        version: '3'
        
        services:
        dataflow-server:
        image: springcloud/spring-cloud-dataflow-server:${DATAFLOW_VERSION:-2.10.2-SNAPSHOT}
        container_name: dataflow-server
        ports:
        - "9393:9393"
        environment:
          - LANG=ko_KR.utf8
          - LC_ALL=ko_KR.utf8
          - JDK_JAVA_OPTIONS=-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -Dloader.path=/scdf/lib
          - SPRING_CLOUD_DATAFLOW_FEATURES_STREAMS_ENABLED=false  # 스트림 비활성화
          - SPRING_FLYWAY_ENABLED=false  # 스트림 비활성화
          - SPRING_DATASOURCE_URL=jdbc:oracle:thin:@//${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}
          - SPRING_DATASOURCE_USERNAME=${DATABASE_USERNAME}
          - SPRING_DATASOURCE_PASSWORD=${DATABASE_PASSWORD}
          - SPRING_DATASOURCE_DRIVER_CLASS_NAME=${DATABASE_DRIVER_CLASS_NAME}
          restart: always
          volumes:
          - ./jar:/scdf/lib
          platform: linux/amd64
        ```
    - spring-cloud-dataflow-server-2.11.5.jar 형태로 실행 해보려 했으나 안됨 (아래는 마지막 시도 흔적)
    - ```shell
        # JDBC 드라이버 포함하여 SCDF 실행
        java -cp "spring-cloud-dataflow-server-2.11.5.jar:ojdbc8.jar" \
        org.springframework.boot.loader.PropertiesLauncher \
        --spring.datasource.url=jdbc:oracle:thin:@//$DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME \
        --spring.datasource.username=$DATABASE_USERNAME \
        --spring.datasource.password=$DATABASE_PASSWORD \
        --spring.datasource.driver-class-name=$DATABASE_DRIVER_CLASS_NAME \
        --spring.cloud.dataflow.features.streams-enabled=false \
        --spring.flyway.enabled=false
        
        exit 0
      ```
    - 둘다 공통적으로 spring-cloud-dataflow-server-2.11.5.jar 빌드시 oracle jdbc 에 대한 dependency를 걸어 주지 않으면 
      서버 실행시 드라이버가 연결이 안됨 
    - planb 1. 오라클을 버리고 postgres로 갈아탄다.
    - planb 2. 내가 직겁 spring-cloud-dataflow-server-2.11.5.jar를 빌드한다.
    - planb 2 선택함, 이미 구성된 DB가 오라클로 있는 상황에서 결국 직접 빌드하는 수 밖에 없음.

### planb 2 내가 직겁 spring-cloud-dataflow-server-2.11.5.jar를 빌드.

1. git clone 
```shell
  git clone -b v2.11.0 https://github.com/spring-cloud/spring-cloud-dataflow.git
  git clone https://github.com/spring-cloud/spring-cloud-dataflow-ui.git
```
1개는 dataflow 서버이고, 다른 한개는 SCDF 대시보드 UI 임

2. spring-cloud-dataflow 프로젝트를 열고 터미널에 아래 명령어 실행 
```shell
./mvnw -s .settings.xml clean package -Plocal-dev-oracle
```
