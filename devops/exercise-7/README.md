# Exercise 7: Introduction to Continuous Integration (CI) and Jenkins Installation

## 📘 What is Continuous Integration (CI)?

**Continuous Integration (CI)** is a software engineering practice where developers frequently merge code changes into a central repository (often multiple times per day). Each integration is verified by an automated build and test pipeline, allowing teams to catch bugs early, prevent integration hell, and accelerate release cycles.

---

## 🔑 Key Features of CI

1. **Frequent Code Integration:** Developers commit small, incremental code changes to shared branches rather than maintaining long-lived divergent branches.
2. **Automated Builds:** Every commit or pull request triggers an automated compilation and dependency resolution process.
3. **Automated Testing:** Unit tests, integration tests, and static code analysis automatically execute on every build.
4. **Immediate Feedback:** Developers receive real-time notifications on build or test failures, enabling immediate remediation before issues reach production.

---

## 🌟 Benefits of CI

* **Early Bug Detection:** Integration bugs and regressions are identified minutes after being introduced rather than weeks later.
* **Improved Collaboration:** Eliminates merge conflicts and keeps all team members aligned on a working codebase.
* **Accelerated Delivery:** Reduces manual testing and deployment overhead.
* **Consistent Quality:** Enforces automated test coverage and quality gates across every commit.

---

## 🔄 How CI Works: Step-by-Step Flow

```text
[ Developer Machine ]
        │ git push
        ▼
[ Version Control (GitHub) ]
        │ Webhook Trigger
        ▼
[ CI Automation Server (Jenkins) ]
        │
        ├─► 1. Checkout Latest Code
        ├─► 2. Resolve Dependencies & Compile
        ├─► 3. Execute Automated Test Suites
        ├─► 4. Package Artifacts (Docker Image / Jar)
        │
        ▼
[ Notification / Feedback ] (Slack / Email / GitHub Status Checks)
```

---

## 🛠️ Overview of Popular CI/CD Tools

| # | Tool | Primary Architecture | Best Suited For | Key Differentiators |
|:---:|:---|:---|:---|:---|
| **1** | **Jenkins** | Self-hosted, plugin-driven | Highly custom enterprise pipelines | 1,800+ community plugins, completely open-source, highly extensible |
| **2** | **GitHub Actions** | Cloud-native, repo-integrated | Teams hosting code on GitHub | Zero-setup integration, marketplace of reusable actions |
| **3** | **GitLab CI/CD** | Unified DevOps platform | GitLab repositories | Single application for entire DevOps lifecycle, Auto DevOps |
| **4** | **CircleCI** | Cloud-first & self-hosted runners | Fast containerized builds | Intelligent test splitting, parallelism, advanced caching |
| **5** | **Travis CI** | Cloud SaaS | Open-source repositories | Declarative YAML, simple setup for open-source communities |
| **6** | **Bamboo** | On-premise enterprise | Atlassian ecosystem users | Seamless integration with Jira, Bitbucket, and Confluence |
| **7** | **TeamCity** | Enterprise server (JetBrains) | Complex builds & multi-platform | Rich build history, automatic test re-runs, IDE integration |
| **8** | **Azure DevOps** | Cloud & server suite | Microsoft / Azure ecosystems | Cross-platform hosted runners, tight Visual Studio integration |
| **9** | **Buildkite** | Hybrid (cloud control + local agents) | High-security enterprise | Source code never leaves your private cloud/servers |
| **10** | **Drone** | Container-native lightweight | Docker-first microservice stacks | Every pipeline step executes as an isolated Docker container |

---

## 🤖 Introduction to Jenkins

**Jenkins** is the industry-standard, open-source automation server. It automates repetitive tasks across software lifecycles, enabling continuous integration, automated testing, and continuous delivery.

### Core Concepts:
* **Job / Project:** A user-configured task that Jenkins executes (e.g., Freestyle project, Pipeline project, Multibranch pipeline).
* **Build:** The execution instance of a Job with specific logs, artifacts, and test results.
* **Pipeline:** A defined sequence of stages (Checkout &rarr; Build &rarr; Test &rarr; Deploy) written as code in a `Jenkinsfile`.
* **Plugins:** Modules extending Jenkins capabilities to integrate with Git, Docker, Kubernetes, Slack, SonarQube, etc.
* **Controller (Master) & Agents (Nodes):** Controller schedules jobs and manages the UI; distributed agent nodes execute build steps.

---

## 🚀 Getting Started: Installing Jenkins via Docker

### 1. Launch the Jenkins LTS Container
Run Jenkins with persistent storage and exposed ports:
* Port **8080**: Web user interface.
* Port **50000**: Inbound build agent connection port.

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

Or run via Docker Compose:
```bash
docker compose up -d
```

---

### 2. Retrieve the Initial Admin Password
For security, Jenkins locks the initial installation until the generated secret is provided.

Retrieve the password from the container:
```bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
*Example Output:*
```text
060a3736329e4533ab8e4428ffcc9619
```

---

### 3. Complete Web Setup Wizard
1. Open your browser and navigate to: **[http://localhost:8080](http://localhost:8080)**.
2. **Unlock Jenkins:** Paste the password retrieved from `/var/jenkins_home/secrets/initialAdminPassword`.
3. **Customize Jenkins:** Click **Install suggested plugins** (automatically installs Git, Pipeline, Credentials, etc.).
4. **Create First Admin User:** Enter your desired username, password, full name, and email.
5. **Instance Configuration:** Confirm the Jenkins URL (`http://localhost:8080/`) and click **Save and Finish**.
6. **Jenkins is Ready!** Click **Start using Jenkins** to view the main dashboard.

---

### 4. Test with a Sample Starter Pipeline (`Jenkinsfile`)

Create your first pipeline job in Jenkins:
1. Click **New Item** &rarr; Name it `sample-ci-pipeline` &rarr; Select **Pipeline** &rarr; Click **OK**.
2. Scroll to the **Pipeline** section.
3. Select **Pipeline script** and paste the provided [`Jenkinsfile`](./Jenkinsfile) content:

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code from repository...'
            }
        }
        stage('Build') {
            steps {
                echo 'Compiling and resolving dependencies...'
                sh 'echo "Build Stage Completed Successfully"'
            }
        }
        stage('Automated Test') {
            steps {
                echo 'Running unit and integration tests...'
                sh 'echo "All Automated Tests Passed (100% Success)"'
            }
        }
        stage('Package & Archive') {
            steps {
                echo 'Packaging application artifact...'
                sh 'echo "Artifact packaged: app-v1.0.tar.gz"'
            }
        }
    }

    post {
        success {
            echo 'Build and Test completed successfully! Ready for deployment.'
        }
    }
}
```
4. Click **Save** &rarr; Click **Build Now**.
5. Observe the Stage View render every stage in green!

---

## 🧹 Teardown & Cleanup

```bash
docker rm -f jenkins
```
Or execute:
- Linux / macOS / WSL: `./cleanup.sh`
- Windows PowerShell: `.\cleanup.ps1`
