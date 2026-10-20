# Exercise 6: Real-Time Operations Monitoring and Alerting

## 🎯 Objective

You are a **DevOps Engineer at ZAPPTTO**, managing a high-velocity quick-commerce delivery service. To guarantee SLAs and detect operational bottlenecks in real time:
1. Build a metrics instrumentation service using Python and the official `prometheus_client`.
2. Configure **Prometheus** to scrape, evaluate, and fire automated threshold alerts.
3. Build executive and operational dashboards in **Grafana** to visualize live fleet status.
4. Automate end-to-end containerized deployments using a declarative **Jenkins Pipeline** (`Jenkinsfile`).

---

## 🏗️ Architecture & Technology Stack

* **Metrics Producer:** Python application simulating real-time delivery telemetry.
* **Telemetry Collector & Alert Engine:** Prometheus server scraping metrics and evaluating rule expressions.
* **Visualization:** Grafana dashboards displaying live operational graphs.
* **CI/CD Automation:** Jenkins pipeline orchestrating Docker image build, testing, and service deployment.

```text
[ Delivery Simulator ] :8000/metrics
         │ (HTTP Scrape every 5s)
         ▼
    [ Prometheus ] :9090
         │               │ (Alert Rules Evaluation)
         ▼               ▼
   [ Grafana ] :3000  [ Alerts Dashboard ] (HighPendingDeliveries, HighAverageDeliveryTime)
```

---

## 📋 Prerequisites & Installation

### Required Tools:
* **Docker:** Engine 20.10+ / Docker Desktop
* **Python:** Version 3.10 or higher
* **Prometheus & Grafana:** Container images (`prom/prometheus`, `grafana/grafana`)
* **Jenkins:** Automation server (`jenkins/jenkins:lts`)

### Install Python Dependencies:
```bash
pip install prometheus-client
```

---

## 📁 Directory Structure

```text
devops/exercise-6/
├── delivery_metrics.py   # Python script simulating live delivery metrics
├── Dockerfile            # Container specification for metrics producer
├── requirements.txt      # Python dependencies (prometheus-client)
├── prometheus.yml        # Prometheus server and scrape targets configuration
├── alert_rules.yml       # Prometheus alerting rules and conditions
├── Jenkinsfile           # Jenkins declarative CI/CD pipeline
├── docker-compose.yml    # Unified multi-service orchestration
├── deploy.sh             # Automated startup script (Bash)
├── deploy.ps1            # Automated startup script (PowerShell)
├── cleanup.sh            # Teardown script (Bash)
├── cleanup.ps1           # Teardown script (PowerShell)
└── README.md             # Complete exercise documentation
```

---

## 🚀 Step-by-Step Implementation Guide

### Step 1: Write the Python Application (`delivery_metrics.py`)

```python
from prometheus_client import start_http_server, Summary, Gauge
import random
import time

# Metrics Definitions
total_deliveries = Gauge("total_deliveries", "Total number of deliveries")
pending_deliveries = Gauge("pending_deliveries", "Number of pending deliveries")
on_the_way_deliveries = Gauge("on_the_way_deliveries", "Number of deliveries on the way")
average_delivery_time = Summary("average_delivery_time", "Average delivery time in seconds")

def simulate_delivery():
    # Simulated metrics values
    pending = random.randint(10, 20)  # Exceeds threshold (>10) for alert testing
    on_the_way = random.randint(5, 20)
    delivered = random.randint(30, 70)
    avg_time = random.uniform(15, 45)

    total = pending + on_the_way + delivered

    print(f"[DEBUG] Total deliveries: {total}")
    print(f"[DEBUG] Pending deliveries: {pending}")
    print(f"[DEBUG] On-the-way deliveries: {on_the_way}")
    print(f"[DEBUG] Average delivery time: {avg_time:.2f} seconds")

    total_deliveries.set(total)
    pending_deliveries.set(pending)
    on_the_way_deliveries.set(on_the_way)
    average_delivery_time.observe(avg_time)

if __name__ == "__main__":
    print("[INFO] Starting the HTTP server on port 8000...")
    start_http_server(8000, addr="0.0.0.0")
    print("[INFO] HTTP server started. Simulating deliveries...")
    while True:
        simulate_delivery()
        time.sleep(1)
```

#### Understanding Prometheus Metric Types:
1. **Gauge (`total_deliveries`, `pending_deliveries`):** Represents a single numerical value that can arbitrarily go up or down. Ideal for queue sizes, current active deliveries, and CPU/memory usage.
2. **Counter:** A cumulative metric that only ever increases or resets to zero upon restart (e.g., total requests served, total errors).
3. **Summary (`average_delivery_time`):** Samples observations (such as request latencies or delivery durations) and calculates configurable percentiles, running totals, and counts.
4. **Histogram:** Counts observations in configurable bucket intervals.

#### Test the metrics endpoint:
```bash
curl http://localhost:8000/metrics
```

---

### Step 2: Configure Prometheus (`prometheus.yml`) & Alerts (`alert_rules.yml`)

#### `prometheus.yml`:
```yaml
global:
  scrape_interval: 5s
  evaluation_interval: 5s

rule_files:
  - /etc/prometheus/alert_rules.yml

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "delivery_service"
    static_configs:
      - targets: ["delivery_metrics:8000", "host.docker.internal:8000", "172.17.0.1:8000"]
```

#### `alert_rules.yml`:
```yaml
groups:
  - name: delivery_alerts
    rules:
      - alert: HighPendingDeliveries
        expr: pending_deliveries > 10
        for: 15s
        labels:
          severity: warning
        annotations:
          summary: "High pending deliveries"
          description: "Pending deliveries are above 10 for the last 15 seconds."

      - alert: HighAverageDeliveryTime
        expr: (average_delivery_time_sum / average_delivery_time_count) > 30
        for: 15s
        labels:
          severity: critical
        annotations:
          summary: "High average delivery time"
          description: "Average delivery time is above 30 seconds for the last 15 seconds."
```

---

### Step 3: Set Up Grafana & Create Dashboards

#### 1. Start Grafana:
```bash
docker run -d --name grafana -p 3000:3000 -e "GF_SECURITY_ADMIN_USER=admin" -e "GF_SECURITY_ADMIN_PASSWORD=admin" grafana/grafana:latest
```

#### 2. Access Grafana Web UI:
* URL: **[http://localhost:3000](http://localhost:3000)**
* Default Credentials: `admin` / `admin`

#### 3. Add Prometheus as Data Source:
* Navigate to: **Connections &rarr; Data Sources &rarr; Add data source &rarr; Prometheus**
* URL: `http://prometheus:9090` (if in Docker network) or `http://host.docker.internal:9090`
* Click **Save & test**.

#### 4. Configure Monitoring Dashboard Panels:
| Panel Title | Query Expression | Visualization |
|:---|:---|:---:|
| **Total Deliveries** | `total_deliveries` | Stat / Gauge |
| **Pending Deliveries** | `pending_deliveries` | Time Series / Gauge |
| **On-The-Way Deliveries** | `on_the_way_deliveries` | Time Series |
| **Average Delivery Time** | `average_delivery_time_sum / average_delivery_time_count` | Gauge / Graph |

---

### Step 4: Jenkins CI/CD Pipeline Automation (`Jenkinsfile`)

```groovy
pipeline {
    agent any
    stages {
        stage('Pre-check Docker') {
            steps {
                script {
                    try {
                        def dockerVersion = sh(script: 'docker --version', returnStdout: true).trim()
                        if (!dockerVersion) {
                            error "Docker is not installed or not in the PATH."
                        }
                        def dockerInfo = sh(script: 'docker info', returnStatus: true)
                        if (dockerInfo != 0) {
                            error "Docker daemon is not running."
                        }
                        echo "Docker is available: ${dockerVersion}"
                    } catch (Exception e) {
                        error "Pre-check failed: ${e.message}"
                    }
                }
            }
        }
        stage('Setup Workspace') {
            steps {
                echo "Preparing workspace files for delivery metrics pipeline..."
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t delivery_metrics .'
            }
        }
        stage('Run Application') {
            steps {
                sh '''
                docker rm -f delivery_metrics 2>/dev/null || true
                docker run -d -p 8000:8000 --name delivery_metrics delivery_metrics
                '''
            }
        }
        stage('Run Prometheus & Grafana') {
            steps {
                sh '''
                docker rm -f prometheus grafana 2>/dev/null || true
                docker run -d --name prometheus -p 9090:9090 \
                  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
                  -v $(pwd)/alert_rules.yml:/etc/prometheus/alert_rules.yml \
                  prom/prometheus
                docker run -d --name grafana -p 3000:3000 grafana/grafana
                '''
            }
        }
    }
}
```

---

### Step 5: Simulate & Validate Alerts

To simulate an emergency rush hour:
1. Increase `pending` delivery values in `delivery_metrics.py`:
   ```python
   pending = random.randint(50, 100)
   ```
2. Open Prometheus Alerts at **[http://localhost:9090/alerts](http://localhost:9090/alerts)**.
3. Observe alert state transitions:
   - **`Inactive`** &rarr; Value below threshold.
   - **`Pending`** &rarr; Expression evaluated true (`pending_deliveries > 10`), waiting for `for: 15s` duration to pass.
   - **`Firing`** &rarr; Condition sustained for over 15 seconds; notification triggered.

---

## ⚡ Quick Deployment with Docker Compose

Run the entire pipeline stack with a single command:

```bash
docker compose up -d
```

To stop all services:
```bash
docker compose down
```
