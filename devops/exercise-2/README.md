# Exercise 2: Deploy a Flask App on Minikube using kubectl and YAML

## Objective
Learn Kubernetes basics using Minikube to set up a single-node cluster and deploy Python applications. This exercise involves containerizing and deploying a Flask web application on Kubernetes using Minikube, managing deployments, handling local images with `imagePullPolicy: Never`, and exposing services with `NodePort`.

---

## Prerequisites
- **The Illustrated Children’s Guide to Kubernetes:** [CNCF Phippy Guide](https://www.cncf.io/phippy/the-childrens-illustrated-guide-to-kubernetes/)
- **Video Walkthrough:** [YouTube Guide](https://www.youtube.com/watch?v=3I9PkvZ80BQ)
- **Install Minikube:** [Official Docs](https://minikube.sigs.k8s.io/docs/)
- Follow the Minikube installation guide for your operating system (Windows/Linux/macOS).
- **Watch:** [Origins of Kubernetes with Tim Hockin of Google](https://www.youtube.com/watch?v=xSztxKexDXM)
- **Watch:** [Keynote: A Vision for Vision (in the era of AI) - Kubernetes in Its Second Decade - Tim Hockin](https://www.youtube.com/watch?v=WqeShpaztZY)

---

## Minikube Cheat Sheet - Frequently Used Commands

```bash
# 1. Starting and Stopping Minikube
minikube start                               # Start Minikube with default settings
minikube start --kubernetes-version=v1.21.2  # Start with a specific Kubernetes version
minikube stop                                # Stop Minikube without deleting
minikube delete                              # Delete Minikube cluster

# 2. Checking Status and Information
minikube status                              # Check Minikube status
kubectl cluster-info                         # Display cluster information

# 3. Accessing Services
minikube service <service-name>              # Open specified service in browser
minikube service list                        # List URLs of all services
minikube tunnel                              # Create a network tunnel to access LoadBalancer services

# 4. Docker with Minikube
eval $(minikube docker-env)                  # Use Minikube's Docker daemon (Bash / zsh)
& minikube -p minikube docker-env --shell powershell | Invoke-Expression # PowerShell
docker build -t my-image .                   # Build image directly in Minikube
minikube image load my-image                 # Load a local image into Minikube

# 5. Debugging and Logs
minikube logs                                # View Minikube logs
minikube dashboard                           # Open the Kubernetes dashboard
minikube ssh                                 # SSH into the Minikube VM
```

---

## Step-by-Step Walkthrough

### Step 1: Start Minikube
```bash
minikube start
```

### Step 2: Create a Flask Application
**File Name:** `app.py`
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Flask on Kubernetes!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=15000)
```

### Step 3: Create a Dockerfile for Flask Application
**File Name:** `Dockerfile`
```dockerfile
FROM python:3.8-slim
WORKDIR /app
COPY . /app
RUN pip install flask
CMD ["python", "app.py"]
```

### Step 4: Build the Docker Image with Minikube’s Docker Daemon
Run the following command to display what environment variables would be set:
```bash
minikube docker-env
```
Configure your terminal session to use Minikube's Docker daemon and build the image locally:
```bash
eval $(minikube docker-env)
docker build -t flask-app:latest .
```
*(On Windows PowerShell, run: `& minikube -p minikube docker-env --shell powershell | Invoke-Expression`)*

### Step 5: Create a Kubernetes Deployment YAML File

> **Note about `imagePullPolicy: Never`:**
> Kubernetes provides three image pull policies:
> 1. **Always:** Kubernetes always pulls the image from the registry, even if it exists locally.
> 2. **IfNotPresent:** Kubernetes pulls the image only if it does not exist locally.
> 3. **Never:** Kubernetes never pulls the image from an external registry; it strictly uses the local image.
>
> Setting `imagePullPolicy: Never` ensures Kubernetes uses the local `flask-app:latest` image built inside Minikube instead of trying to pull from Docker Hub.

**File Name:** `flask-deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: flask-app:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 15000
```

### Step 6: Deploy the Application
Deploy the Flask application to Kubernetes:
```bash
kubectl apply -f flask-deployment.yaml
```

### Step 7: Check Deployment Status
Verify that the deployment was created and check replicas:
```bash
kubectl get deployments
```
*Expected Output:*
```text
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
flask-app    1/1     1            1           5s
```

### Step 8: Verify Pods Created by the Deployment
```bash
kubectl get pods -l app=flask-app
```
*Expected Output:*
```text
NAME                          READY   STATUS    RESTARTS   AGE
flask-app-3443a-213a          1/1     Running   0          5s
```

### Step 9: Describe the Deployment
Inspect deployment events, controller details, and replicas:
```bash
kubectl describe deployment flask-app
```

### Step 10: View Deployment Logs
View application logs from the running pod:
```bash
kubectl logs <pod-name>
# Or using label selector:
kubectl logs -l app=flask-app
```
*Expected Output:*
```text
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:15000
 * Running on http://10.0.0.210:15000
Press CTRL+C to quit
```

### Step 11: Check Services
Check existing cluster services:
```bash
kubectl get services
```

### Step 12: Internal vs. External Access
Attempting `curl http://127.0.0.1:15000` directly from the host fails because Minikube runs in an isolated network/VM environment and the Pod's port 15000 is not yet exposed outside the cluster.

### Step 13: Expose via Service (NodePort)
Update `flask-deployment.yaml` with the Service manifest:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: flask-app:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 15000
---
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
spec:
  selector:
    app: flask-app
  ports:
  - port: 15000
    targetPort: 15000
  type: NodePort
```

Apply the updated manifest:
```bash
kubectl apply -f flask-deployment.yaml
```

**Port Mapping Breakdown:**
- **`port` (Service Port):** Exposed by the Kubernetes Service (port 15000).
- **`targetPort` (Container Port):** Port that the Flask application listens on inside the container (port 15000).
- **Traffic Flow:** `Client Request -> Service (port 15000) -> Container (targetPort 15000) -> Flask App`

Retrieve the accessible URL in Minikube:
```bash
minikube service flask-app-service --url
```

Access the service endpoint:
```bash
curl <generated-url>
```
*Output:*
```text
Hello from Flask on Kubernetes!
```

---

## ❓ Q&A Review

- **Q1: What is the purpose of `minikube service flask-app-service --url`?**  
  **A1:** To provide the reachable URL for accessing the `flask-app-service` running in Minikube.

- **Q2: What happens when you run `minikube service flask-app-service --url`?**  
  **A2:** Minikube checks if the service is running, allocates/resolves the node routing, and outputs the accessible URL in the terminal.

- **Q3: Why is `targetPort` used in Kubernetes Service configuration?**  
  **A3:** To specify the exact port number on which the container process is listening inside the Pod.

- **Q4: What is the difference between `port` and `targetPort` in Kubernetes Service configuration?**  
  **A4:** `port` is the port exposed by the Kubernetes Service to other pods or external clients, while `targetPort` is the port inside the target container where traffic is forwarded.

- **Q5: How do you access a Flask application running in Minikube?**  
  **A5:** Use `minikube service <service-name> --url` to obtain the routed URL and open it via browser or curl.

- **Q6: Why does the terminal need to remain open when using Docker driver on Linux with Minikube?**  
  **A6:** Because the Docker driver uses a background port-forwarding process to maintain network connectivity between the host and Minikube container.

- **Q7: What is the benefit of using `--url` flag with `minikube service` command?**  
  **A7:** It outputs the URL as a clean string without launching an interactive browser session, making it ideal for scripts and curl verification.

- **Q8: What command is used to expose a service in Kubernetes?**  
  **A8:** `kubectl expose` (imperative) or `kubectl apply -f <service.yaml>` (declarative).

- **Q9: How does Minikube help in local Kubernetes testing?**  
  **A9:** It spins up a lightweight single-node Kubernetes cluster locally, allowing developers to test manifests, networking, and containers before deploying to production clusters.

- **Q10: What is the role of `kubectl` in this setup?**  
  **A10:** `kubectl` is the Kubernetes CLI used to communicate with the cluster's API server to deploy apps, inspect resources, and manage workloads.
