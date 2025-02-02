import os
import jinja2
import subprocess
import argparse

# Load environment variables and template file
def render_template(template_path, output_path):
    env = jinja2.Environment(loader=jinja2.FileSystemLoader(os.path.dirname(template_path)))
    template = env.get_template(os.path.basename(template_path))
    
    # Render with environment variables
    rendered_content = template.render(env=os.environ)
    
    # Save the rendered file
    with open(output_path, "w") as f:
        f.write(rendered_content)
    print(f"Rendered file saved to {output_path}")

# Execute the rendered docker-compose file
def execute_compose(output_path):
    try:
        subprocess.run(["docker-compose", "-f", output_path, "up", "-d"], check=True)
        print("Docker Compose executed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error executing Docker Compose: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Render and execute Jinja template for Docker Compose")
    parser.add_argument("--render", action="store_true", help="Render the Jinja template")
    parser.add_argument("--execute", action="store_true", help="Execute the rendered Docker Compose file")
    args = parser.parse_args()
    
    template_path = "docker-compose.yml.j2"  # Path to Jinja template
    output_path = "docker-compose.yml"  # Output path for the rendered file
    
    if args.render:
        render_template(template_path, output_path)
    if args.execute:
        execute_compose(output_path)
    if not args.render and not args.execute:
        parser.print_help()
