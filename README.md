# 🚀 Strapi Deployment on AWS ECS (Fargate) using Terraform

This project deploys a Strapi application on AWS ECS Fargate using Terraform, with Docker images pulled from Amazon ECR and logs sent to CloudWatch Logs.

# 🧱 Architecture Overview

- AWS ECS (Fargate) – Runs Strapi container (serverless, no EC2 management)

- Amazon ECR – Stores Strapi Docker image

- CloudWatch Logs – Application logs

- IAM Execution Role – ECS task permissions

- VPC & Subnets – Default AWS networking

- Security Group – Allows access on port 1337

# 📁 Terraform File Structure
```bash
.
├── provider.tf        # AWS provider configuration
├── variables.tf       # Input variables (image_uri, region, etc.)
├── data.tf            # Existing AWS resources (VPC, subnets, IAM role)
├── ecs.tf             # ECS cluster, task definition, service
├── iam.tf             # (Optional) Only if creating new IAM role
├── cloudwatch.tf      # CloudWatch log group
├── sg.tf              # Security group
├── outputs.tf         # Outputs (cluster & service name)
└── README.md
```
# ⚙️ Prerequisites

- AWS account access

- IAM user with:

- ecs:*

- iam:PassRole

- logs:*

- Docker image pushed to Amazon ECR

Terraform >= 1.3

# 🚀 How to Deploy
- terraform init
- terraform validate
- terraform apply -auto-approve -var="image_uri=<ECR_IMAGE_URI>:latest"

# 🌐 Access Strapi

- After deployment:

- Get the public IP from the running ECS task

- Open in browser:

- http://<PUBLIC_IP>:1337


# Strapi admin panel will be available on first launch.

# 📝 Notes

- Uses existing IAM execution role if already created

- CloudWatch log group must exist before ECS task starts

- ECS service automatically restarts tasks if the container stops

# ✅ Status
- Completed
