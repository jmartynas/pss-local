.PHONY: run
run: mysql run-backend run-frontend

.PHONY: mysql
mysql:
	cd mysql/; \
	make venv; \
	. .venv/bin/activate; \
	make run \
	deactivate \
	make clean

.PHONY: run-backend
run-backend:
	cd backend/ \
	make run \
	make clean

.PHONY: run-frontent
run-frontend:
	cd frontend/ \
	make run \
	make clean
