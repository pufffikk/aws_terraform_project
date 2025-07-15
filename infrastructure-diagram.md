# AWS Infrastructure Diagram

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
    │  │  ┌───────────────┐  │                │                     │  │
    │  │  │  NAT Gateway  │  │                │                     │  │
    │  │  └───────────────┘  │                │                     │  │
    │  └─────────────────────┘                └─────────────────────┘  │
    │             │                                                    │
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
    │  └─────────────────────────────────────────────────────────────┘  │
    └──────────────────────────────────────────────────────────────────┘

                              ┌─────────────────┐
                              │   Route 53      │
                              │  Hosted Zone    │
                              │ quizgameruslan  │
                              │     .com        │
                              └─────────────────┘
                                       │
                              ┌─────────────────┐
                              │ CNAME Record    │
                              │ db.quizgame...  │
                              │ → RDS Endpoint  │
                              └─────────────────┘
```

## Component Details

### Security Groups
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ALB SG        │    │   EC2 SG        │    │   RDS SG        │
│                 │    │                 │    │                 │
│ Inbound:        │    │ Inbound:        │    │ Inbound:        │
│ • HTTP (80)     │    │ • From ALB SG   │    │ • From EC2 SG   │
│   from Internet │    │   Port 8000     │    │   Port 5432     │
│                 │    │ • SSH (22)      │    │                 │
│ Outbound:       │    │   from Internet │    │ Outbound:       │
│ • All traffic   │    │                 │    │ • All traffic   │
│                 │    │ Outbound:       │    │                 │
│                 │    │ • All traffic   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Auto Scaling Group
```
┌─────────────────────────────────────────────────────────────┐
│                    Auto Scaling Group                       │
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
│ └─────────────────┘           └─────────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

## Traffic Flow

1. **User Request** → Internet → Route 53 (optional)
2. **Internet Gateway** → VPC
3. **Application Load Balancer** → Distributes traffic
4. **Target Group** → Routes to healthy EC2 instances
5. **EC2 Instances** → Process FastAPI requests
6. **Database Connection** → EC2 connects to RDS via private network
7. **Outbound Traffic** → EC2 → NAT Gateway → Internet Gateway

## Key Features

- **High Availability**: Resources deployed across 2 AZs
- **Security**: RDS in private subnets, security groups restrict access
- **Scalability**: Auto Scaling Group maintains desired capacity
- **Load Distribution**: ALB distributes traffic evenly
- **Database Access**: Custom DNS via Route 53 for RDS endpoint