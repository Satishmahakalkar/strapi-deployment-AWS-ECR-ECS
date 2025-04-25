# 🚀 Strapi Deployment on AWS ECS Fargate with Terraform & GitHub Actions CI/CD


This project automates the deployment of a Strapi application to **Amazon ECS Fargate** using **Terraform** for infrastructure provisioning and **GitHub Actions** for CI/CD. Docker images are built and pushed to **Amazon ECR**, and the ECS service is updated accordingly.


🎥 **Demo Video (Loom)**:  


---

## 📁 Project Structure
root@ip-172-31-2-115:~# tree -L 2
.
├── aws
│   ├── README.md
│   ├── THIRD_PARTY_LICENSES
│   ├── dist
│   └── install
├── aws-fargate-cicd-setup
│   ├── Dockerfile
│   ├── README.md
│   └── terraform

.
├── Dockerfile
├── README.md
└── terraform
    ├── alb.tf
    ├── ecs.tf
    ├── iam.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.1745230050.backup
    ├── terraform.tfstate.backup
    └── variables.tf
## ⚙️ Prerequisites

- AWS Account
- ECR Repository (e.g., `strapi-app`)
- IAM Role for ECS Tasks (e.g., `ecsTaskExecutionRole`)
- GitHub Repository Secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION` (e.g., `us-east-1`)
  - `ECR_REPO` (e.g., `strapi-app`)

---

## 🚀 How It Works

### ✅ GitHub Actions Workflow

1. **Triggers on Push to `main` branch**
2. **Authenticates with AWS**
3. **Pulls latest Docker image**
4. **Pushes Docker image to ECR**
5. **Initializes Terraform**
6. **Applies Infrastructure changes using Terraform**

### 📦 Docker Image

Make sure your Docker image is already built and pushed to ECR or modify the workflow to build from local.

---

## 🌐 Terraform Variables (Example)

Update the `Terraform Apply` step in `.github/workflows/ci-cd.yml` with these:

```yaml
terraform apply -auto-approve \
  -var="vpc_id=vpc-xxxxxxxx" \
  -var='subnet_ids=["subnet-xxxx", "subnet-yyyy"]' \
  -var="ecr_image=118273046134.dkr.ecr.us-east-1.amazonaws.com/${{ secrets.ECR_REPO }}:latest" \
  -var="execution_role_arn=arn:aws:iam::123456789012:role/ecsTaskExecutionRole"


🧰 Setup Instructions
1. Clone the Repo
bash
Copy
Edit
git clone https://github.com/shashibabu123/aws-fargate-cicd-setup.git
cd aws-fargate-cicd-setup
2. Add GitHub Secrets
Repository → Settings → Secrets and variables → Actions:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

AWS_REGION

ECR_REPO

3. Push to Deploy 🚀

git add .
git commit -m "initial commit for ECS Fargate CI/CD"
git push origin main
🧹 Clean Up
To destroy infrastructure:


cd terraform
terraform destroy -auto-approve
📺 Demo
🎥 Loom Walkthrough Video
👉 Watch Demo



🙌 Author
Made with ❤️ by Shashikumar
Intern @ PearlThoughts 🚀
