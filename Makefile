# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# 전역변수
SCDF_CLI = dataflow                          # SCDF CLI 명령어
TASKS = hpf-download-job hpf-upld-mng-job     # batch jobs 목록, 계속 추가 가능 cf 공백 구분자

# 새로 추가한 Docker 이미지 및 컨테이너 다운
dataflow-down:
	@echo "=== SCDF 관련 Docker 이미지를 내립니다. ==="
	docker compose -f dataflow-compose.yml \
	down

# dataflow 이미지 빌드 및 배치 job 이미지 빌드후 SCDF task 등록
.PHONY: dataflow-build-and-up
dataflow-build-and-up:
	@echo "=== Building Docker images for SCDF server and batch jobs, and starting the server ==="
	# Build and run the SCDF server Docker image
	docker compose -f dataflow-compose.yml \
           down && \
	docker compose -f dataflow-compose.yml \
	       up -d --build && \
	MAKE build-all
	#&& \
	#MAKE register-all

# 모든 배치 job 이미지 빌드
.PHONY: build-all
build-all: $(addprefix build-, $(TASKS))

$(addprefix build-, $(TASKS)):
	@task=$(subst build-,,$@) && \
	path=./scdf-batch/$$task && \
	echo "=== Building Docker image locally for: $$task ===" && \
	docker build -t $$task:latest $$path

# 빌드됨 배치 job 이미지 를 SCDF에 Task로 등록 하기 위해 SCDF cli 기동
#.PHONY: run-scdf-shell
#run-scdf-shell:
#	@echo "=== run SCDF shell start ==="
#	java -jar ./standalone/spring-cloud-dataflow-shell-2.11.5.jar
#	@echo "=== run SCDF shell end ==="

# 빌드됨 배치 job 이미지 를 SCDF에 Task로 등록
.PHONY: register-all
register-all: $(addprefix register-, $(TASKS))

$(addprefix register-, $(TASKS)):
	@task=$(subst register-,,$@) && \
	echo "=== Registering Task in SCDF: $$task ===" && \
	$(SCDF_CLI) app register --name $$task-task --type task --uri docker:$$task:latest
