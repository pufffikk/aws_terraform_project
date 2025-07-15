# AWS Infrastructure Diagram - Updated Architecture

```
                                    Internet
                                       |
                              ┌────────────────┐
                              │ Internet Gateway│
                              │     (IGW)      │
                              └────────────────┘
                                       |
    ┌──────────────────────────────────────────────────────────────────┐
    │                          VPC (10.0.0.0/16)                      │
    │                                                                  │
    │  ┌─────────────────────┐                ┌─────────────────────┐  │
    │  │   Public Subnet     │                │   Public Subnet     │  │
    │  │  (10.0.1.0/24)      │                │  (10.0.2.0/24)      │  │
    │  │    us-west-2a       │                │    us-west-2b       │  │
    │  │                     │                │                     │  │
    │  │  ┌───────────────┐  │                │  ┌───────────────┐  │  │
    │  │  │  NAT Gateway  │  │                │  │ Bastion Host  │  │  │
    │  │  └───────────────┘  │                │  │   t3.micro    │  │  │
    │  │                     │                │  │   SSH:22      │  │  │
    │  │                     │                │  └───────────────┘  │  │
    │  └─────────────────────┘                └─────────────────────┘  │
    │                                                                  │
    │  ┌──────────────────────────────────────────────────────────────┐ │
    │  │                Application Load Balancer                     │ │
    │  │                      (Port 80)                               │ │
    │  └──────────────────────────────────────────────────────────────┘ │
    │             │                                                    │
    │             ├─────────────────┬──────────────────────────────────┤ │
    │             │                 │                                  │ │
    │  ┌─────────────────────┐                ┌─────────────────────┐  │
    │  │   Private Subnet    │                │   Private Subnet    │  │
    │  │  (10.0.11.0/24)     │                │  (10.0.12.0/24)     │  │
    │  │    us-west-2a       │                │    us-west-2b       │  │
    │  │                     │                │                     │  │
    │  │  ┌───────────────┐  │                │  ┌───────────────┐  │  │
    │  │  │   EC2 Instance│  │                │  │   EC2 Instance│  │  │
    │  │  │   (t3.micro)  │  │                │  │   (t3.micro)  │  │  │
    │  │  │   FastAPI App │  │                │  │   FastAPI App │  │  │
    │  │  │   Port 8000   │  │                │  │   Port 8000   │  │  │
    │  │  └───────────────┘  │                │  └───────────────┘  │  │
    │  └─────────────────────┘                └─────────────────────┘  │
    │             │                                     │               │
    │             └─────────────────┬───────────────────┘               │
    │                               │                                   │
    │  ┌─────────────────────────────────────────────────────────────┐  │
    │  │                    RDS Subnet Group                        │  │
    │  │                                                             │  │
    │  │              ┌───────────────────────────┐                  │  │
    │  │              │     PostgreSQL RDS        │                  │  │
    │  │              │     (db.t3.micro)         │                  │  │
    │  │              │     Port 5432             │                  │  │
    │  │              │     20GB gp2              │                  │  │
    │  │              └───────────────────────────┘                  │  │
    │  │                                                             │  │
    │  │              ┌───────────────────────────┐                  │  │
    │  │              │   Route 53 (Internal)     │                  │  │
    │  │              │ db.quizgameruslan.com     │                  │  │
    │  │              │    → RDS Endpoint         │                  │  │
    │  │              └───────────────────────────┘                  │  │
    │  └─────────────────────────────────────────────────────────────┘  │
    └──────────────────────────────────────────────────────────────────┘
```

## Component Details

### Security Groups
```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   ALB SG        │  │   EC2 SG        │  │ Bastion SG      │  │   RDS SG        │
│                 │  │                 │  │                 │  │                 │
│ Inbound:        │  │ Inbound:        │  │ Inbound:        │  │ Inbound:        │
│ • HTTP (80)     │  │ • From ALB SG   │  │ • SSH (22)      │  │ • From EC2 SG   │
│   from Internet │  │   Port 8000     │  │   from Internet │  │   Port 5432     │
│                 │  │ • From Bastion  │  │                 │  │ • From Bastion  │
│ Outbound:       │  │   SSH (22)      │  │ Outbound:       │  │   Port 5432     │
│ • All traffic   │  │                 │  │ • All traffic   │  │                 │
│                 │  │ Outbound:       │  │                 │  │ Outbound:       │
│                 │  │ • All traffic   │  │                 │  │ • All traffic   │
└─────────────────┘  └─────────────────┘  └─────────────────┘  └─────────────────┘
```

### Auto Scaling Group
```
┌─────────────────────────────────────────────────────────────┐
│              Auto Scaling Group (Private Subnets)           │
│                                                             │
│ • Desired Capacity: 2                                       │
│ • Min Size: 2                                               │
│ • Max Size: 2                                               │
│ • Health Check: ALB                                         │
│ • Launch Template: EC2 with FastAPI                         │
│                                                             │
│ ┌─────────────────┐           ┌─────────────────┐           │
│ │   EC2 Instance  │           │   EC2 Instance  │           │
│ │   AZ: us-west-2a│           │   AZ: us-west-2b│           │
│ │ (Private Subnet)│           │ (Private Subnet)│           │
│ └─────────────────┘           └─────────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

## Traffic Flow

### 1. **Web Traffic Flow**
1. **User Request** → Internet → Internet Gateway → VPC
2. **Application Load Balancer** → Distributes traffic to private subnets
3. **Target Group** → Routes to healthy EC2 instances in private subnets
4. **EC2 Instances** → Process FastAPI requests (not directly accessible)

### 2. **SSH Access Flow**
1. **Admin** → SSH to Bastion Host in public subnet
2. **Bastion Host** → SSH to EC2 instances in private subnets
3. **Secure Access** → No direct SSH from internet to private instances

### 3. **Database Access Flow**
1. **EC2 Instances** → Connect to RDS in private subnets via internal DNS
2. **Internal DNS** → Route 53 resolves db.quizgameruslan.com to RDS endpoint
3. **Optional** → Bastion can also access RDS for troubleshooting

### 4. **Outbound Traffic Flow**
1. **Private EC2s** → NAT Gateway in public subnet
2. **NAT Gateway** → Internet Gateway → Internet
3. **Updates/Downloads** → Secure outbound access without inbound exposure

## Key Features

- **Enhanced Security**: EC2 instances in private subnets, no direct internet access
- **Bastion Host**: Secure SSH access via jump server in public subnet
- **High Availability**: Resources deployed across 2 AZs
- **Load Distribution**: ALB distributes traffic to private EC2 instances
- **Database Security**: RDS in private subnets with internal DNS resolution
- **Outbound Access**: NAT Gateway enables private instances to reach internet
- **Network Isolation**: Clear separation between public (bastion, ALB, NAT) and private (EC2, RDS) tiers

## SSH Access Commands

```bash
# 1. SSH to bastion host
ssh -i path/to/your-key.pem ec2-user@<BASTION_PUBLIC_IP>

# 2. From bastion, SSH to private EC2 instances
ssh -i path/to/your-key.pem ec2-user@<PRIVATE_EC2_IP>

# 3. Optional: Copy key to bastion for easier access
scp -i path/to/your-key.pem path/to/your-key.pem ec2-user@<BASTION_PUBLIC_IP>:~/.ssh/
```

## Architecture Benefits

1. **Security**: Private instances not directly accessible from internet
2. **Compliance**: Follows AWS security best practices
3. **Scalability**: Auto Scaling Group can adjust capacity as needed
4. **Monitoring**: Centralized access through bastion host for auditing
5. **Cost Optimization**: Single NAT Gateway serves all private subnets