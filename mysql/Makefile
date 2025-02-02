TEMPLATE_PATH = docker-compose.yml.j2
OUTPUT_PATH = docker-compose.yml
PYTHON_SCRIPT = render_jinja.py
VENV_PATH = .venv

install:
	sudo apt update && sudo apt install -y python3 python3-pip
	# Create a virtual environment if it doesn't exist
	if [ ! -d "$(VENV_PATH)" ]; then python3 -m venv $(VENV_PATH); fi
	# Ensure pip is installed inside the virtual environment
	$(VENV_PATH)/bin/python -m ensurepip --upgrade
	# Upgrade pip to the latest version inside the virtual environment
	$(VENV_PATH)/bin/python -m pip install --upgrade pip
	# Install Jinja2 inside the virtual environment
	$(VENV_PATH)/bin/pip install jinja2
	# Enable and start Docker service
	sudo systemctl enable --now docker
	# Add the current user to the docker group
	sudo usermod -aG docker $(USER)
	echo "Installation complete. Please log out and back in if you added yourself to the docker group."
	echo "Jinja2 installed in virtual environment. Use 'source $(VENV_PATH)/bin/activate' to activate the environment."

render:
	$(VENV_PATH)/bin/python $(PYTHON_SCRIPT) --render

execute:
	$(VENV_PATH)/bin/python $(PYTHON_SCRIPT) --execute

run: render execute 
	$(VENV_PATH)/bin/python $(PYTHON_SCRIPT) --render && $(VENV_PATH)/bin/python $(PYTHON_SCRIPT) --execute

