# Variables
RENDERED_DIR=rendered
TEMPLATES_DIR=templates CONFIG_FILE=config.yml
DEFAULT_NUM_SLAVES=3
MYSQL_DATA=mysql_data

.PHONY: install
install:
	@echo "Installing required software..."
	.venv/bin/pip3 install jinja2 pyyaml docker-compose

.PHONY: render
render:
	@echo "Rendering Jinja templates..."
	mkdir -p $(RENDERED_DIR)
	.venv/bin/python3 render.py

.PHONY: up
up: render
	mkdir -p mysql_data/master mysql_data/slave-1 mysql_data/slave-2 mysql_data/slave-3
	docker-compose -f $(RENDERED_DIR)/docker-compose.yml up -d --scale mysql-slave=$(DEFAULT_NUM_SLAVES)

.PHONY: promote
promote:
	@echo "Promoting a slave to master..."
	.venv/bin/python3 promote.py

.PHONY: down
down:
	docker-compose -f $(RENDERED_DIR)/docker-compose.yml down

.PHONY: cleanup
cleanup:
	@echo "Cleaning up generated files..."
	sudo rm -rf $(MYSQL_DATA) $(RENDERED_DIR)/*
