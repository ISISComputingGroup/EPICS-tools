#!groovy

pipeline {

  // agent defines where the pipeline will run.
  agent {
    label {
      label("ndw1757")
    }
  }

  environment {
      NODE = "${env.NODE_NAME}"
  }

  // The options directive is for configuration that applies to the whole job.
  options {
    buildDiscarder(logRotator(numToKeepStr:'5', daysToKeepStr: '7'))
    disableConcurrentBuilds()
    // as we "checkout scm" as a stage, we do not need to do it here too
    skipDefaultCheckout(true)
    timestamps()
  }

  stages {
    stage("Checkout") {
      steps {
        timeout(time: 2, unit: 'HOURS') {
          checkout scm
        }
      }
    }
    
    stage("Build") {
        steps {
            echo "Building"
            timeout(time: 16, unit: 'HOURS') {
                echo "Branch: ${env.BRANCH_NAME}"
                echo "Build Number: ${env.BUILD_NUMBER}"
                bat """
                    jenkins_build.bat
                """
            }
        }
    }
  }

}