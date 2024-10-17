# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

dataflow: dataflow-down
	docker compose -f dataflow-compose.yml \
	-f broker-compose.yml \
	-f database-compose.yml \
	pull
	docker compose -f dataflow-compose.yml \
	-f broker-compose.yml \
	-f database-compose.yml \
	up -d

dataflow-down:
	docker compose -f dataflow-compose.yml \
	-f broker-compose.yml \
	-f database-compose.yml \
	down

# 새로 추가한 Docker 이미지 빌드 및 서버 업로드
dataflow-build:
	@echo "=== SCDF 관련 Docker 이미지를 빌드합니다 ==="
	docker build -t hpf-scdf-batch-app ./hpf-scdf-batch

dataflow-build-and-up: dataflow-build
	@echo "=== SCDF Docker 이미지를 빌드하고 서비스를 시작합니다 ==="
	docker compose -f dataflow-compose.yml \
	-f broker-compose.yml \
	-f database-compose.yml \
	up -d --build