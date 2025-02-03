import os
import subprocess
import yaml

def load_config():
    with open("config.yml") as f:
        return yaml.safe_load(f)

def get_slaves():
    result = subprocess.run(["docker", "ps", "--format", "{{.Names}}"], capture_output=True, text=True)
    return [name for name in result.stdout.split() if "mysql-slave" in name]

def promote_slave(slave_name):
    print(f"Promoting {slave_name} to master...")
    subprocess.run(["docker", "exec", slave_name, "mysql", "-uroot", "-p$ROOT_PASSWORD", "-e", "RESET MASTER;"])
    subprocess.run(["docker", "rename", slave_name, "mysql-master"])

def main():
    config = load_config()
    slaves = get_slaves()
    
    if not slaves:
        print("No available slaves to promote.")
        return
    
    promote_slave(slaves[0])
    print(f"{slaves[0]} is now the master.")

if __name__ == "__main__":
    main()
