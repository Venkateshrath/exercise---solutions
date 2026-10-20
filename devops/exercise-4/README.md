# Exercise 4: Docker Networking with Multiple Containers

## 🎯 Objective
Understand Docker networking concepts, explore internal DNS name resolution, and configure a secure multi-container application using user-defined bridge networks.

---

## 🌐 Scenario Overview

A real-world microservice web stack typically isolates services on a private virtual bridge while exposing only necessary ports to the outside world:
* **Container 1 (Web API):** Python Flask REST server (`flask-api` on port `5001`)
* **Container 2 (Database):** MySQL database (`mysql:latest`)
* **Container 3 (Cache):** Redis in-memory cache (`redis:latest`)

All three containers communicate securely across an isolated Docker bridge network using automatic Docker embedded DNS service discovery.

---

## 🛠 Step-by-Step Tasks

### Task 1: Create a User-Defined Bridge Network
Create an isolated bridge network named `my-bridge-net`:
```bash
docker network create --driver bridge my-bridge-net
```
*Expected Output:*
```text
87c23b491f5994c74e497f4f4f4f4f4f4f4f4...
```

---

### Task 2: Verify the Network
List active Docker networks:
```bash
docker network ls
```
*Expected Output:*
```text
NETWORK ID     NAME            DRIVER    SCOPE
87c23b491f59   my-bridge-net   bridge    local
```

---

### Task 3: Inspect the Network
Inspect the subnet, gateway, IPAM configuration, and connected containers:
```bash
docker network inspect my-bridge-net
```
*Expected Output:*
```json
[
    {
        "Name": "my-bridge-net",
        "Id": "87c23b491f5994c74e497f4f4f4f4f4f4f4f4",
        "Created": "2023-02-20T14:30:45.421654Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Containers": {}
    }
]
```

---

### Task 4: Launch Containers

#### 1. Flask Application Code (`app.py`)
```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/about', methods=['GET'])
def about():
    return jsonify({
        "name": "Simple REST API",
        "version": "1.0",
        "description": "This is a simple REST API built with Flask."
    })

if __name__ == '__main__':
    # host='0.0.0.0' binds to all interfaces inside the container
    app.run(debug=True, host='0.0.0.0', port=5001)
```

#### 2. Dependencies (`requirements.txt`)
```text
Flask>=2.0.1
Werkzeug>=2.0.0,<3.0.0
```

#### 3. Container Specification (`Dockerfile`)
```dockerfile
FROM python:3.9-slim

# Install diagnostic utilities (ping, curl) for connectivity testing
RUN apt-get update && apt-get install -y --no-install-recommends \
    iputils-ping \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
COPY app.py .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5001
CMD ["python", "app.py"]
```

#### 4. Build the Flask Image
```bash
docker build -t flask-api .
```

#### 5. Launch All Containers in Detached Mode (`-d`)
Attach all three containers to the same bridge network (`--net=my-bridge-net`):

```bash
# 1. MySQL Container
docker run -d --name mysql --net=my-bridge-net -e MYSQL_ROOT_PASSWORD=my-secret-pw mysql:latest

# 2. Redis Container
docker run -d --name redis --net=my-bridge-net redis:latest

# 3. Flask API Container (exposing port 5001 to host)
docker run -d --name flask --net=my-bridge-net -p 5001:5001 flask-api
```

---

### Task 5: Test Inter-Container Connectivity & DNS Resolution

#### 1. Open an interactive shell inside the Flask container:
```bash
docker exec -it flask bash
```

#### 2. Ping the MySQL container by name:
```bash
ping -c 3 mysql
```
*Expected Output:*
```text
PING mysql (172.18.0.2) 56(84) bytes of data.
64 bytes from mysql (172.18.0.2): icmp_seq=1 ttl=64 time=0.078 ms
64 bytes from mysql (172.18.0.2): icmp_seq=2 ttl=64 time=0.065 ms
```

#### 3. Ping the Redis container by name:
```bash
ping -c 3 redis
```
*Expected Output:*
```text
PING redis (172.18.0.3) 56(84) bytes of data.
64 bytes from redis (172.18.0.3): icmp_seq=1 ttl=64 time=0.078 ms
64 bytes from redis (172.18.0.3): icmp_seq=2 ttl=64 time=0.062 ms
```

#### 4. Test the Flask REST API from your host browser or curl:
```bash
curl http://localhost:5001/about
```
*Expected JSON Output:*
```json
{
  "description": "This is a simple REST API built with Flask.",
  "name": "Simple REST API",
  "version": "1.0"
}
```

---

### Task 6: Cleanup

#### 1. Stop and remove the containers:
```bash
docker stop mysql redis flask && docker rm mysql redis flask
```

#### 2. Remove the bridge network:
```bash
docker network rm my-bridge-net
```

---

## 💡 Modern DevOps Alternative: Docker Compose

Instead of running separate imperative CLI commands, you can manage the entire multi-container environment declaratively with [`docker-compose.yml`](./docker-compose.yml):

```bash
# Start all 3 containers on the bridge network in detached mode
docker compose up -d

# Verify services
docker compose ps

# Clean up all containers and network with a single command
docker compose down
```

---

## ❓ Lab Review & Questions

**Q1: What is the purpose of the `--net` flag in `docker run`?**  
**A1:** The `--net` (or `--network`) flag specifies the Docker network to which the container should attach upon startup.

**Q2: How do containers communicate with each other on the same user-defined bridge network?**  
**A2:** Containers communicate using their **container names** as hostnames (resolved by Docker's built-in DNS service) or directly via their dynamically assigned private IP addresses.

**Q3: What is the difference between a bridge network and a host network?**  
**A3:** 
* **Bridge Network:** Containers run in a private, isolated network namespace connected through a software bridge (`docker0` or user-defined). Containers communicate with each other through internal IP/DNS and require port publishing (`-p`) to be accessible from the host.  
  *(Analogy: Containers are in a private conference room, speaking among themselves and opening a door only for explicitly mapped ports).*
* **Host Network:** Containers share the host's network namespace directly, bypassing Docker's network isolation.  
  *(Analogy: Containers are standing in the same common room as the host machine, listening and speaking directly on the host's network interfaces).*

**Q4: How can you expose a container's port to the host machine?**  
**A4:** Use the `-p` (or `--publish`) flag with syntax `<host-port>:<container-port>` (for example, `-p 5001:5001`).

---

## 📚 Reference
Detailed lab exercise guide: [Google Docs Lab Guide](https://docs.google.com/document/d/1ue5G-sj02E4G9NW5T5ObmsbdMl4LihUS/edit?usp=sharing&ouid=116025589128606060426&rtpof=true&sd=true)
