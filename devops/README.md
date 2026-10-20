# DevOps Hands-On Exercises & Solutions

Welcome to the **DevOps Hands-On Exercise Series**. This directory contains production-ready solutions, Kubernetes manifests, automation scripts, and documentation for each exercise.

---

## 📚 Exercise Index

| Exercise | Topic | Description | Directory Link |
|:---:|:---|:---|:---:|
| **Exercise 1** | Kubernetes (K8s) | **Hello Pod**: Deploying Zepto Storefront (Nginx) as a Pod and exposing via NodePort Service | [📂 `devops/exercise-1`](./exercise-1/) |
| **Exercise 2** | Kubernetes (K8s) | **Deploy Flask App on Minikube**: Building Python Flask image locally and deploying via Deployment & Service manifests | [📂 `devops/exercise-2`](./exercise-2/) |
| **Exercise 3** | Kubernetes (K8s) | **Scaling Flask App on Single Node using ReplicaSets**: High-concurrency flash sale simulation, horizontal pod scaling, and self-healing | [📂 `devops/exercise-3`](./exercise-3/) |
| **Exercise 4** | Docker Networking | **Docker Networking with Multiple Containers**: Multi-container bridge networking (Flask API, MySQL, Redis) and DNS service discovery | [📂 `devops/exercise-4`](./exercise-4/) |
| **Exercise 5** | Container Security | **Docker Security with AppArmor and Python**: Securing containers with AppArmor profiles, programmatic SDK enforcement, and restricted action verification | [📂 `devops/exercise-5`](./exercise-5/) |
| **Exercise 6** | Observability & CI/CD | **Real-Time Operations Monitoring and Alerting (ZAPPTTO)**: Python Prometheus metrics exporter, Prometheus alerting rules, Grafana dashboards, and Jenkins pipeline | [📂 `devops/exercise-6`](./exercise-6/) |
| **Exercise 7** | Continuous Integration | **Introduction to CI and Jenkins Installation**: Core CI concepts, top 10 CI tools comparison, containerized Jenkins LTS deployment, and sample pipeline | [📂 `devops/exercise-7`](./exercise-7/) |
| **Exercise 8** | Jenkins Automation | **Creating "Hello World" Jenkins Job**: Shell script execution via Git SCM, Freestyle project build configuration, and console output verification | [📂 `devops/exercise-8`](./exercise-8/) |
| **Exercise 9** | CI/CD Pipelines | **Jenkins Multi-Stage Pipeline: Deploying a Python Application**: End-to-end 5-stage declarative pipeline (Build, Test, Deploy, Run App, Test App) with unit testing and process tracking | [📂 `devops/exercise-9`](./exercise-9/) |
| **Exercise 10** | Kubernetes (K8s) | **Multi-Node Kubernetes Cluster with Multiple Applications and ReplicaSets**: Product Catalog (2 replicas) & Shopping Cart (3 replicas) across 3 Minikube nodes with Pod Anti-Affinity | [📂 `devops/exercise-10`](./exercise-10/) |

---

## 📁 Repository Structure

```text
devops/
├── README.md               # Main DevOps directory index
├── Images/
│   └── k8s-exercise-1.jpg  # Kubernetes system internal architecture diagram
├── exercise-1/             # Exercise 1: Hello Pod
│   ├── README.md           # Exercise 1 documentation & deep dive
│   ├── pod.yaml            # Pod manifest (nginx)
│   ├── service.yaml        # Service manifest (NodePort)
│   ├── deploy.sh           # Automated deployment script (Bash)
│   ├── deploy.ps1          # Automated deployment script (PowerShell)
│   ├── cleanup.sh          # Teardown script (Bash)
│   ├── cleanup.ps1         # Teardown script (PowerShell)
│   └── k8s-exercise-1.jpg  # Architecture diagram
├── exercise-2/             # Exercise 2: Flask App on Minikube
│   ├── README.md           # Exercise 2 documentation & Q&A
│   ├── app.py              # Flask web application
│   ├── Dockerfile          # Container build definition
│   ├── requirements.txt    # Python dependencies
│   ├── flask-deployment.yaml # Deployment and NodePort Service manifests
│   ├── deploy.sh           # Automated deployment script (Bash)
│   ├── deploy.ps1          # Automated deployment script (PowerShell)
│   ├── cleanup.sh          # Teardown script (Bash)
│   └── cleanup.ps1         # Teardown script (PowerShell)
├── exercise-3/             # Exercise 3: Scaling Flask App using ReplicaSets
│   ├── README.md           # Exercise 3 documentation, walkthrough & Q&A
│   ├── app.py              # Flash sale Flask application
│   ├── ex3-flash-sale.py   # Compatibility entry point
│   ├── Dockerfile          # Container build definition
│   ├── requirements.txt    # Python dependencies (Flask, Gunicorn)
│   ├── flashsale-replicaset.yaml # ReplicaSet & Service manifests
│   ├── flashsale-deployment.yaml # Additional challenge: Deployment manifest
│   ├── deploy.sh           # Automated deployment & scaling script (Bash)
│   ├── deploy.ps1          # Automated deployment & scaling script (PowerShell)
│   ├── cleanup.sh          # Teardown script (Bash)
│   └── cleanup.ps1         # Teardown script (PowerShell)
├── exercise-4/             # Exercise 4: Docker Multi-Container Networking
│   ├── README.md           # Exercise 4 documentation, tasks & Q&A
│   ├── app.py              # Flask REST API
│   ├── Dockerfile          # Container build definition with diagnostic tools
│   ├── requirements.txt    # Python dependencies
│   ├── docker-compose.yml  # Modern multi-container orchestration manifest
│   ├── deploy.sh           # Automated setup, container run & connectivity test (Bash)
│   ├── deploy.ps1          # Automated setup, container run & connectivity test (PowerShell)
│   ├── cleanup.sh          # Teardown script (Bash)
│   └── cleanup.ps1         # Teardown script (PowerShell)
├── exercise-5/             # Exercise 5: Docker Security with AppArmor and Python
│   ├── README.md           # Exercise 5 documentation, walkthrough & Q&A
│   ├── app.py              # Secured Flask application
│   ├── Dockerfile          # Container build definition
│   ├── requirements.txt    # Python dependencies (Flask, Docker SDK)
│   ├── my-apparmor-profile # AppArmor Mandatory Access Control profile
│   ├── apply_apparmor.py   # Python Docker SDK profile enforcement script
│   ├── test_restricted_actions.py # Python test script for restricted operations
│   ├── deploy.sh           # Automated deployment & security check script (Bash)
│   ├── deploy.ps1          # Automated deployment & security check script (PowerShell)
│   ├── cleanup.sh          # Teardown script (Bash)
│   └── cleanup.ps1         # Teardown script (PowerShell)
├── exercise-6/             # Exercise 6: Real-Time Operations Monitoring & Alerting
│   ├── README.md           # Exercise 6 documentation, architecture & guide
│   ├── delivery_metrics.py # Python Prometheus metrics producer
│   ├── Dockerfile          # Container build definition
│   ├── requirements.txt    # Python dependencies (prometheus-client)
│   ├── prometheus.yml      # Prometheus configuration & scrape targets
│   ├── alert_rules.yml     # Prometheus alert rules
│   ├── Jenkinsfile         # Jenkins declarative pipeline script
│   ├── docker-compose.yml  # Unified monitoring stack orchestration
│   ├── deploy.sh           # Automated deployment & verification script (Bash)
│   ├── deploy.ps1          # Automated deployment & verification script (PowerShell)
│   ├── cleanup.sh          # Teardown script (Bash)
│   └── cleanup.ps1         # Teardown script (PowerShell)
├── exercise-7/             # Exercise 7: Introduction to CI & Jenkins Installation
│   ├── README.md           # Exercise 7 documentation, CI concepts & guide
│   ├── Jenkinsfile         # Sample starter declarative CI pipeline
│   ├── docker-compose.yml  # Jenkins server orchestration manifest
│   ├── deploy.sh           # Automated deployment & password extraction (Bash)
│   ├── deploy.ps1          # Automated deployment & password extraction (PowerShell)
│   ├── cleanup.sh          # Teardown script (Bash)
│   └── cleanup.ps1         # Teardown script (PowerShell)
├── exercise-8/             # Exercise 8: Creating "Hello World" Jenkins Job
│   ├── README.md           # Exercise 8 documentation, job config & guide
│   ├── hello-world.sh      # Bash script executed by Jenkins build step
│   ├── hello-world.ps1     # PowerShell equivalent for Windows environments
│   ├── Jenkinsfile         # Pipeline as Code specification
│   ├── test_job.sh         # Local verification test script (Bash)
│   └── test_job.ps1        # Local verification test script (PowerShell)
├── exercise-9/             # Exercise 9: Jenkins Multi-Stage Pipeline
│   ├── README.md           # Exercise 9 documentation, architecture & guide
│   ├── app.py              # Python Flask application
│   ├── test_app.py         # Unit test suite using unittest
│   ├── requirements.txt    # Python dependencies (Flask, flake8)
│   ├── Jenkinsfile         # 5-stage declarative CI/CD pipeline
│   ├── Dockerfile          # Container build definition
│   ├── deploy.sh           # Automated local pipeline simulation (Bash)
│   ├── deploy.ps1          # Automated local pipeline simulation (PowerShell)
│   ├── cleanup.sh          # Teardown script (Bash)
│   └── cleanup.ps1         # Teardown script (PowerShell)
└── exercise-10/            # Exercise 10: Multi-Node K8s Cluster with Anti-Affinity
    ├── README.md           # Exercise 10 documentation, architecture & guide
    ├── product_catalog.py  # Flask AppA - Product Catalog service
    ├── shopping_cart.py    # Flask AppB - Shopping Cart service
    ├── requirements.txt    # Python dependencies (Flask)
    ├── Dockerfile.product  # Dockerfile for Product Catalog
    ├── Dockerfile.shopping # Dockerfile for Shopping Cart
    ├── product_catalog_deployment.yaml # K8s Deployment (2 replicas + Anti-Affinity)
    ├── shopping_cart_deployment.yaml   # K8s Deployment (3 replicas + Anti-Affinity)
    ├── product_catalog_service.yaml    # NodePort Service for Product Catalog
    ├── shopping_cart_service.yaml      # NodePort Service for Shopping Cart
    ├── deploy.sh           # Automated deployment script (Bash)
    ├── deploy.ps1          # Automated deployment script (PowerShell)
    ├── cleanup.sh          # Teardown script (Bash)
    └── cleanup.ps1         # Teardown script (PowerShell)
```
