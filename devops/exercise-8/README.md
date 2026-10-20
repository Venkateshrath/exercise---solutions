# Exercise 8: Creating "Hello World" Jenkins Job

## 🎯 Objective
Learn how to create, configure, and execute an automated **Jenkins Freestyle Job** that checks out code from your GitHub repository and executes a shell script (`hello-world.sh`), verifying the automated CI build lifecycle and inspecting console output.

---

## 🛠️ Step-by-Step Implementation

### Step 1: Create the Script (`hello-world.sh`)

Create a script named `hello-world.sh`:

```bash
#!/bin/bash
echo "Hello, Jenkins!"
```

Make the script executable:
```bash
chmod +x hello-world.sh
```

---

### Step 2: Access Jenkins

1. Open your browser and navigate to your running Jenkins instance:
   * **URL:** [http://localhost:8080](http://localhost:8080)
2. Log in using your Jenkins administrator credentials.

---

### Step 3: Create a New Freestyle Job

1. On the Jenkins dashboard, click **New Item** in the left-hand navigation menu.
2. Enter the item name: `HelloWorld`.
3. Select **Freestyle project**.
4. Click **OK** to proceed to the configuration page.

---

### Step 4: Configure the Job

#### 1. General Settings
* **Description:**
  ```text
  Hello World! Jenkins automation job for DevOps exercise series.
  ```

#### 2. Source Code Management (SCM)
* Select **Git**.
* **Repository URL:**
  ```text
  https://github.com/Venkateshrath/exercise---solutions.git
  ```
* **Credentials:** None needed (the repository is public) or your GitHub credential if private.
* **Branches to build:** `*/main`

#### 3. Build Steps
* Click **Add build step** &rarr; select **Execute shell** (or **Execute Windows batch command** / **PowerShell** if running on Windows native agent).
* Enter the command to run:
  ```bash
  sh devops/exercise-8/hello-world.sh
  ```
  *(Or if executing inside the folder: `cd devops/exercise-8 && sh hello-world.sh`)*

---

### Step 5: Save and Run the Job

1. Click **Save** at the bottom of the page.
2. On the `HelloWorld` job page, click **Build Now** from the left-hand menu.
3. Observe build `#1` appear in the **Build History** box with a blue (or green) status ball indicating success.

---

### Step 6: View the Build Output

1. Under **Build History**, click on build number **#1**.
2. Click **Console Output** in the left menu.
3. Verify the execution log:

```text
Started by user Admin
Running as SYSTEM
Building in workspace /var/jenkins_home/workspace/HelloWorld
Selected Git installation does not exist. Using default
The recommended git tool is: NONE
using credential ...
 > git rev-parse --resolve-git-dir /var/jenkins_home/workspace/HelloWorld/.git # timeout=10
Fetching changes from the remote Git repository
 > git config remote.origin.url https://github.com/Venkateshrath/exercise---solutions.git # timeout=10
Fetching upstream changes from https://github.com/Venkateshrath/exercise---solutions.git
 > git --version # timeout=10
 > git fetch --tags --force --progress -- https://github.com/Venkateshrath/exercise---solutions.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/main^{commit} # timeout=10
Checking out Revision 03c2c39 (refs/remotes/origin/main)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 03c2c39...
Commit message: "Add Exercise 7: Introduction to CI and Jenkins Installation"
[HelloWorld] $ /bin/sh -xe /tmp/jenkins1281930102.sh
+ sh devops/exercise-8/hello-world.sh
Hello, Jenkins!
Finished: SUCCESS
```

---

## ⚡ Modern Jenkins Alternative: Pipeline as Code (`Jenkinsfile`)

In addition to Freestyle projects, industry best practices recommend defining pipelines as code using a [`Jenkinsfile`](./Jenkinsfile):

```groovy
pipeline {
    agent any

    stages {
        stage('Execute Script') {
            steps {
                echo 'Running hello-world.sh...'
                sh 'sh devops/exercise-8/hello-world.sh || sh hello-world.sh'
            }
        }
    }

    post {
        success {
            echo 'HelloWorld Jenkins job completed successfully!'
        }
        failure {
            echo 'HelloWorld Jenkins job failed.'
        }
    }
}
```

To run this pipeline:
1. Click **New Item** &rarr; Name it `HelloWorld-Pipeline` &rarr; Select **Pipeline**.
2. Under **Pipeline Definition**, select **Pipeline script from SCM**.
3. Choose **Git**, provide `https://github.com/Venkateshrath/exercise---solutions.git`, branch `*/main`, and script path `devops/exercise-8/Jenkinsfile`.
4. Click **Save** &rarr; **Build Now**.

---

## 🧪 Local Verification

Run the test script to verify script execution locally:
* Linux / macOS / WSL: `./test_job.sh`
* Windows PowerShell: `.\test_job.ps1`
