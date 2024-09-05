# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

local: local-down
	docker compose -f local-compose.yml up -d --build

local-down:
	docker compose -f local-compose.yml down

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
