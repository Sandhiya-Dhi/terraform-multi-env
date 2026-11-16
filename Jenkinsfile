
pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'qa'],
            description: 'Select environment to deploy or destroy'
        )

        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Select Terraform action'
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
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform plan -var-file=terraform.tfvars -out=tfplan -input=false'
                }
            }
        }

        stage('Apply Approval') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    input message: "Approve APPLY for ${params.ENVIRONMENT}?"
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }

        stage('Terraform Destroy Plan') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform plan -destroy -var-file=terraform.tfvars -out=destroy.tfplan -input=false'
                }
            }
        }

        stage('Destroy Approval') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    input message: "WARNING: Approve DESTROY for ${params.ENVIRONMENT}? This will delete its managed infrastructure."
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform apply -input=false destroy.tfplan'
                }
            }
        }
    }

    post {
        success {
            echo "Terraform ${params.ACTION} completed successfully for ${params.ENVIRONMENT}"
        }

        failure {
            echo "Terraform pipeline failed for ${params.ENVIRONMENT}"
        }

        always {
            echo "Pipeline execution finished."
        }
    }
}
