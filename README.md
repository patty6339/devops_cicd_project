# DevOps CI/CD Project

This project implements a CI/CD pipeline using GitHub Actions, Terraform, Docker, and AWS ECR.

## Running the Application

### Option 1: Using GitHub Actions CI/CD Pipeline

1. Push changes to the main branch to trigger the workflow
2. The workflow will:
   - Deploy infrastructure using Terraform
   - Build and push Docker image to ECR
   - Deploy the application to EC2

### Option 2: Manual Deployment

#### Prerequisites
- AWS CLI configured with appropriate permissions
- Docker installed
- Terraform installed

#### Steps

1. Deploy infrastructure:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

2. Build and push Docker image:
   ```bash
   cd nodeapp
   aws ecr get-login-password | docker login --username AWS --password-stdin <your-ecr-repo-url>
   docker build -t <your-ecr-repo-url>:latest .
   docker push <your-ecr-repo-url>:latest
   ```

3. SSH into EC2 and run the container:
   ```bash
   ssh ubuntu@<ec2-public-ip> -i your-key.pem
   
   # Login to ECR
   aws ecr get-login-password | sudo docker login --username AWS --password-stdin <your-ecr-repo-url>
   
   # Run the container
   sudo docker run -d --name myappcontainer -p 80:8080 <your-ecr-repo-url>:latest
   ```

## Checking Application Status

After deployment, you can check the application status in several ways:

### 1. Using the check_app.sh script

```bash
chmod +x check_app.sh
./check_app.sh <ec2-public-ip>
```

### 2. Manually via SSH

```bash
# SSH into the EC2 instance
ssh ubuntu@<ec2-public-ip> -i your-key.pem

# Check if the container is running
sudo docker ps

# View container logs
sudo docker logs myappcontainer

# Check application response
curl http://localhost
```

### 3. Web Browser

Open your web browser and navigate to: `http://<ec2-public-ip>/`

## Accessing the Application

After successful deployment, the application is available at:

```
http://<ec2-public-ip>/
```

Where `<ec2-public-ip>` is the public IP address of your EC2 instance. You can find this IP:

1. In the GitHub Actions workflow output
2. In the AWS EC2 Console
3. By running `terraform output instance_public_ip` in the terraform directory

## Troubleshooting

If the application is not responding or you see "ERR_CONNECTION_TIMED_OUT":

### 1. Security Group Issues
- Verify the EC2 security group allows inbound traffic on port 80 from your IP address or 0.0.0.0/0
- In AWS Console: EC2 > Security Groups > Select your instance's security group > Edit inbound rules
- Add rule: Type: HTTP, Source: 0.0.0.0/0

### 2. Container Issues
SSH into the EC2 instance and check:
```bash
# Check if container is running
sudo docker ps

# If container is not listed, check all containers including stopped ones
sudo docker ps -a

# Check container logs for errors
sudo docker logs myappcontainer

# Restart the container if needed
sudo docker restart myappcontainer

# If container failed, try running it again with interactive output
sudo docker run --name myappcontainer -p 80:8080 <your-ecr-repo-url>:latest
```

#### Common Node.js Error: Object.hasOwn is not a function
If you see this error in the logs:
```
TypeError: Object.hasOwn is not a function
```

This is caused by a Node.js version compatibility issue. Express.js 5.x requires Node.js 16 or higher, but the Dockerfile uses Node.js 14.

Fix by updating the Dockerfile:
1. Change `FROM node:14` to `FROM node:18`
2. Rebuild and redeploy the container

### 3. Application Port Mapping
- Verify the application inside the container is listening on port 8080 (which is mapped to port 80)
- Check if the port mapping is correct in the docker run command: `-p 80:8080`

### 4. EC2 Instance Status
- Check if the EC2 instance is running and healthy in AWS Console
- Verify you can SSH into the instance
- Check system resources: `top`, `df -h`

### 5. Network Issues
- Try accessing the application from a different network
- Check if your corporate firewall is blocking the connection
- Try using a VPN or mobile hotspot