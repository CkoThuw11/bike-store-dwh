# Bike Store DWH - common commands. Run `make help` to list them.

SHELL := /bin/bash
AIRFLOW := docker compose exec -T airflow-scheduler airflow

.PHONY: help up run schedule status stop down clean

help:  ## List the available commands
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-9s %s\n", $$1, $$2}'

up:  ## Build the images and start all services
	docker compose up -d --build

run: up  ## Start everything and run the daily pipeline once (first load)
	@echo "Waiting for Airflow to load the DAGs..."
	@until $(AIRFLOW) dags list 2>/dev/null | grep -q bike_store_daily; do sleep 5; done
	$(AIRFLOW) dags unpause bike_store_daily
	$(AIRFLOW) dags trigger bike_store_daily
	@echo ""
	@echo "Pipeline started. Airflow:  http://localhost:8080  (admin / admin)"
	@echo "                 Metabase: http://localhost:3000"
	@echo "After the first run is green: make schedule"

schedule:  ## Turn on the weekly full reload (run after the first daily load succeeded)
	$(AIRFLOW) dags unpause bike_store_weekly_full_reload

status:  ## Show containers and the latest daily runs
	docker compose ps -a
	-$(AIRFLOW) dags list-runs bike_store_daily 2>/dev/null | head -n 8

stop:  ## Stop all containers (keeps containers and data; resume with make up)
	docker compose stop

down:  ## Remove all containers (keeps data volumes)
	docker compose down --remove-orphans

clean:  ## Remove all containers AND all data (warehouse, Metabase dashboards, Airflow history)
	@read -p "This deletes ALL data, incl. Metabase dashboards. Type 'yes' to continue: " answer; \
	[ "$$answer" = "yes" ] || { echo "Aborted."; exit 1; }
	docker compose down -v --remove-orphans
