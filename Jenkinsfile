pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '555044956356.dkr.ecr.us-east-1.amazonaws.com/ruhi-2048-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        TRIVY_IMAGE = 'aquasec/trivy:0.69.3'
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Source') {
            steps {
                git branch: 'main', url: 'https://github.com/AlRuh-ux/ruhi-devops-pipeline.git'
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
                sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO'
                sh 'docker push $ECR_REPO:$IMAGE_TAG'
            }
        }

        stage('Scan') {
            // Trivy is pinned to an exact version on purpose: never use the "latest" tag for a scanner.
            // The image is saved to a tar file and copied into the scanner container with "docker cp".
            // Jenkins itself runs in a container, so a bind mount of its workspace would not be visible
            // to the Docker host. The Docker socket is never mounted into the scanner.
            steps {
                sh 'docker save $ECR_REPO:$IMAGE_TAG -o image.tar'
                sh '''
                    scan() {
                        docker rm -f trivy-scan >/dev/null 2>&1 || true
                        docker create --name trivy-scan -v trivy-cache:/root/.cache/ $TRIVY_IMAGE image --input /tmp/image.tar --scanners vuln --no-progress --ignore-unfixed "$@" >/dev/null
                        docker cp image.tar trivy-scan:/tmp/image.tar
                        docker start -a trivy-scan
                        rc=$?
                        docker rm trivy-scan >/dev/null
                        return $rc
                    }
                    # Report HIGH and CRITICAL findings that have a fix available
                    scan --severity HIGH,CRITICAL
                    # Fail the pipeline on CRITICAL findings that have a fix available
                    scan --severity CRITICAL --exit-code 1
                '''
            }
            post {
                always {
                    sh 'rm -f image.tar'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'docker rm -f test-container || true'
                sh 'docker run -d --name test-container $ECR_REPO:$IMAGE_TAG'
                sh 'sleep 5'
                sh 'docker exec test-container wget -q -O- http://localhost:80 | grep -q "2048" && echo "Test passed"'
                sh 'docker stop test-container && docker rm test-container'
            }
        }

        stage('Deploy') {
            steps {
                sh 'helm upgrade ruhi-2048 ./helm/ruhi-2048 --namespace ruhi-2048 --set image.tag=$IMAGE_TAG'
            }
        }
    }
}
