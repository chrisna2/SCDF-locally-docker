# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# 현재 날짜와 시간을 포맷하여 변수에 저장
LOG_FILE="./log/register_task_log_$(shell date +%Y-%m-%d_%H-%M).log"

# 새로 추가한 Docker 이미지 및 컨테이너 다운
dataflow-down:
	@echo "=== SCDF 관련 Docker 이미지를 내립니다. ==="
	docker compose -f dataflow-compose.yml \
	down

# dataflow 이미지 빌드 및 배치 job 이미지 빌드후 SCDF task 등록
.PHONY: dataflow-build-and-up
dataflow-build-and-up:
	@echo "=== Building Docker images for SCDF server and batch jobs, and starting the server ==="
	docker compose -f dataflow-compose.yml \
           down && \
	docker compose -f dataflow-compose.yml \
	       up -d --build && \
	MAKE build-all && \
	MAKE wait-for-server && \
	MAKE register-all


# 모든 배치 job 이미지 빌드
.PHONY: build-all
build-all:
	@echo "=== Building SCDF batch app start  ==="
	mvn -s ./settings.xml clean install -f ./scdf-batch/pom.xml -P local -DskipTests=true -DlocalRepository=$(MAVEN_LOCAL_REPOSITORY)
	@echo "=== Building SCDF batch app end  ==="

# SCDF 서버가 기동될 때까지 대기
.PHONY: wait-for-server
wait-for-server:
	@echo "=== Waiting for SCDF server to be ready ==="
	@until curl -s http://localhost:9393/security/info > /dev/null 2>&1; do \
		echo "Waiting for SCDF server..."; \
		sleep 5; \
	done
	@echo "=== SCDF server is now ready, check register Task ==="

# 빌드됨 배치 job 이미지 를 SCDF에 Task로 등록
.PHONY: register-all
register-all: $(addprefix register-, $(TASKS))
	@rm -f check-task-output.txt check-task.script || true; \
	[ -f register-task.script ] && rm register-task.script || true;
	@echo "=== Complete register Task for SCDF server ==="

$(addprefix register-, $(TASKS)):
	@task=$(subst register-,,$@) && \
	echo "=== Checking if Task is already registered in SCDF: $$task ===" | tee -a $(LOG_FILE) && \
	echo "app info $$task --type task" > check-task.script && \
	$(SCDF_CLI) --spring.shell.commandFile=check-task.script > check-task-output.txt 2>&1; \
	cat check-task-output.txt >> $(LOG_FILE); \
	if grep -q "Application info is not available" check-task-output.txt; then \
	    echo "Task does not exist. Registering Task: $$task" | tee -a $(LOG_FILE); \
	    echo "app register --name $$task --type task --uri file:///scdf/lib/scdf/hpf/batch/$$task/1.0-snapshot/$$task-1.0-snapshot.jar" > register-task.script; \
	    $(SCDF_CLI) --spring.shell.commandFile=register-task.script >> $(LOG_FILE) 2>&1; \
	elif grep -q "Information about task application" check-task-output.txt; then \
	    echo "Task is already registered. Skipping registration." | tee -a $(LOG_FILE); \
	    true; \
	else \
	    echo "Unexpected output. Please check SCDF server status." | tee -a $(LOG_FILE); \
	    exit 1; \
	fi;