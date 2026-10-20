import docker

# Create a Docker client
client = docker.from_env()

# Run the container with the AppArmor profile
container = client.containers.run(
    "flask-apparmor",
    ports={'5000/tcp': 5000},
    security_opt=["apparmor=my-apparmor-profile"],
    detach=True
)

print(f"Container started: {container.short_id}\n")

# Test restricted action 1: Reading sensitive /etc/passwd
exit_code, output = container.exec_run("cat /etc/passwd")
print(f"Attempt to read /etc/passwd: Exit Code {exit_code}, Output: {output.decode().strip()}")

# Test restricted action 2: Executing binaries in /bin/bash
exit_code, output = container.exec_run("/bin/bash")
print(f"Attempt to execute /bin/bash: Exit Code {exit_code}, Output: {output.decode().strip()}")

# Stop and remove the container
container.stop()
container.remove()
print("Container stopped")
