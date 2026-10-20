# Exercise 10: Multi-Node Kubernetes Cluster with Multiple Applications and ReplicaSets

## 📋 Overview & Storyboard

In an enterprise e-commerce platform (such as Amazon or Flipkart), high availability and fault tolerance are foundational requirements. A failure in a single physical or virtual host must not take down customer-facing microservices.

In this exercise, we architect and deploy a resilient, multi-node Kubernetes cluster hosting two interdependent microservices:
1. **Product Catalog (`AppA`)**: Exposes the product catalog and pricing (scaled to **2 replicas**).
2. **Shopping Cart (`AppB`)**: Manages the user's active shopping cart items (scaled to **3 replicas**).

To guarantee resilience, we leverage **Kubernetes Pod Anti-Affinity** (`podAntiAffinity` with `topologyKey: "kubernetes.io/hostname"`). This scheduler policy forces Kubernetes to distribute replicas across distinct cluster nodes, ensuring zero downtime even if a node crashes or undergoes maintenance.

---

## 🏗️ Architecture & Cluster Layout

```
                  ┌────────────────────────────────────────┐
                  │       Minikube 3-Node Cluster          │
                  │       (Profile: devops-multinode)      │
                  └──────────────────┬─────────────────────┘
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         ▼                           ▼                           ▼
┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
│ devops-multinode │        │ devops-multinode │        │ devops-multinode │
│ (Control / Node) │        │      (-m02)      │        │      (-m03)      │
├──────────────────┤        ├──────────────────┤        ├──────────────────┤
│ shopping-cart-1  │        │ product-catalog-1│        │ product-catalog-2│
│ (Pod - Port 80)  │        │ (Pod - Port 80)  │        │ (Pod - Port 80)  │
│                  │        │                  │        │                  │
│                  │        │ shopping-cart-2  │        │ shopping-cart-3  │
│                  │        │ (Pod - Port 80)  │        │ (Pod - Port 80)  │
└────────┬─────────┘        └────────┬─────────┘        └────────┬─────────┘
         │                           │                           │
         └───────────────────────────┴───────────────────────────┘
                                     │
         ┌───────────────────────────┴───────────────────────────┐
         ▼                                                       ▼
┌─────────────────────────────────┐             ┌─────────────────────────────────┐
│ product-catalog-service         │             │ shopping-cart-service           │
│ NodePort (Port 80 -> NodePort)  │             │ NodePort (Port 80 -> NodePort)  │
└─────────────────────────────────┘             └─────────────────────────────────┘
```

---

## 📂 File Structure

```
devops/exercise-10/
├── Dockerfile.product             # Container definition for Product Catalog
├── Dockerfile.shopping            # Container definition for Shopping Cart
├── product_catalog.py             # Flask AppA - Product Catalog service
├── shopping_cart.py               # Flask AppB - Shopping Cart service
├── product_catalog_deployment.yaml# K8s Deployment (2 replicas + Anti-Affinity)
├── shopping_cart_deployment.yaml  # K8s Deployment (3 replicas + Anti-Affinity)
├── product_catalog_service.yaml   # K8s NodePort Service for Product Catalog
├── shopping_cart_service.yaml      # K8s NodePort Service for Shopping Cart
├── requirements.txt               # Python dependencies (Flask)
├── deploy.sh                      # Automation bash deployment script
├── deploy.ps1                     # Automation PowerShell deployment script
├── cleanup.sh                     # Teardown bash script
├── cleanup.ps1                    # Teardown PowerShell script
└── README.md                      # Comprehensive guide and verification
```

---

## 🚀 Step-by-Step Instructions

### Step 0: Clean Up Any Existing Minikube Instances

Before provisioning a multi-node cluster, clean up any existing Minikube instance:

```bash
minikube stop
minikube delete
```

---

### Step 1: Set Up Minikube with Multiple Nodes & Registry Add-on

Create a multi-node Minikube cluster consisting of 3 nodes under the profile `devops-multinode`:

```bash
minikube start --nodes 3 -p devops-multinode --force
```

Enable the Minikube registry add-on to facilitate image distribution across nodes:

```bash
minikube -p devops-multinode addons enable registry
```

---

### Step 2 & 3: Microservice Applications

#### Product Catalog (`product_catalog.py`)
```python
from flask import Flask, jsonify

app = Flask(__name__)

products = [
    {"id": 1, "name": "Laptop", "price": 1200},
    {"id": 2, "name": "Phone", "price": 800},
    {"id": 3, "name": "Headphones", "price": 150},
]

@app.route("/products", methods=["GET"])
def get_products():
    return jsonify(products)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

#### Shopping Cart (`shopping_cart.py`)
```python
from flask import Flask, jsonify, request

app = Flask(__name__)

cart = []

@app.route("/cart", methods=["GET"])
def get_cart():
    return jsonify(cart)

@app.route("/cart", methods=["POST"])
def add_to_cart():
    item = request.json
    cart.append(item)
    return jsonify(cart), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

---

### Step 4: Dockerize Both Applications

Build container images locally using the respective Dockerfiles:

```bash
# Build Product Catalog image
docker build -t product-catalog:latest -f Dockerfile.product .

# Build Shopping Cart image
docker build -t shopping-cart:latest -f Dockerfile.shopping .
```

Verify images in local Docker daemon:
```bash
docker images | grep -E "product-catalog|shopping-cart"
```

---

### Step 5: Load Images into Minikube Multi-Node Cluster

In a multi-node Minikube setup, images must be loaded into the cluster registry so all worker nodes can pull them:

```bash
minikube -p devops-multinode image load product-catalog:latest
minikube -p devops-multinode image load shopping-cart:latest
```

Verify that images exist on cluster nodes:
```bash
minikube -p devops-multinode ssh -- docker images
```

---

### Step 6: Deploy Applications with Pod Anti-Affinity

Pod Anti-Affinity rules ensure that the Kubernetes scheduler places replicas on different host nodes using `topologyKey: "kubernetes.io/hostname"`.

Apply both deployments:
```bash
kubectl apply -f product_catalog_deployment.yaml
kubectl apply -f shopping_cart_deployment.yaml
```

---

### Step 7: Expose Services via NodePort

Deploy the NodePort services to expose port 80 externally:

```bash
kubectl apply -f product_catalog_service.yaml
kubectl apply -f shopping_cart_service.yaml
```

---

### Step 8: Verify Pod Distribution Across Nodes

Inspect the running Pods and their assigned cluster nodes using `kubectl get pods -o wide`:

```bash
kubectl get pods -o wide
```

**Sample Output:**
```text
NAME                               READY   STATUS    RESTARTS   AGE   IP           NODE                   NOMINATED NODE   READINESS GATES
product-catalog-5fdfc7f5fb-2jlnv   1/1     Running   0          29s   10.244.1.3   devops-multinode-m02   <none>           <none>
product-catalog-5fdfc7f5fb-7v556   1/1     Running   0          29s   10.244.2.4   devops-multinode-m03   <none>           <none>
shopping-cart-788c48675b-7l4lx     1/1     Running   0          25s   10.244.0.4   devops-multinode       <none>           <none>
shopping-cart-788c48675b-d48w2     1/1     Running   0          25s   10.244.1.4   devops-multinode-m02   <none>           <none>
shopping-cart-788c48675b-hml9r     1/1     Running   0          25s   10.244.2.5   devops-multinode-m03   <none>           <none>
```

> **Observation**:
> - `product-catalog` replicas are scheduled on `devops-multinode-m02` and `devops-multinode-m03`.
> - `shopping-cart` replicas are scheduled across all 3 nodes (`devops-multinode`, `devops-multinode-m02`, `devops-multinode-m03`).

---

### Step 9: Access Services via Minikube Tunnel

Because the Docker driver runs inside containerized networks, access the NodePort services using the `minikube service` tunnel command:

```bash
# Terminal 1: Product Catalog Tunnel
minikube -p devops-multinode service product-catalog-service

# Terminal 2: Shopping Cart Tunnel
minikube -p devops-multinode service shopping-cart-service
```

---

### Step 10: Testing Endpoints with `curl`

#### 1. Test Product Catalog Service (`GET /products`)
```bash
curl http://127.0.0.1:35855/products
```

**Expected Response:**
```json
[
    {"id": 1, "name": "Laptop", "price": 1200},
    {"id": 2, "name": "Phone", "price": 800},
    {"id": 3, "name": "Headphones", "price": 150}
]
```

#### 2. Test Shopping Cart Service (`GET /cart`)
```bash
curl http://127.0.0.1:38975/cart
```

**Expected Response:**
```json
[]
```

#### 3. Add Item to Shopping Cart (`POST /cart`)
```bash
curl -X POST http://127.0.0.1:38975/cart \
  -H "Content-Type: application/json" \
  -d '{"id": 1, "name": "Laptop", "quantity": 1}'
```

**Expected Response:**
```json
[
    {"id": 1, "name": "Laptop", "quantity": 1}
]
```

---

## 🧹 Cleanup

To remove the Kubernetes resources:
```bash
kubectl delete -f shopping_cart_service.yaml --ignore-not-found=true
kubectl delete -f product_catalog_service.yaml --ignore-not-found=true
kubectl delete -f shopping_cart_deployment.yaml --ignore-not-found=true
kubectl delete -f product_catalog_deployment.yaml --ignore-not-found=true
```

To stop and delete the Minikube multi-node cluster:
```bash
minikube stop -p devops-multinode
minikube delete -p devops-multinode
```

Or execute `./cleanup.sh` (or `.\cleanup.ps1` on Windows).
