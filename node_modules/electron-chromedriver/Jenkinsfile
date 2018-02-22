pipeline {
  agent  {
    label 'osx'
  }
  stages {
    stage('NPM install and test') {
      steps {
        timeout(60) {
          sh 'npm install'
          sh 'node --version'
          sh 'npm --version'
          sh 'npm test'
        }
      }
      post {
        always {
          cleanWs()
        }
      }
    }
  }
}
