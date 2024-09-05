# Docker Compose를 사용한 Spring Cloud Data Flow 로컬 머신 설치


이 저장소는 Docker Compose를 사용하여 로컬 컴퓨터에서 Spring Cloud Data Flow(SCDF)를 쉽게 설정할 수 있는 방법을 제공, 
제공된 구성 파일을 사용하면 SCDF를 실행하는 데 필요한 서비스를 빠르게 시작할 수 있으며, 
데이터 처리 파이프라인의 개발 및 테스트를 바로 시작할 수 있다.

## 사전 요구 사항

- Docker (Docker Desktop) 설치
- Docker Compose 설치
- Git (optional, for cloning the repository)
- GNU Make (http://gnuwin32.sourceforge.net/packages/make.htm) - 설치 후 환경 변수(path) 설정 필요

## 빠른 설치 진행

1. 해당 주소의 Git repository에서 clone 진행:

```bash
git clone https://github.com/chrisna2/SCDF-locally-docker.git
```

2. 인텔리J 사용시 Terminal 오픈, PowerShell이 아닌 리눅스 계열 터미널 사용. GIT을 설치한 경우 git Bash 활용 권장
   (이유는 makefile이 리눅스 기반의 명령어로 구성됨) :


3. 프로젝트 디렉터리 경로 변경
```bash
cd SCDF-locally-docker
```

4. 데이터 플로우 환경 서비스 시작, 아래 명령어 실행 :

```bash
make dataflow
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
* `skipper-server`: Spring Cloud Skipper 서버
* `app-import-stream`: 스트림 애플리케이션을 가져오기 위한 유틸리티 컨테이너
* `app-import-task`: 태스크 애플리케이션을 가져오기 위한 유틸리티 컨테이너

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

2. Skipper Server (skipper-server) :
   Skipper Server는 실제 애플리케이션 배포와 관리를 담당. Data Flow Server에서 정의된 파이프라인을 실제 클러스터에 배포하고, 애플리케이션 버전 관리 및 배포 작업을 처리.

   - 배포 관리: Skipper Server는 주로 애플리케이션의 배포를 담당. Data Flow Server에서 정의된 파이프라인을 실제로 실행하기 위해 Skipper Server가 필요.
   - 버전 관리: Skipper는 애플리케이션 버전 관리를 통해, 다양한 버전의 애플리케이션을 관리하고 배포 가능.
   - 배포의 세부 관리: 애플리케이션을 클러스터에 배포하고, 배포 상태를 모니터링하며, 롤백과 같은 작업을 처리.

- 주요 기능:
  - 애플리케이션의 배포와 관리
  - 애플리케이션 버전 관리
  - 배포 작업의 세부 관리 및 롤백


