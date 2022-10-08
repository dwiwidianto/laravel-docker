pipeline {
    environment {
        GITHUB_REPO = 'https://github.com/dwiwidianto/laravel-docker.git#main'
        TAG_DOCKER_PHP = "registry.gitlab.com/dwiwidianto/laravel-docker:php"
        TAG_DOCKER_NGINX = "registry.gitlab.com/dwiwidianto/laravel-docker:webserver"
        BUILD_IMAGE_1 = "docker build ${GITHUB_REPO} -f docker/dockerfile/php.Dockerfile  -t ${TAG_DOCKER_PHP}"
        BUILD_IMAGE_2 = "docker build ${GITHUB_REPO} -f docker/dockerfile/webserver.Dockerfile -t ${TAG_DOCKER_NGINX}"
        DISCORD_WEBHOOK = ""
    }
    agent any
    stages {
        stage('Build Docker Images') {
            steps {
                sh '${BUILD_IMAGE_1} && ${BUILD_IMAGE_2}' 
            }
        }
        stage('Push Image to Gitlab Regsitry') {
            steps {
                sh 'docker push ${TAG_DOCKER_PHP} && docker push ${TAG_DOCKER_NGINX}' 
            }
        }
        stage('Update Deployment') {
            steps {
                sh 'docker compose up -d' 
            }
        }
    }

    post('Send Notification to Discord') {
        always {
                discordSend description: "Jenkins Pipeline Build", link: env.BUILD_URL, showChangeset: true, result: currentBuild.currentResult, title: env.JOB_NAME, webhookURL: "${DISCORD_WEBHOOK}"
        }
    }
}