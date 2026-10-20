# Exercise 3: Scaling Flask App on Single Node using ReplicaSets

## 🛒 Real-Life Tech Use Case: E-Commerce Flash Sale

During a high-stakes flash sale on an e-commerce platform (such as **Flipkart's Big Billion Days** or **Amazon Prime Day**):
- A simple Flask service may normally handle **100 requests per minute**.
- Suddenly, at the launch moment, traffic spikes violently to **10,000+ requests per minute**.
- If the application runs on a single Pod, it will be overwhelmed, exhaust its CPU/memory limits, and crash under the load, causing severe revenue loss and downtime.
- Using Kubernetes **ReplicaSets**, the system can scale out horizontally to 5, 10, or 20 identical Pods running the same application, seamlessly distributing incoming checkout requests among them.
- Once the flash sale concludes and traffic normalizes, Kubernetes can scale the workload back down to release compute resources and minimize infrastructure costs.

---

## 🎯 Objectives
- Understand the relationship between **ReplicaSets** and **Pods**.
- Deploy and scale a containerized Python Flask web application.
- Observe pod distribution, self-healing, and traffic routing across pods on a single Kubernetes node.

---

## 💡 Key Observations & Learnings

1. **Pod Distribution:** Each Pod functions as an identical worker. Scaling out means creating identical clones of the application container.
2. **Resiliency & Self-Healing:** If an active Pod crashes or is terminated (`kubectl delete pod`), the ReplicaSet controller detects the discrepancy between *desired* and *actual* states and automatically provisions a replacement Pod.
3. **Efficiency:** Instead of permanently paying for over-provisioned servers, teams provision Pods dynamically when demand surges and de-provision them during off-peak hours.
4. **Real-World Microservice Scalability:** This mechanism forms the foundation of how hyperscale systems like Netflix, YouTube, and Swiggy autoscale workloads to handle peak user concurrency.

---

## 🛠 Application Architecture & Endpoints

**File:** `app.py` / `ex3-flash-sale.py`

| Endpoint | HTTP Method | Description |
|:---|:---:|:---|
| `/` | `GET` | Welcomes users to the Big Sale and identifies the serving Pod hostname and timestamp. |
| `/buy` | `GET` | Simulates a flash sale checkout order. Selects an item randomly, accepts optional `?user=...` query param, and returns `served_by_pod` to verify load distribution. |
| `/health` | `GET` | Health endpoint queried by Kubernetes **Readiness** and **Liveness** probes. |

```python
from flask import Flask, request
import socket
import time
import random

app = Flask(__name__)

@app.get("/")
def homepage():
    return {
        "message": "Welcome to Big Sale!",
        "pod": socket.gethostname(),
        "ts": time.time()
    }

@app.get("/buy")
def buy():
    item = random.choice(["Smartphone", "Shoes", "Headphones", "Laptop"])
    user = request.args.get("user", f"user{random.randint(1, 1000)}")
    return {
        "status": "success",
        "item": item,
        "user": user,
        "served_by_pod": socket.gethostname(),
        "time": time.strftime("%H:%M:%S")
    }

@app.get("/health")
def health():
    return {"status": "healthy", "pod": socket.gethostname()}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

## 📦 Containerization (`Dockerfile`)

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app", "--workers", "1", "--threads", "2"]
```

---

## 🚀 Step-by-Step Walkthrough

### Step 1: Clean Up Previous Minikube Cluster
If an existing cluster is running, stop and delete it before starting a fresh single-node cluster:
```bash
minikube stop
minikube delete
```

### Step 2: Start Minikube with a Single Node
```bash
minikube start --nodes=1
```
Verify the cluster node status:
```bash
kubectl get nodes
```
*Expected Output:*
```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   42s   v1.31.0
```

### Step 3: Define the ReplicaSet Manifest (`flashsale-replicaset.yaml`)

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: flashsale-rs
  labels:
    app: flashsale
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flashsale
  template:
    metadata:
      labels:
        app: flashsale
    spec:
      containers:
      - name: flashsale-container
        image: flashsale:1.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5000
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 2
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 10
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: flashsale-svc
  labels:
    app: flashsale
spec:
  type: ClusterIP
  selector:
    app: flashsale
  ports:
  - name: http
    port: 80
    targetPort: 5000
```

### Step 4: Build Image inside Minikube's Docker Daemon
Configure your shell to use Minikube's internal Docker daemon:

- **Linux / macOS / WSL:**
  ```bash
  eval $(minikube docker-env)
  docker build -t flashsale:1.0 .
  ```

- **Windows PowerShell:**
  ```powershell
  & minikube -p minikube docker-env --shell powershell | Invoke-Expression
  docker build -t flashsale:1.0 .
  ```

### Step 5: Apply the ReplicaSet and Service Configuration
```bash
kubectl apply -f flashsale-replicaset.yaml
```
*Output:*
```text
replicaset.apps/flashsale-rs created
service/flashsale-svc created
```

### Step 6: Verify the Pods & ReplicaSet Status
```bash
kubectl get pods -l app=flashsale
```
*Expected Output:*
```text
NAME                 READY   STATUS    RESTARTS   AGE
flashsale-rs-8gbfp   1/1     Running   0          3m35s
flashsale-rs-f4gsl   1/1     Running   0          3m35s
flashsale-rs-nb5kl   1/1     Running   0          3m35s
```

Check the ReplicaSet state:
```bash
kubectl get rs flashsale-rs
```
*Expected Output:*
```text
NAME           DESIRED   CURRENT   READY   AGE
flashsale-rs   3         3         3       40s
```

### Step 7: Scale the ReplicaSet to 5 Replicas (Traffic Surge)
Simulate scaling out to absorb flash sale peak load:
```bash
kubectl scale rs flashsale-rs --replicas=5
```
*Output:*
```text
replicaset.apps/flashsale-rs scaled
```

### Step 8: Verify the Updated ReplicaSet
```bash
kubectl get rs flashsale-rs
```
*Expected Output:*
```text
NAME           DESIRED   CURRENT   READY   AGE
flashsale-rs   5         5         5       7m38s
```

### Step 9: Verify the 5 Running Pods
```bash
kubectl get pods -l app=flashsale
```
*Expected Output:*
```text
NAME                 READY   STATUS    RESTARTS   AGE
flashsale-rs-4nr6q   1/1     Running   0          7m55s
flashsale-rs-84v7x   1/1     Running   0          7m55s
flashsale-rs-nsmlx   1/1     Running   0          32s
flashsale-rs-rbwr4   1/1     Running   0          7m55s
flashsale-rs-wfbb4   1/1     Running   0          32s
```

### Step 10: Test Pod Self-Healing (Delete One Pod)
Simulate a pod failure by deleting one pod:
```bash
kubectl delete pod flashsale-rs-84v7x
```
*Output:*
```text
pod "flashsale-rs-84v7x" deleted
```

### Step 11: Verify Self-Healing & Pod Distribution
Immediately check the Pods:
```bash
kubectl get pods -l app=flashsale
```
Notice that Kubernetes immediately created a brand-new Pod (e.g. `flashsale-rs-hqtm7`) to maintain the desired count of 5 replicas.

Inspect the node placement:
```bash
kubectl get pods -l app=flashsale -o wide
```
*Expected Output:*
```text
NAME                 READY   STATUS    RESTARTS   AGE     IP            NODE       NOMINATED NODE   READINESS GATES
flashsale-rs-4nr6q   1/1     Running   0          10m     10.244.0.9    minikube   <none>           <none>
flashsale-rs-hqtm7   1/1     Running   0          109s    10.244.0.12   minikube   <none>           <none>
flashsale-rs-nsmlx   1/1     Running   0          2m54s   10.244.0.11   minikube   <none>           <none>
flashsale-rs-rbwr4   1/1     Running   0          10m     10.244.0.7    minikube   <none>           <none>
flashsale-rs-wfbb4   1/1     Running   0          2m54s   10.244.0.10   minikube   <none>           <none>
```

---

## ❓ Questions & Answers (Q&A)

**Q1: What is the initial number of replicas in the ReplicaSet?**  
**A1:** `3` (specified in `spec.replicas: 3`).

**Q2: How many pods are running after applying the ReplicaSet configuration?**  
**A2:** `3` pods are created and running.

**Q3: What happens when you scale the ReplicaSet to 5 replicas?**  
**A3:** Kubernetes creates 2 additional Pods to meet the desired count of 5 replicas. The ReplicaSet reconciliation loop ensures 5 healthy Pods are active.

**Q4: What happens when you delete one pod?**  
**A4:** Kubernetes automatically provisions a new Pod to replace the terminated one, restoring the desired state of 5 replicas.

**Q5: How does Kubernetes maintain the desired number of replicas?**  
**A5:** The ReplicaSet controller continuously monitors the cluster via the Kubernetes API server, comparing the actual number of matching Pods (via label selectors) against the `spec.replicas` desired state. Any discrepancy triggers creation or deletion of Pods.

**Q6: How many nodes are running?**  
**A6:** `1` node (`minikube`).

**Q7: Where are the pods running with respect to nodes?**  
**A7:** All 5 pods are running co-located on the single `minikube` node, each allocated an isolated Pod IP address and network namespace by the CNI.

---

## 🏆 Additional Challenges & Production Comparison

### Challenge 1: Deployment vs. ReplicaSet (`flashsale-deployment.yaml`)
In modern Kubernetes production environments, **Deployments** are preferred over bare ReplicaSets. Deployments automatically manage ReplicaSets, adding declarative rolling updates, zero-downtime canary updates, and automated rollbacks.

Apply the Deployment manifest:
```bash
kubectl apply -f flashsale-deployment.yaml
```

### Challenge 2: Deep Inspection
Inspect controller events, conditions, and probe statuses:
```bash
kubectl describe rs flashsale-rs
kubectl describe pod -l app=flashsale
```

### Challenge 3: Live Pod Interaction & Logs
```bash
# View combined logs
kubectl logs -l app=flashsale --tail=50

# Execute interactive shell inside one of the replicas
kubectl exec -it $(kubectl get pods -l app=flashsale -o jsonpath='{.items[0].metadata.name}') -- /bin/sh
```

---

## 🧹 Teardown & Cleanup

```bash
kubectl delete -f flashsale-replicaset.yaml --ignore-not-found=true
kubectl delete -f flashsale-deployment.yaml --ignore-not-found=true
```
Or execute:
- Linux / macOS / WSL: `./cleanup.sh`
- Windows PowerShell: `.\cleanup.ps1`
