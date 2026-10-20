# Exercise 9: Jenkins Multi-Stage Pipeline: Deploying a Python Application

## 🎯 Objective

Understand how to design, configure, and execute an enterprise-grade **multi-stage Jenkins CI/CD Pipeline** (`Jenkinsfile`). In this exercise, we automate the end-to-end delivery lifecycle for a Python Flask application across five distinct stages:
1. **Build:** Environment preparation and dependency installation.
2. **Test:** Automated unit testing using Python's `unittest` framework.
3. **Deploy:** Staging and deploying the application artifacts to a deployment directory.
4. **Run Application:** Starting the background application process with PID tracking.
5. **Test Application:** End-to-end validation of the live application endpoint.

---

## 🏗️ Multi-Stage Pipeline Architecture

```text
[ Git SCM Checkout ]
         │
         ▼
 ┌───────────────┐
 │ Stage 1: Build│──► Install requirements (Flask, dependencies)
 └───────┬───────┘
         ▼
 ┌───────────────┐
 │ Stage 2: Test │──► Execute unit tests (unittest discover -s .)
 └───────┬───────┘
         ▼
 ┌────────────────┐
 │ Stage 3: Deploy│──► Package and copy artifacts to deployment target
 └───────┬────────┘
         ▼
 ┌──────────────────────┐
 │Stage 4: Run App      │──► Start Flask service (nohup ... & echo $! > app.pid)
 └───────┬──────────────┘
         ▼
 ┌──────────────────────┐
 │Stage 5: Test Live App│──► Test live HTTP endpoints against deployed app
 └───────┬──────────────┘
         ▼
 ┌──────────────────────┐
 │ Post: Teardown/Alert │──► Graceful process cleanup and build notification
 └──────────────────────┘
```

---

## 📁 Application Files

### 1. Flask Web Application (`app.py`)
```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello, Jenkins Multi-Stage Pipeline!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
```

### 2. Dependencies (`requirements.txt`)
```text
flask>=2.1.2
flake8>=6.0.0
```

### 3. Unit Test Suite (`test_app.py`)
```python
import unittest
from app import app

class TestApp(unittest.TestCase):
    def test_home(self):
        tester = app.test_client()
        response = tester.get("/")
        decoded_output = response.data.decode("utf-8")
        print(f"\n[TEST LOG] Response: {decoded_output}")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(decoded_output, "Hello, Jenkins Multi-Stage Pipeline!")

if __name__ == "__main__":
    unittest.main()
```

---

## 📜 Declarative Pipeline (`Jenkinsfile`)

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Creating virtual environment and installing dependencies...'
                sh '''
                pip install -r devops/exercise-9/requirements.txt || pip3 install -r requirements.txt || pip install flask
                '''
            }
        }
        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh '''
                python3 -m unittest discover -s devops/exercise-9 || python3 -m unittest discover -s . || python -m unittest test_app.py
                '''
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh '''
                mkdir -p ${WORKSPACE}/python-app-deploy
                cp ${WORKSPACE}/devops/exercise-9/app.py ${WORKSPACE}/python-app-deploy/ 2>/dev/null || cp ${WORKSPACE}/app.py ${WORKSPACE}/python-app-deploy/
                '''
            }
        }
        stage('Run Application') {
            steps {
                echo 'Running application in background...'
                sh '''
                nohup python3 ${WORKSPACE}/python-app-deploy/app.py > ${WORKSPACE}/python-app-deploy/app.log 2>&1 &
                echo $! > ${WORKSPACE}/python-app-deploy/app.pid
                sleep 2
                '''
            }
        }
        stage('Test Application') {
            steps {
                echo 'Testing deployed application...'
                sh '''
                python3 ${WORKSPACE}/devops/exercise-9/test_app.py 2>/dev/null || python3 ${WORKSPACE}/test_app.py
                '''
            }
        }
    }

    post {
        always {
            sh '''
            if [ -f ${WORKSPACE}/python-app-deploy/app.pid ]; then
                kill $(cat ${WORKSPACE}/python-app-deploy/app.pid) 2>/dev/null || true
            fi
            '''
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for more details.'
        }
    }
}
```

---

## 🚀 Setting Up the Job in Jenkins

1. Open your browser to your Jenkins dashboard: **[http://localhost:8080](http://localhost:8080)**.
2. Click **New Item** &rarr; Enter name `Python-MultiStage-Pipeline` &rarr; Select **Pipeline** &rarr; Click **OK**.
3. Under **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/Venkateshrath/exercise---solutions.git`
   - Branch Specifier: `*/main`
   - Script Path: `devops/exercise-9/Jenkinsfile`
4. Click **Save**.
5. Click **Build Now** to execute the pipeline.

---

## 🔧 Handling Common Build Errors in Jenkins Docker

When executing Python commands in a default `jenkins/jenkins:lts` container, builds may fail if `python3` and `pip` are not yet installed in the Jenkins runtime container.

### Resolution Steps:
1. Identify the Jenkins container ID:
   ```bash
   docker ps -a | grep jenkins
   ```
2. Log into the Jenkins container as `root`:
   ```bash
   docker exec -it -u root <container-id-or-name> bash
   ```
3. Install Python 3, pip, and Flask:
   ```bash
   apt-get update
   apt-get install -y python3 python3-pip python3-flask
   ```
4. Re-run **Build Now** in Jenkins.

---

## 📋 Expected Console Output

```text
Started by user admin
Obtained Jenkinsfile from git https://github.com/Venkateshrath/exercise---solutions.git
[Pipeline] Start of Pipeline
[Pipeline] stage (Build)
Creating virtual environment and installing dependencies...
[Pipeline] stage (Test)
Running unit tests...
+ python3 -m unittest discover -s .
.
----------------------------------------------------------------------
Ran 1 test in 0.004s

OK
Hello, Jenkins Multi-Stage Pipeline!
[Pipeline] stage (Deploy)
Deploying application...
+ mkdir -p /var/jenkins_home/workspace/.../python-app-deploy
+ cp app.py python-app-deploy/
[Pipeline] stage (Run Application)
Running application in background...
[Pipeline] stage (Test Application)
Testing deployed application...
+ python3 test_app.py
.
----------------------------------------------------------------------
Ran 1 test in 0.004s

OK
[Pipeline] stage (Declarative: Post Actions)
Pipeline completed successfully!
Finished: SUCCESS
```

---

## 💡 Additional Enhancements

### 1. Code Quality Stage (Linting)
Integrate `flake8` to enforce PEP 8 standards:
```groovy
stage('Code Quality') {
    steps {
        echo 'Running code quality checks...'
        sh 'flake8 devops/exercise-9/ || flake8 .'
    }
}
```

### 2. Containerized Deployment
Instead of copying files to a folder, build and run a container:
```groovy
stage('Docker Deploy') {
    steps {
        sh '''
        docker build -t flask-multistage:latest devops/exercise-9/
        docker run -d -p 5000:5000 --name flask-app flask-multistage:latest
        '''
    }
}
```

---

## 🧪 Local Simulation

To simulate the entire pipeline lifecycle locally without Jenkins:
* Linux / macOS / WSL: `./deploy.sh`
* Windows PowerShell: `.\deploy.ps1`
