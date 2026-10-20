# DevOps Hands-On Exercises & Solutions

Welcome to the **DevOps Hands-On Exercise Series**. This directory contains production-ready solutions, Kubernetes manifests, automation scripts, and documentation for each exercise.

---

## 📚 Exercise Index

| Exercise | Topic | Description | Directory Link |
|:---:|:---|:---|:---:|
| **Exercise 1** | Kubernetes (K8s) | **Hello Pod**: Deploying Zepto Storefront (Nginx) as a Pod and exposing via NodePort Service | [📂 `devops/exercise-1`](./exercise-1/) |
| **Exercise 2** | Kubernetes (K8s) | **Deploy Flask App on Minikube**: Building Python Flask image locally and deploying via Deployment & Service manifests | [📂 `devops/exercise-2`](./exercise-2/) |

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
└── exercise-2/             # Exercise 2: Flask App on Minikube
    ├── README.md           # Exercise 2 documentation & Q&A
    ├── app.py              # Flask web application
    ├── Dockerfile          # Container build definition
    ├── requirements.txt    # Python dependencies
    ├── flask-deployment.yaml # Deployment and NodePort Service manifests
    ├── deploy.sh           # Automated deployment script (Bash)
    ├── deploy.ps1          # Automated deployment script (PowerShell)
    ├── cleanup.sh          # Teardown script (Bash)
    └── cleanup.ps1         # Teardown script (PowerShell)
```
