.PHONY: run
run:
	ansible-playbook playbooks/setup_mysql_replication.yml --ask-become-pass

.PHONY: venv
venv:
	python3 -m venv .venv
	. .venv/bin/activate && pip install -r requirements.txt
	@echo "\033[1;32mTo activate virtual environment run 'source .venv/bin/activate' command.\033[0m" 
	@echo "\033[1;32mTo deactivate virtual environment run 'deactivate' command.\033[0m" 
