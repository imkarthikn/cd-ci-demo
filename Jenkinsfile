def CONTAINER_NAME="demo-build"
def CONTAINER_TAG="latest"
def DOCKER_HUB_USER="imkarthikn"
def HTTP_PORT="8090"
env.docker = '/var/jenkins_home/docker/docker'
node {

    stage('Initialize'){
        def dockerHome = tool 'mydocker'
        def mavenHome  = tool 'mymaven'
        def docker = '/var/jenkins_home/docker/docker'
        env.PATH = "${dockerHome}/bin:${mavenHome}/bin:$docker:${env.PATH}"
    }

    stage('Checkout') {
        checkout scm
    }

    stage('Build'){
        sh "mvn clean install"
    }

    stage('Static code'){
        try {
            sh "mvn sonar:sonar"
        } catch(error){
            echo "The sonar server could not be reached ${error}"
        }
     }

    stage("Image clean up"){
        imagePrune(CONTAINER_NAME)
    }

    stage('Docker Build'){
        imageBuild(CONTAINER_NAME, CONTAINER_TAG)
    }

    stage('Push to Docker Registry'){
        withCredentials([usernamePassword(credentialsId: 'kkdockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            pushToImage(CONTAINER_NAME, CONTAINER_TAG, USERNAME, PASSWORD)
        }
    }

    stage('APP Deploy'){
        runApp(CONTAINER_NAME, CONTAINER_TAG, DOCKER_HUB_USER, HTTP_PORT)
    }

}

def imagePrune(containerName){
    try {
        sh "/var/jenkins_home/docker/docker -v"
        sh "/var/jenkins_home/docker/docker image prune -f"
        sh "/var/jenkins_home/docker/docker stop $containerName"
    } catch(error){}
}

def imageBuild(containerName, tag){
    sh "/var/jenkins_home/docker/docker build -t $containerName:$tag  -t $containerName --pull --no-cache ."
    echo "Image build complete"
}

def pushToImage(containerName, tag, dockerUser, dockerPassword){
    sh "/var/jenkins_home/docker/docker login -u $dockerUser -p $dockerPassword"
    sh "/var/jenkins_home/docker/docker tag $containerName:$tag $dockerUser/$containerName:$tag"
    sh "/var/jenkins_home/docker/docker push $dockerUser/$containerName:$tag"
    echo "Image push complete"
}

def runApp(containerName, tag, dockerHubUser, httpPort){
    sh "/var/jenkins_home/docker/docker pull $dockerHubUser/$containerName"
    sh "/var/jenkins_home/docker/docker run -d --rm -p $httpPort:$httpPort --name $containerName $dockerHubUser/$containerName:$tag"
    echo "Application started on port: ${httpPort} (http)"
}
