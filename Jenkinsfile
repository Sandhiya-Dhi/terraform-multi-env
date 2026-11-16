
pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'qa'],
            description: 'Select environment to deploy'
        )
    }

    environment {
        TF_IN_AUTOMATION = 'true'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform init -reconfigure -backend-config=backend.hcl -input=false'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform plan -var-file=terraform.tfvars -out=tfplan -input=false'
                }
            }
        }

        stage('Approval') {
            steps {
                input message: "Approve deployment to ${params.ENVIRONMENT}?"
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
    }
}

