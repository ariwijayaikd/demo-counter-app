pipeline{
    
    agent any 
    
    stages {
        stage('Git Checkout'){
            steps{
                script{
                    git branch: 'main', url: 'https://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@github.com/ariwijayaikd/demo-counter-app.git'
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
                    repository: 'counterapp', 
                    version: "${pom.version}"
                }
            }
        }
    }  
}