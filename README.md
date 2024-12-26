# Jenkins on Docker Setup with Pipeline for Website Deployment

This guide will walk you through the process of automating the setup of Jenkins on Docker, configuring pipelines, and deploying a website container on the same EC2 instance.

## Step-by-Step Implementation

## INstalll

    apt update && apt upgrade -y && apt install -y apt-transport-https ca-certificates curl software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && apt update && apt install -y docker-ce docker-ce-cli containerd.io && curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt install -y nodejs && apt install -y build-essential git && systemctl enable docker && systemctl start docker


---

### 1. EC2 Instance Setup /VMware

1. **Install Docker**:
   First, install Docker on your EC2 instance:
   ```bash
   sudo apt-get update -y
   sudo apt-get install -y docker.io
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

2. **Run the Jenkins Container**:
   Run Jenkins in a Docker container, mapping necessary ports and volumes:
   ```bash
   docker run -d \
     --name jenkins \
     -p 8080:8080 \
     -p 50000:50000 \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v jenkins_home:/var/jenkins_home \
     jenkins/jenkins:lts
   ```

3. **Access Jenkins**:
   Open your browser and navigate to:
   ```
   http://<your-ec2-public-ip>:8080
   ```
   Retrieve the initial admin password to unlock Jenkins:
   ```bash
   sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```

---

### 2. Jenkins Initial Configuration

1. **Install Plugins**:
   Install the following plugins to enhance Jenkins functionality:
   - **Pipeline** (For CI/CD pipelines)
   - **Docker Pipeline** (For Docker integration)
   - **Git** (For GitHub repository access)

2. **Configure Credentials**:
   - Add **GitHub credentials** to enable Jenkins to clone repositories.
   - Add **Docker Hub credentials** if your Docker images are private.

3. **Verify Docker Permissions**:
   Ensure Jenkins has permission to run Docker commands by adding the Jenkins user to the Docker group:
   ```bash
   docker exec -it jenkins bash
   usermod -aG docker jenkins
   exit
   ```

---

### 3. Create a Jenkins Pipeline

1. **Pipeline Script**:
   - Navigate to **Jenkins Dashboard** > **New Item** > **Pipeline** > **Pipeline Definition (Pipeline Script)**, and paste the following script:

   ```groovy
   pipeline {
       agent any
       environment {
           DOCKER_IMAGE = 'pb26uk/khushi:latest'
           WEBSITE_CONTAINER_NAME = 'website-container'
       }
       stages {
           stage('Clone Repository') {
               steps {
                   // Pull code from GitHub
                   git branch: 'main', url: 'https://github.com/your-repo/your-project.git'
               }
           }
           stage('Pull Docker Image') {
               steps {
                   // Pull the latest Docker image from Docker Hub
                   sh 'docker pull $DOCKER_IMAGE'
               }
           }
           stage('Deploy Website') {
               steps {
                   // Stop and remove the existing container
                   sh """
                   docker stop $WEBSITE_CONTAINER_NAME || true
                   docker rm $WEBSITE_CONTAINER_NAME || true
                   """
                   // Run a new container with the updated image
                   sh """
                   docker run -d \
                       --name $WEBSITE_CONTAINER_NAME \
                       -p 80:80 \
                       $DOCKER_IMAGE
                   """
               }
           }
       }
   }
   ```

### 2. **Save and Build**:

      docker run -d   --name khushi-container   --network jenkins_network   -p 80:80 -e PORT=80  -v /var/run/docker.sock:/var/run/docker.sock  khushi
      
      - Save the pipeline script and click **Save**.

       docker run -d \
      --name jenkins \
       --network jenkins_network \
       -p 8080:8080 -p 50000:50000 \
       -v /var/run/docker.sock:/var/run/docker.sock \
        jenkins/jenkins:lts

   - Save the pipeline and trigger a build. Jenkins will:
     - Pull the source code from GitHub.
     - Pull the latest Docker image from Docker Hub.
     - Stop and remove the existing website container.
     - Deploy the updated website container.

---

### 4. Docker Networking

Ensure both containers are on the same Docker network to enable communication:
```bash
docker network create jenkins-network
docker network connect jenkins-network jenkins
docker network connect jenkins-network website-container
```

---

### 5. Test the Setup

1. Open a browser and navigate to the deployed website:
   ```
   http://<your-ec2-public-ip>:80
   ```

2. Verify that the changes from GitHub and Docker Hub are reflected in the website.

---

### Security and Optimization Tips

1. **Secure Docker Socket**:
   - Use **docker-socket-proxy** to limit Jenkins' access to Docker for improved security.

2. **Optimize Resources**:
   - Monitor the EC2 instance's resource usage with tools like `htop` or `docker stats` to ensure efficient use of CPU and memory.

3. **Backup Jenkins**:
   - Regularly back up the `jenkins_home` directory to avoid data loss.

---

### Conclusion

This setup ensures seamless CI/CD operations with Jenkins and Docker on the same EC2 instance. It automates the entire process of setting up Jenkins, configuring pipelines, pulling Docker images, and deploying containers. Let me know if you need further assistance!
```
