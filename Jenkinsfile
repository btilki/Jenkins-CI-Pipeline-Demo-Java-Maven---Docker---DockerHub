pipeline {
  agent any

  // configure image name and tag; tag can be set by build number
  environment {
    IMAGE_NAME = "sample-java-app"
    IMAGE_TAG = "${env.BUILD_NUMBER}"
    // dockerhub credential ID (create this in Jenkins credentials as 'Username with password')
    DOCKERHUB_CREDENTIALS_ID = "dockerhub-creds"
  }

  stages {
    stage('Checkout') {
      steps {
        // For Multibranch pipeline, checkout scm is usually enough.
        checkout scm
      }
    }

    stage('Build Jar') {
      steps {
        // If Jenkins agent has maven installed and in PATH
        sh 'mvn -B -DskipTests clean package'

        // archive artifact to Jenkins (optional)
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    stage('Build Docker Image') {
      steps {
        // Tag image temporarily; push step will retag/push with docker credentials
        script {
          // Try to use DOCKER_USER from credentials on push stage; for building we tag to a local name
          sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        // Use withCredentials to provide username/password for docker login
        withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            // Full image name is <dockerhub-username>/<repo>:tag
            def fullImage = "${env.DOCKER_USER}/${env.IMAGE_NAME}:${env.IMAGE_TAG}"
            sh "docker tag ${env.IMAGE_NAME}:${env.IMAGE_TAG} ${fullImage}"
            sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
            sh "docker push ${fullImage}"
          }
        }
      }
    }
  }

  post {
    success {
      echo "Build and push succeeded: ${IMAGE_NAME}:${IMAGE_TAG}"
    }
    failure {
      echo "Build or push failed"
    }
  }
}