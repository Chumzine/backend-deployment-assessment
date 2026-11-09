# MuchToDo Backend Deployment – DevOps Assessment

![AWS](https://img.shields.io/badge/AWS-Cloud%20Infrastructure-orange?logo=amazonaws)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-7B42BC?logo=terraform)
![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?logo=docker)
![Go](https://img.shields.io/badge/Go-Backend-00ADD8?logo=go)
![MongoDB](https://img.shields.io/badge/MongoDB-Database-47A248?logo=mongodb)

## About the Project

This project is part of the StartupTech Month 1 DevOps Assessment.

The goal was to deploy the MuchToDo Go backend application on AWS, using Terraform to create the infrastructure, Docker to package the application, and MongoDB to store application data.

I also configured an Application Load Balancer to make the backend accessible through a public endpoint while keeping the application and database servers in private subnets.

## Architecture

The deployment uses the following AWS components:

- **VPC:** Provides an isolated network for the application.
- **Public subnets:** Host the Application Load Balancer and Bastion Host.
- **Private subnets:** Host the Backend and MongoDB EC2 instances.
- **Bastion Host:** Provides secure SSH access to the private Backend instance.
- **Backend EC2:** Runs the MuchToDo backend application inside a Docker container.
- **MongoDB EC2:** Runs MongoDB as a separate database service.
- **Application Load Balancer (ALB):** Receives public HTTP requests and forwards them to the backend.

### How the components work together

1. A user sends a request to the public Application Load Balancer.
2. The load balancer forwards the request to the backend running on the private EC2 instance.
3. The backend communicates with MongoDB on the separate private EC2 instance.
4. MongoDB processes database requests and returns the required information to the backend.
5. The backend sends the response back through the load balancer to the user.

The database is not exposed directly to the internet. Access to MongoDB on port 27017 is restricted to the Backend security group.

## Technologies Used

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure |
| Terraform | Creating and managing AWS resources |
| Docker | Packaging and running the backend |
| Docker Compose | Managing application containers |
| Go | Backend application |
| MongoDB | Database |
| Git and GitHub | Source code management |
| Linux | Server administration |

## Prerequisites

Before setting up the project, make sure you have:

- An AWS account.
- AWS CLI installed and configured.
- Terraform installed.
- Docker Desktop installed and running.
- Git installed.
- An SSH key pair for accessing the EC2 instances.
- Access to the MuchToDo backend repository.

## Project Setup and Deployment

### 1. Clone the repository

```bash
git clone --branch feature/backend-only https://github.com/Innocent9712/much-to-do.git
```

Use the assessment project directory containing the Terraform configuration and Docker files for the remaining steps.

### 2. Configure AWS

Configure your AWS credentials using:

```bash
aws configure
```

Set the AWS region to:

```text
eu-north-1
```

Make sure your AWS credentials have the permissions required to create the infrastructure.

### 3. Create the AWS infrastructure

Navigate to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Review the infrastructure plan:

```bash
terraform plan
```

Create the resources:

```bash
terraform apply
```

Review the outputs after deployment. These include the VPC ID, Bastion public IP, Backend private IP and ALB DNS name.

### 4. Configure the environment variables

Create your local `.env` file using the example configuration.

For AWS deployment, create `.env.aws` and configure the MongoDB connection using the private IP address of the MongoDB EC2 instance.

Example:

```env
PORT=8080
MONGO_URI=mongodb://<MONGODB_PRIVATE_IP>:27017
DB_NAME=muchtodo
JWT_SECRET_KEY=<YOUR_SECURE_SECRET>
JWT_EXPIRATION_HOURS=72
ENABLE_CACHE=false
LOG_LEVEL=info
LOG_FORMAT=json
```

Replace the placeholders with the appropriate values.

**Important:** Never commit `.env`, `.env.aws`, AWS credentials, private keys or Terraform state files to GitHub.

### 5. Build and test locally

Build the Docker image:

```bash
docker compose build
```

Start the local application and MongoDB:

```bash
docker compose up -d
```

Check the containers:

```bash
docker compose ps
```

Test the health endpoint:

```bash
curl http://localhost:8080/health
```

The expected response is similar to:

```json
{
  "cache": "disabled",
  "database": "ok"
}
```

### 6. Deploy to AWS

The AWS deployment uses the separate MongoDB EC2 instance, while the backend runs in its own Docker container.

The deployment process is:

1. Connect to the private Backend EC2 through the Bastion Host.
2. Prepare the backend deployment directory.
3. Transfer the Docker image and deployment files to the Backend EC2.
4. Load the Docker image on the server.
5. Configure the `.env.aws` file with the MongoDB private IP and application settings.
6. Start the backend using Docker Compose.

Run the backend deployment:

```bash
docker compose -f docker-compose.aws.yml up -d
```

Check that the container is running:

```bash
docker compose -f docker-compose.aws.yml ps
```

Check the application logs:

```bash
docker compose -f docker-compose.aws.yml logs --tail=80 backend
```

### 7. Verify the deployment

Test the backend locally on the Backend EC2:

```bash
curl http://localhost:8080/health
```

Then test through the public Application Load Balancer:

```bash
curl http://<YOUR_ALB_DNS_NAME>/health
```

A successful response should return HTTP 200 and indicate that the database connection is working.

## How the Backend Connects to MongoDB

MongoDB runs on a separate EC2 instance in a private subnet.

The backend connects to it using the MongoDB private IP address configured in `.env.aws`.

For example:

```env
MONGO_URI=mongodb://<MONGODB_PRIVATE_IP>:27017
```

The Backend security group is allowed to communicate with the MongoDB security group on port 27017.

This means the backend can access the database without exposing MongoDB directly to public internet traffic.

## Cleanup and Removing AWS Resources

AWS resources can continue generating charges even when the application is no longer being used.

When the assessment is complete and the infrastructure is no longer needed, follow these steps.

### 1. Stop the backend container

Connect to the Backend EC2 and run:

```bash
docker compose -f docker-compose.aws.yml down
```

### 2. Remove the AWS infrastructure

From your local machine, navigate to the Terraform directory:

```bash
cd terraform
```

Review the resources that will be removed:

```bash
terraform plan -destroy
```

When you are ready to remove the infrastructure:

```bash
terraform destroy
```

Type `yes` when Terraform asks for confirmation.

**Important:** Destroying the infrastructure will remove the EC2 instances and other Terraform-managed resources. Back up anything important before proceeding, especially database data. Do not run this command while the assessment still needs to be accessible.

## Final Notes

This project gave me practical experience working with cloud infrastructure, Terraform, Docker, Linux servers, networking, SSH access and database connectivity.

It also helped me understand how different infrastructure components work together to support the deployment of a backend application.

**Assessment:** StartupTech Month 1 DevOps Assessment  
**Application:** MuchToDo Backend  
**AWS Region:** `eu-north-1`