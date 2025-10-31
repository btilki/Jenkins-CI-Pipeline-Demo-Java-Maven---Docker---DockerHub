# Jenkins CI Pipeline Demo: Java Maven -> Docker -> DockerHub

This repository is a minimal demo project that shows a complete CI pipeline for a Java Maven application using Jenkins. The pipeline builds the JAR, builds a Docker image, and pushes the image to a private Docker Hub repository.

Technologies used
- Jenkins (with Pipeline)
- Docker (on Jenkins host/agent)
- Linux
- Git
- Java 11 (openjdk)
- Maven

What’s included
- A tiny Java Maven app (src/)
- pom.xml
- Dockerfile
- Jenkinsfile (Declarative Pipeline)
- .dockerignore, .gitignore

Goal
- Use Jenkins to: checkout code, build JAR with Maven, build Docker image, push image to private DockerHub repository.

Getting started — prerequisites
1. A running Jenkins server (LTS recommended).
2. Docker installed on the Jenkins server or agent that runs pipeline builds.
3. Jenkins user in the docker group (or use dind).
4. Docker Hub account and a private repository (or use docker.io/<your_username>/<repo>).
5. Maven (or use Docker-based maven image in pipeline) and optionally Node if you need it for frontend steps.
6. Git repo (this project) pushed to GitHub (instructions below).

Project structure
- Jenkinsfile
- Dockerfile
- pom.xml
- src/main/java/com/example/App.java
- .gitignore
- .dockerignore
- README.md

Jenkins configuration (step-by-step)

1) Install Plugins (via Manage Jenkins -> Manage Plugins)
- Pipeline
- Git plugin
- GitHub Branch Source (if you want Multibranch)
- Docker Pipeline (recommended)
- Credentials Binding Plugin

2) Make Docker available to Jenkins
Option A (recommended for a single Jenkins server with Docker installed):
- Install Docker on Jenkins host (apt/yum).
- Add user `jenkins` to the `docker` group: `sudo usermod -aG docker jenkins`
- Restart Jenkins so it can access docker socket `/var/run/docker.sock`.

Option B (containers): Use Docker-in-Docker or a Docker agent that has access to the Docker socket.

3) Configure Build Tools (Manage Jenkins -> Global Tool Configuration)
- Add Maven installation (name it e.g. `M3`) or leave out if you prefer using Maven Docker image in the pipeline.
- Add NodeJS installation if required (e.g. for frontend builds).

4) Add Jenkins credentials
- Docker Hub credentials:
  - Kind: Username with password
  - ID: `dockerhub-creds` (or a name you choose; use this ID in the Jenkinsfile or job)
- Git credentials (if using private repo):
  - Kind: Username with password or SSH Username with private key
  - ID: `git-creds` (or choose your own)
Make sure to note the credential IDs; the Jenkinsfile uses `dockerhub-creds` by default.

5) Create a Jenkins job
You can use different job types:

A. Multibranch Pipeline (recommended for GitHub branches)
- New Item -> Multibranch Pipeline
- Branch Sources -> Add GitHub or Git
- Provide repository URL and credentials (the Git credentials above).
- Jenkins will scan the repo, find the Jenkinsfile and create branch jobs automatically.

B. Pipeline job (single branch)
- New Item -> Pipeline
- In Pipeline definition select "Pipeline script from SCM -> Git"
- Repository URL -> your GitHub repo
- Credentials -> `git-creds`
- Branch -> main (or master)
- Script Path -> Jenkinsfile

C. Freestyle job (less preferred)
- You can create a Freestyle job that checks out code, runs shell build steps (mvn), docker build and docker push using shell build steps. Prefer Pipeline for better reproducibility.

Jenkinsfile overview
- Checkout: uses `checkout scm` (works for Multibranch or Pipeline-from-SCM).
- Build: `mvn -B -DskipTests clean package`
- Build Docker image: `docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} .`
- Push image: uses `withCredentials` to login to Docker Hub using `dockerhub-creds`.

How to push this repo to GitHub (local commands)
1. Create a new GitHub repository (e.g., `jenkins-ci-demo`).
2. Locally:
   git init
   git remote add origin git@github.com:<your_username>/jenkins-ci-demo.git
   git add .
   git commit -m "Initial commit - Jenkins CI demo"
   git push -u origin main

Notes and tips
- If your Jenkins agents do not have Maven, you can run Maven inside a container in the Jenkinsfile (see alternate examples).
- For pushing to a private Docker Hub repo, ensure the repository exists and the Jenkins Docker Hub user has push permissions.
- If Docker push fails with permission denied, re-check credentials and repo name (`<dockerhub-user>/<repo>`).

License
- Use this sample freely in your portfolio.
