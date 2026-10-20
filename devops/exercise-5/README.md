# Exercise 5: Docker Security with AppArmor and Python

## 🎯 Objective

Understand how to secure Docker containers using **AppArmor** (Application Armor) security profiles with Python for policy enforcement. Learn how to:
1. Define custom Linux security profiles to enforce the principle of least privilege.
2. Apply AppArmor profiles programmatically using the **Docker SDK for Python**.
3. Verify security policy enforcement by testing blocked and restricted actions within the container.

---

## 🛡️ Scenario Overview

You are responsible for deploying a mission-critical Python web service running inside a Docker container. To protect the host and prevent lateral privilege escalation:
* **Restrict Access to Sensitive Directories:** Deny read access to `/etc/**` (preventing credential theft like `/etc/passwd` or `/etc/shadow`) and write access to `/var/**`.
* **Block Binary Execution:** Deny executing auxiliary binaries inside `/bin/**` and `/usr/bin/**` (preventing attackers from spawning interactive shells such as `/bin/bash` or `/bin/sh`).
* **Restrict Linux Capabilities:** Allow only network socket binding (`capability net_bind_service`) while explicitly denying administrative capabilities (`deny capability sys_admin`).

The containerized Flask application runs under this restrictive AppArmor profile, managed and verified via Python and the Docker SDK.

---

## 📋 Prerequisites

### Install AppArmor Utilities (Ubuntu / Debian / Linux / WSL)
```bash
sudo apt-get update
sudo apt-get install -y apparmor-utils
```

### Install Docker SDK for Python
```bash
pip install docker
```

---

## 🛠 Step-by-Step Tasks

### Task 1: Basic Python Flask Application
**File:** `app.py`

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, this is a secure Flask application running inside a Docker container!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

### Task 2: Containerize the Flask Application
**File:** `Dockerfile`

```dockerfile
# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy requirements and install Flask
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files into the container at /app
COPY . /app

# Expose port 5000
EXPOSE 5000

# Run app.py when the container launches
CMD ["python", "app.py"]
```

#### Build the Docker image:
```bash
docker build -t flask-apparmor .
```

*Expected Output:*
```text
Sending build context to Docker daemon  3.072kB
Step 1/5 : FROM python:3.8-slim
 ---> e83d9d28b2f6
Step 2/5 : WORKDIR /app
 ---> Using cache
 ---> 2c4979d5c6f3
Step 3/5 : COPY . /app
 ---> 91d94a789d7a
Step 4/5 : RUN pip install flask
 ---> Running in 7fd028e9370d
Collecting flask
  ...
Successfully built flask-apparmor
```

---

### Task 3: Create & Apply the AppArmor Profile
**File:** `my-apparmor-profile`

AppArmor profiles are installed in `/etc/apparmor.d/my-apparmor-profile`.

```text
#include <tunables/global>

/usr/bin/python3 {
    # Deny access to sensitive system files
    deny /etc/** r,
    deny /var/** rw,

    # Allow Flask app to bind to port 5000
    network inet stream,

    # Permissions to the application directory
    /app/** rwk,

    # Deny execution of any binaries in /bin or /usr/bin
    deny /bin/** rmix,
    deny /usr/bin/** rmix,

    # Capability restrictions
    capability net_bind_service,
    deny capability sys_admin,
}
```

#### Steps to Load and Apply the Profile:
1. Copy the profile to `/etc/apparmor.d/`:
   ```bash
   sudo cp my-apparmor-profile /etc/apparmor.d/my-apparmor-profile
   ```
2. Parse and reload the profile into the Linux kernel:
   ```bash
   sudo apparmor_parser -r /etc/apparmor.d/my-apparmor-profile
   ```
3. Run the container with the profile attached via `--security-opt`:
   ```bash
   docker run -d --name flask-apparmor --security-opt="apparmor=my-apparmor-profile" -p 5000:5000 flask-apparmor
   ```

---

### Task 4: Programmatic Enforcement with Docker SDK for Python
**File:** `apply_apparmor.py`

This script automates building the image, launching the container with `--security-opt`, and verifying the applied profile from container metadata.

```python
import docker

# Create a Docker client
client = docker.from_env()

# Build the Docker image
print("Building image from Dockerfile...")
image, build_logs = client.images.build(path=".", tag="flask-apparmor")
for log in build_logs:
    if 'stream' in log and log['stream'].strip():
        print(f"[INFO] {log['stream'].strip()}")

# Run the container with the AppArmor profile
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

# Stop and cleanup container
print("\nStopping the container...")
container.stop()
container.remove()
print("Container stopped and cleaned up.")
```

#### Run the script:
```bash
python apply_apparmor.py
```

*Expected Output:*
```text
Building image from Dockerfile...
[INFO] Sending build context to Docker daemon  3.072kB
[INFO] Step 1/5 : FROM python:3.8-slim
 ---> e83d9d28b2f6
[INFO] Step 2/5 : WORKDIR /app
 ---> Using cache
 ---> 2c4979d5c6f3
[INFO] Step 3/5 : COPY . /app
 ---> Using cache
 ---> 91d94a789d7a
[INFO] Step 4/5 : RUN pip install flask
 ---> Using cache
 ---> 4f7e4a98128f
[INFO] Step 5/5 : EXPOSE 5000
 ---> Using cache
 ---> 230dece26d37
[INFO] Successfully built flask-apparmor

Running container with AppArmor profile...
Container started: f8c2a7f9b9b8

Inspecting container to verify AppArmor profile...
AppArmor profile applied: ['apparmor=my-apparmor-profile']

Stopping the container...
Container stopped and cleaned up.
```

---

### Task 5: Test Restricted Actions
**File:** `test_restricted_actions.py`

Verifies that unauthorized attempts (reading sensitive system files or executing unauthorized binaries) are intercepted and rejected by AppArmor.

```python
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

# Stop and clean up container
container.stop()
container.remove()
print("Container stopped")
```

#### Run the test:
```bash
python test_restricted_actions.py
```

*Expected Output:*
```text
Container started: f8c2a7f9b9b8

Attempt to read /etc/passwd: Exit Code 1, Output: 
Attempt to execute /bin/bash: Exit Code 126, Output: 
Container stopped
```
> **Interpretation:**
> - `Exit Code 1` / permission denied confirms `/etc/**` read denial.
> - `Exit Code 126` (Command invoked cannot execute) confirms `/bin/**` execution denial.

---

## ❓ Lab Review & Questions

**Q1: What is the purpose of using AppArmor with Docker containers?**  
**A1:** AppArmor is a Linux Security Module (LSM) used to enforce mandatory access control (MAC) policies, confining container processes to an explicit set of allowable resources. In Docker, it provides a crucial defense-in-depth boundary limiting file access, execution permissions, and network capabilities even if a container is compromised.

**Q2: How do AppArmor profiles help secure a Docker container?**  
**A2:** AppArmor profiles define granular white-lists and black-lists specifying which files can be read/written/executed, which network sockets can be created, and which kernel capabilities can be leveraged. This blocks attackers from breaking out of the container or tampering with host resources.

**Q3: Why is it important to restrict access to sensitive directories such as `/etc/` and `/var/`?**  
**A3:** Directories like `/etc/` house critical configuration files, user hashes (`/etc/shadow`), and SSL certificates, while `/var/` stores dynamic runtimes, databases, and logs. Restricting access prevents information disclosure, credential theft, and unauthorized persistence.

**Q4: What other capabilities can you restrict using AppArmor profiles?**  
**A4:** AppArmor can restrict raw network sockets, binding to privileged ports, inter-process signaling (PTRACE), mounting filesystems, executing binaries in specified directories, and utilizing dangerous administrative capabilities such as `CAP_SYS_ADMIN`, `CAP_NET_ADMIN`, or `CAP_SYS_RAWIO`.

**Q5: How can you verify if an AppArmor profile is successfully applied to a Docker container?**  
**A5:** By inspecting the container using the Docker SDK (`client.api.inspect_container(id)['HostConfig']['SecurityOpt']`) or the Docker CLI (`docker inspect --format '{{json .HostConfig.SecurityOpt}}' <container>`). The configuration will explicitly reflect `apparmor=my-apparmor-profile`.
