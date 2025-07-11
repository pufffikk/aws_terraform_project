# AWS Terraform Project ☁️

This project sets up a full AWS infrastructure using Terraform to deploy a FastAPI application on EC2 instances behind an Application Load Balancer (ALB), with Auto Scaling and a PostgreSQL RDS database.

---

## 🔧 Project Structure

* `vpc.tf` — VPC, public and private subnets, internet gateway, NAT gateway, and route tables
* `security_groups.tf` — Security groups for ALB and EC2 instances
* `launch_template.tf` — EC2 launch template (AMI, instance type, EBS volume, user\_data script)
* `alb.tf` — Application Load Balancer (ALB), target group, and HTTP listener
* `autoscaling.tf` — Auto Scaling Group with two EC2 instances
* `rds.tf` — RDS PostgreSQL instance in private subnets
* `scripts/ec2_user_data.sh` — User data script that configures the EC2 instances and starts the FastAPI app
* `outputs.tf` *(optional)* — Outputs like ALB DNS name and RDS endpoint

---

## ⚙️ Requirements

* Terraform `>= 1.0`
* AWS CLI configured (`aws configure` or env vars `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`)
* An existing EC2 KeyPair (referenced in `variables.tf`)

---

## ✨ Quick Start

1. **Initialize Terraform**

```bash
terraform init
```

2. **Preview the plan**

```bash
terraform plan
```

3. **Apply the infrastructure**

```bash
terraform apply
```

4. **Validate setup**

   * Go to AWS Console to check:

     * VPC, subnets, IGW/NAT
     * Security Groups for ALB and EC2
     * 2 EC2 instances in Auto Scaling Group
     * ALB status and port 80 listener
     * PostgreSQL RDS in private subnet
   * Test FastAPI:

```bash
curl http://<ALB-DNS>/health
```

Expected output:

```json
{"status": "ok"}
```

---

## 📃 Common Commands

```bash
# SSH into EC2 instance (replace with correct IP and key path)
ssh -i path/to/key.pem ec2-user@<EC2-Public-IP>

# Check if FastAPI is up
curl http://<ALB-DNS>/health

# Connect to PostgreSQL from EC2
psql -h <RDS-ENDPOINT> -U postgres -d postgres -p 55433
```

---

## ⚙️ Variables and Configuration

The `variables.tf` file contains required variables:

```hcl
variable "key_pair" { type = string }
```

Set your key name in `terraform.tfvars`:

```hcl
key_pair = "your-ec2-keypair"
```

Other resources (VPC, subnets, etc.) use hardcoded defaults. You can change them as needed.

---

## 🔧 Features

* Auto Scaling Group ensures exactly **2 EC2 instances** always run
* ALB provides a **single entry point** and balances traffic to EC2s
* FastAPI app is deployed using a `user_data` script
* PostgreSQL RDS is hosted in private subnets for security
* DNS aliasing via Route 53 for easy access to the database

---

## 📄 Teardown

To destroy all created resources:

```bash
terraform destroy
```

---

## 📚 .gitignore recommendation

Add the following to your `.gitignore`:

```
.terraform/
*.tfstate
*.tfstate.backup
*.pem
```

Ensure sensitive data (like `.pem` keys or credentials) is never committed.

---

## 📢 Contact

For questions or feedback, open an issue in this repository.

---

Happy deploying ✨
