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
                script{
                    sh 'docker build -t $JOB_NAME:v1.$BUILD_ID .'
                    sh 'docker image tag $JOB_NAME:v1.$BUILD_ID ariwijayaikd/$JOB_NAME:v1.$BUILD_ID'
                    sh 'docker image tag $JOB_NAME:v1.$BUILD_ID ariwijayaikd/$JOB_NAME:latest'
                }
            }
        }

        stage('Push Docker Image to Docker Hub'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-auth', usernameVariable: 'UNAME', passwordVariable: 'PASS')]) {
                    sh 'docker login -u $UNAME -p $PASS'
                    sh 'docker push ariwijayaikd/$JOB_NAME:v1.$BUILD_ID'
                    sh 'docker push ariwijayaikd/$JOB_NAME:latest'
                    }
                }
            }
        }
    }  
}