import os
import yaml
from jinja2 import Environment, FileSystemLoader

# Load configuration
def load_config():
    with open("config.yml") as f:
        config = yaml.safe_load(f)
    
    # Override with environment variables
    for key, value in os.environ.items():
        if key in config:
            config[key] = value
    return config

# Render templates
def render_templates():
    env = Environment(loader=FileSystemLoader("templates"))
    config = load_config()
    os.makedirs("rendered", exist_ok=True)
    
    for template_name in ["docker-compose.yml.j2"]:
        template = env.get_template(template_name)
        output = template.render(config)
        
        output_filename = f"rendered/{template_name.replace('.j2', '')}"
        with open(output_filename, "w") as f:
            f.write(output)
        print(f"Rendered {output_filename}")
    
    # Render individual my.cnf files for each slave
    for i in range(1, int(config.get("num_slaves", 2)) + 1):
        template = env.get_template("my.cnf.j2")
        output = template.render(slave_id=i)
        output_filename = f"rendered/my-{i}.cnf"
        with open(output_filename, "w") as f:
            f.write(output)
        print(f"Rendered {output_filename}")

if __name__ == "__main__":
    render_templates()
