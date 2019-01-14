pipeline {
    agent any
    environment {
      DOCKER_REGISTRY = 'docker.io'
      ORG          = 'jenkinsxio'
      APP_NAME     = 'oauth2_proxy'
      GIT_PROVIDER = 'github.com'
      GIT_CREDS    = credentials('jx-pipeline-git-github-github')
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/bitly/oauth2_proxy') {
            checkout scm

            sh "make test release-binary"

            sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml'

            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }
        }
      }
      stage('Build Release') {
        environment {
          CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
        }
        when {
          branch 'master'
        }
        steps {
            dir ('/home/jenkins/go/src/github.com/bitly/oauth2_proxy') {
              git 'https://github.com/jenkins-x/oauth2_proxy'
            }
            dir ('/home/jenkins/go/src/github.com/bitly/oauth2_proxy') {
                // ensure we're not on a detached head
                sh "git checkout master"

                sh "git config --global credential.helper store"
                sh "jx step git credentials"
            }
            dir ('/home/jenkins/go/src/github.com/bitly/oauth2_proxy') {
              // so we can retrieve the version in later steps
              sh "echo \$(jx-release-version) > VERSION"
            }
            dir ('/home/jenkins/go/src/github.com/bitly/oauth2_proxy') {

              sh "make test release-binary"
              sh 'export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml'

              sh "jx step tag --version \$(cat VERSION)"
              sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"

            }
            dir ('/home/jenkins/go/src/github.com/bitly/oauth2_proxy/charts/oauth2_proxy/FIXME/THIS/NEEDS/TO/BE/DONE') {
              sh "make release"
            }
        }
      }
    }
  }
