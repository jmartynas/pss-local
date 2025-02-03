import os
import jinja2

# Function to render Jinja templates
def render_template(template_path, output_filename, context):
    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(searchpath="./"),  # Assuming templates are in the same directory
    )
    template = env.get_template(template_path)
    rendered_content = template.render(context)
    
    # Write the rendered content to the output file
    with open(output_filename, 'w') as output_file:
        output_file.write(rendered_content)

# Define context with environment variables passed directly
context = {
    "MYSQL_ROOT_PASSWORD": os.getenv("MYSQL_ROOT_PASSWORD", "pass"),
    "MYSQL_REPLICATION_USER": os.getenv("MYSQL_REPLICATION_USER", "repl"),
    "MYSQL_REPLICATION_PASSWORD": os.getenv("MYSQL_REPLICATION_PASSWORD", "slave"),
    "SLAVE_COUNT": 2,
    "SLAVE_NAME": "mysql",
    "MASTER_NAME": "mysql_master",
    "COMPOSE_FILE": "docker-compose.yml",
    "MYSQL_DATABASE": "my_database"
}

# Render docker-compose.yml and build.sh as usual
render_template('docker-compose.yml.j2', 'docker-compose.yml', context)
render_template('build.sh.j2', 'build.sh', context)

# Now render slave.cnf for each slave
for i in range(1, context["SLAVE_COUNT"] + 1):
    slave_context = context.copy()  # Copy the base context
    slave_context["slave_id"] = i  # Set slave-specific ID
    output_filename = f"config/slave_{i}.cnf"  # Dynamic file name for each slave
    render_template('config/slave.cnf.j2', output_filename, slave_context)

