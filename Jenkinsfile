pipeline{
    
    agent any 
    
    stages {
        stage('Git Checkout'){
            steps{
                script{
                    git branch: 'main', url: 'https://github.com/ariwijayaikd/demo-counter-app.git'
                }
            }
        }
        stage('UNIT testing'){
            steps{
                script{
                    sh 'mvn test'
                }
            }
        }
        stage('Integration testing'){
            steps{
                script{
                    sh 'mvn verify -DskipUnitTests'
                }
            }
        }
        stage('Maven build'){
            steps{
                script{
                    sh 'mvn clean install'
                }
            }
        }
        stage('SonarQube analysis'){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonarserver', installationName: 'sonarserver2'){
                        sh 'mvn clean package sonar:sonar'
                    }
                }
            }
        }
        stage('Quality Gate Status'){
            steps{
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonarserver'
                }
            }
        }

        stage('Upload jar file to Nexus Repo'){
            steps{
                script{
                    def pom = readMavenPom file: 'pom.xml'

                    def nexusrepo = pom.version.endsWith("SNAPSHOT") ? "counterapp-dev" : "counterapp"

                    nexusArtifactUploader artifacts: 
                    [
                        [
                            artifactId: 'springboot', 
                            classifier: '', 
                            file: 'target/Uber.jar', 
                            type: 'jar'
                        ]
                    ], 
                    credentialsId: 'nexus-auth',
                    groupId: 'com.example', 
                    nexusUrl: '10.2.155.210:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: "${nexusrepo}", 
                    version: "${pom.version}"
                }
            }
        }

        stage('Build Docker Image'){
            steps{
                git 'https:/github.com/ariwijayaikd/demo-counter-app.git'
                sh 'docker build -t $JOB_NAME:v1.$BUILD.ID .'
                sh 'docker image tag $JOB_NAME:v1.$BUILD.ID ariwijayaikd/$JOB_NAME:v1.$BUILD.ID'
                sh 'docker image tag $JOB_NAME:v1.$BUILD.ID ariwijayaikd/$JOB_NAME:latest'
            }
        }

        stage('Push'){
            steps{
            withCredentials([usernamePassword(credentialsId: ‘docker-hub’, usernameVariable: ‘DOCKER_USERNAME’, passwordVariable: ‘DOCKER_PASSWORD’)]) {
            sh ‘docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD’
            sh ‘docker push my-image:${BUILD_NUMBER}’
            }
            }
        }
    }  
}