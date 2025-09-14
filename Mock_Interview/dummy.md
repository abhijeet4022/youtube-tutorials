### Q. 40. What are modules and how are they useful in provisioning infrastructure?

In Terraform, a module is a collection of resources grouped together for reuse. Modules help organize infrastructure code and allow you to replicate configurations across different environments or projects.

**Benefits of modules:**
- Promote reusability: Define infrastructure once and use it multiple times.
- Reduce duplication: Simplify code and ensure consistency.
- Easier maintenance: Updates to a module reflect everywhere it is used.

**Example usage:**

```hcl
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  region     = "us-east-1"
}
```
- This lets you provision the same VPC in dev, staging, and prod without duplicating code.

---

### Q. What is the traffic flow when you SSH to a machine via a bastion host?

**Answer:**

#### VPN Connection
Your laptop connects to the corporate network via GlobalProtect VPN. The VPN assigns a corporate IP and routes traffic into the VPC.

#### Route Table & Subnet
- Bastion host resides in a public subnet with a route to the internet via an Internet Gateway.
- Private EC2 is in a private subnet with routes through the bastion host (no direct internet access).

#### Security Groups
- Bastion SG allows SSH from your VPN IP range.
- Private EC2 SG allows SSH only from the bastion SG.

#### Traffic Flow
```
Laptop (VPN IP)
   |
   v
[Corporate VPN / Route Table]
   |
   v
Bastion Host (Public Subnet, SG allows VPN IP)
   |
   v
Private EC2 (Private Subnet, SG allows Bastion SG)
   |
   v
Responses follow the same path back
```

> **Note:** Traffic from your laptop reaches the private EC2 via Bastion’s public IP. The private subnet doesn’t need an explicit route to the bastion — it uses the VPC local route in the route table.

✅ **Summary:** Your laptop → VPN → Bastion host → Private EC2 → Bastion → Laptop, with route tables, subnets, and security groups controlling access at each step.

---

## 30. What is the difference between ALB and NLB in AWS?

### 1️⃣ Path and Host-Based Routing (ALB only)
- **ALB (Application Load Balancer)** works at Layer 7 (HTTP/HTTPS), so it can route traffic based on:
    - **Host-based routing:** Direct traffic to different targets based on domain name.
        - Example: `api.example.com` → API servers, `www.example.com` → Web servers
    - **Path-based routing:** Direct traffic based on URL path.
        - Example: `/images` → Image servers, `/videos` → Video servers
    - **Use Case:** Useful for microservices architecture or serving multiple apps from a single ALB.
- **NLB (Network Load Balancer)** cannot do path/host-based routing because it works at Layer 4 (TCP/UDP).

### 2️⃣ Target Groups (TG) and Listeners
- **ALB:**
    - Single listener (e.g., port 80 or 443) can forward traffic to multiple target groups using rules.
    - Example: Listener port 80 → TG1 if path `/api`, TG2 if path `/web`.
- **NLB:**
    - Each listener forwards traffic to one target group only (TCP/UDP based).

### 3️⃣ Cross-Zone Load Balancing
- **ALB:** Enabled by default, balances traffic evenly across targets in all AZs.
- **NLB:** Must be explicitly enabled for cross-zone balancing; otherwise, traffic is distributed only to targets in the same AZ as the incoming request.

---

## 32. What happens if you stop and start an EC2 instance with an ephemeral volume?

An **ephemeral (instance store) volume** is temporary storage physically attached to the host. If the instance is stopped, all data on the ephemeral volume is lost. If the ephemeral volume is the OS disk, the instance itself will be lost upon shutdown, but rebooting the server does not affect the data.

---

## 33. Can you design a highly available web server architecture with load balancing in AWS?

### Step 1: Create a VPC
- Define a VPC with a CIDR block (e.g., `10.0.0.0/16`).
- This VPC will host all application resources.

### Step 2: Create Subnets
- **Public Subnets** (e.g., `10.0.1.0/24`, `10.0.2.0/24`) in different AZs for ALB and NAT Gateway.
- **Private Subnets** (e.g., `10.0.3.0/24`, `10.0.4.0/24`) in different AZs for EC2 web servers.

### Step 3: Set up Internet Gateway (IGW)
- Attach IGW to the VPC.
- Update public subnet route tables to route `0.0.0.0/0` via IGW.

### Step 4: Set up NAT Gateway
- Place NAT Gateway in one of the public subnets.
- Update private subnet route tables to route `0.0.0.0/0` via NAT Gateway.
- This allows private instances to access the internet for updates/packages.

### Step 5: Create Security Groups
- **ALB SG:** Allow inbound HTTP (80) / HTTPS (443) from the internet.
- **EC2 SG:** Allow inbound traffic only from ALB SG, and allow outbound traffic to NAT Gateway.

### Step 6: Set up Application Load Balancer (ALB)
- Launch the ALB in public subnets.
- Configure listeners (HTTP/HTTPS).
- Create a Target Group (initially empty).
- Add rules for path-based or host-based routing if needed.

### Step 7: Create Launch Template
- Define a Launch Template that includes:
    - AMI with pre-installed web server (Apache/Nginx) or user data script to install packages at boot.
    - Instance type, key pair, security groups, IAM role, and subnet selection.
- This ensures all instances launched by ASG are identical and ready to serve traffic.

### Step 8: Configure Auto Scaling Group (ASG)
- Create ASG spanning multiple AZs for high availability.
- Attach the Launch Template.
- Attach the ASG to the ALB’s Target Group.
- The ASG automatically registers/deregisters instances with the Target Group as they are launched or terminated.
- Configure scaling policies based on CPU, memory, or network traffic.

### Step 9: Configure Health Checks
- Configure ALB health checks on the Target Group.
- Only healthy instances will receive traffic.

### Step 10: Set up DNS (Optional)
- Use Route 53 to point your domain to the ALB.
- Enable failover and weighted routing if required.

### Step 11: Test the Setup
- Access the web application via ALB DNS or Route 53 domain.
- Verify traffic is distributed evenly across multiple AZs.
- Simulate AZ failure to confirm HA and Auto Scaling work as expected.

### Traffic Flow
```
Internet
|
Route 53 (DNS)
|
ALB (Public Subnets)
|
Target Group (ASG)
/         |         \
AZ1        AZ2        AZ3
+---------+ +---------+ +---------+
|  EC2    | |  EC2    | |  EC2    |  <-- Private Subnets
| Web     | | Web     | | Web     |
+---------+ +---------+ +---------+
|
NAT Gateway (Public Subnet)
|
Internet Gateway (IGW)
```

---
Q. How do ALB and Auto Scaling Group (ASG) perform health checks, and what happens when an instance is unhealthy?
A:

ALB vs ASG Health Checks

ALB:
* Checks targets in its Target Group using protocol, port, path (e.g., /health), and HTTP response codes. Marks targets healthy/unhealthy to decide traffic routing.
* It's basically check the application health.
* If a target is unhealthy, ALB stops sending traffic to it until it becomes healthy again.

ASG:
* Uses EC2 status checks instance level to mark it healthy/unhealthy.
* If an instance is unhealthy, ASG terminates and replaces it to maintain the desired capacity.
* If ALB marks an instance as unhealthy, the ASG will terminate and replace it (if ALB health checks are enabled in the ASG).

Key Point: ALB controls traffic flow, while ASG controls instance lifecycle and availability.
