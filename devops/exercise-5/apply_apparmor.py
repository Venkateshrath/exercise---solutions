import docker

# Create a Docker client
client = docker.from_env()

print("Building image from Dockerfile...")
image, build_logs = client.images.build(path=".", tag="flask-apparmor")
for log in build_logs:
    if 'stream' in log and log['stream'].strip():
        print(f"[INFO] {log['stream'].strip()}")

print("\nRunning container with AppArmor profile...")
container = client.containers.run(
    "flask-apparmor",
    ports={'5000/tcp': 5000},
    security_opt=["apparmor=my-apparmor-profile"],
    detach=True
)

print(f"Container started: {container.short_id}")

# Verify AppArmor profile applied
print("\nInspecting container to verify AppArmor profile...")
container_info = client.api.inspect_container(container.id)
apparmor_profile = container_info['HostConfig']['SecurityOpt']

print(f"AppArmor profile applied: {apparmor_profile}")

# Stop the container
print("\nStopping the container...")
container.stop()
container.remove()
print("Container stopped and cleaned up.")
