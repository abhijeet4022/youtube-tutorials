**Linux Interview FAQs**

Q1. How to fix Application file system full issue?
* **Answer :**
* When a file system becomes full on a Linux server, follow the steps below to investigate and resolve the issue.

1. **Identify the Full File System**

* Use: `df -hT`
* Identify which file system is 100% or nearly full.

2. **Navigate to the Affected Mount Point**

* `cd /path/to/full/mount`

3. **Identify Large Files or Directories**

* `du -sh * | sort -h`
* To include hidden files: `du -sh .[!.]* * | sort -h`

4. **Take Action to Free Up Space**

* Inform respective user or team.
* Delete or compress unnecessary files.
* Move files to another location.

5. **If Cleanup is Not Sufficient**

* Raise a request to extend file system.
* Get required approvals from stakeholders (Server and Application Owner).
* Create a Change Request (CR) following your organization’s change management process.
* Schedule and perform the file system extension activity.
---

Q2. You're running out of space on /var, which is an LVM volume. Walk me through the steps to increase the size of /var by 5GB. Assume a new disk /dev/xvdf is attached.
* **Answer :**
> Refer the video for LVM: [LVM Extension Video](https://youtu.be/M7dk5mRBBwk)

```bash
# 1. Verify the space is available on current volume group.
vgs

# 2. If in current VG space is not there then attach disk or extend the current disk.
# Create a new partition
fdisk /dev/xvdf
# Create primary partition and save

# 3. Create physical volume
pvcreate /dev/xvdf1

# 4. Extend volume group
vgextend <vg_name> /dev/xvdf1

# 5. Extend logical volume
lvextend -L +5G /dev/<vg_name>/<lv_name>

# 6. Resize filesystem
resize2fs /dev/<vg_name>/<lv_name>   # For ext4
xfs_growfs /var                       # For xfs
```
---

Q3. How do you ensure a cron job ran successfully? What logs do you check and how would you debug a failing cron?
* We can ensure a cron job ran successfully by checking the following:
* We can verify our required task is completed or not.
* We can check the cron job logs to see if it ran successfully or not. We can identify the error also from the logs.
```bash
grep CRON /var/log/cron   # or journalctl -u crond
```

### Debugging Steps:
* Check the cron service status: `systemctl status crond`
* Ensure the script is executable.
* Check the script or command is correctly written.
* Check the cron job syntax in the crontab file.
* Check the environment variables in the script.
* Check the cron job's output and error logs.
---

Q4. A log file is growing very large, and logrotate is not rotating it. What steps will you take to debug and fix this issue?
**Answer:**

* Check logrotate config: `/etc/logrotate.conf` or `/etc/logrotate.d/*`
* Run manually in debug mode:

```bash
logrotate -d /etc/logrotate.conf
```
* Check the logrotate service status or cron job is set properly or not to run the logrotate script.
* Ensure correct permissions, paths, and postrotate scripts.
---

Q5. When you are planning to patch production servers. What are the steps you take before and after patching?
**Answer:**
**Before:**

* Notify stakeholders
* Backup or snapshot
* Check disk, memory, uptime
* Check current kernel version
* Check running services
* Check application functionality

**After:**

* Reboot if needed
* Verify patch installation
* Validate service health
* Verify kernel version
* Verify application functionality
* Notify stakeholders
---

Q6. One of your EC2 Linux servers is running slow. What steps will you use to troubleshoot performance issues?
* **Answer :**
```bash
top/htop       # CPU, memory
vmstat         # Memory and CPU activity
iostat -x      # Disk I/O
free -h        # Memory usage
df -h / du -sh # Disk usage
sar            # Historical stats
Monitoring tools: Prometheus, Grafana
```
---

Q7. Suppose you have received an alert stating that CPU utilization of any particular application server is high (85%). What steps will you take for this alert?
* **Answer :**
1. Verify the Alert:
  * Log into the server.
  * Use top or htop to confirm real-time CPU usage.
  * Use uptime to check system load averages.
  * We can use monitoring tools like CloudWatch, Prometheus, or Grafana to verify the alert.

2. Identify the Root Cause:
  * Run `ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head` to find top CPU-consuming processes.
  * Use `top` and press `Shift + P` to sort by memory usage.
  * Check if a particular process, service, or user is responsible.
  * Sometimes due to more user load or peeks in application usage, CPU usage can spike. And after few minutes it will come down automatically.

3. System-Level Process Check
  * Check if a system daemon, scheduled cron job, or a misbehaving kernel process is responsible for high CPU usage.
  * if a system process is consuming high CPU, check its logs or configuration.
  * Any scheduled jobs or cron tasks that might be running at the time of high CPU usage. Wait to complete the job.
  * Check memory usage (free -m) — high memory pressure can cause CPU spikes.

4. Application-Level Check:
  * If it's an application service causing the issue, take the screenshots and notify the application team (Application Owner/Server Owner).
  * Restart the process if it’s unresponsive or consuming abnormally high CPU After taking the necessary approvals.

5. Historical Analysis:
  * Check historical data from monitoring tools (like CloudWatch, Prometheus, Grafana) to see if this is a recurring issue.
  * If yes, consider scaling the instance size after approval.
---

Q8. You deployed a web app using Nginx, but when accessing the site, you get a 502 Bad Gateway. How do you troubleshoot this?
* **Answer :**

* Check the nginx server is up and running if the server is shutdown state or due to high load sometime server won't respond.
* Check the nginx service status: `systemctl status nginx`
* Verify Nginx configuration: `nginx -t`
* Look for errors in Nginx logs: `/var/log/nginx/error.log`
* Check if the upstream server (e.g., application server) is running and reachable.
* Ensure the upstream server is correctly defined in the Nginx config
* Ensure backend app is running and reachable
* Curl backend directly: `curl localhost:<port>`
---

Q9. What is the minimal network traffic flow when accessing a web application hosted on an AWS Linux server from a browser?
* **Answer :**
* When a user accesses a web application hosted on an AWS Linux server from a browser, the minimal network traffic flow involves the following steps:
1. DNS Resolution
  * The browser sends a DNS request to resolve the domain name to the associated IP.
  * If using Route 53, it resolves to:
    * A public IP, or
    * A domain name pointing to an AWS Load Balancer.

2. Client to AWS (Public Internet)
  * The browser initiates an HTTP or HTTPS (TLS) request to the resolved IP/Load Balancer.
  * This request traverses the public internet to reach the AWS infrastructure.

3. AWS Network Entry Point
  * The request hits:
    * An Application Load Balancer (ALB) or Network Load Balancer (NLB), or
    * Directly to the EC2 instance if using a public IP or EIP
    * If using NACL, the request must pass through the Network ACL rules where 80 and 443 should allow.
    * Security Group of the instance or LB must allow traffic (e.g., TCP port 80/443)

4. AWS Linux EC2 Instance
  * The load balancer (if used) forwards the request to the EC2 instance hosting the app.
  * The instance:
    * Runs a web server like Nginx, Apache, or a custom app
    * Serves the static or dynamic content (HTML, JSON, API responses)

5. Response Back to Browser
  * The EC2 instance sends the response back through the same path:
    * To the load balancer (if present)
    * Through the internet gateway
    * Back to the user's browser
---

Q10. How do you view the contents of a .tar.gz file without extracting it?
* `tar -tzf file.tar.gz`
---

Q11. How do you check which ports are listening?
* `ss -tuln` or `netstat -tuln`
---

Q12. How do you list all running processes?
* Use `ps aux` or `top` or `ps -u <user>`.
---

Q13. How will you check the security patches and severity?
* **Answer :**
- List Available Security Updates with Details: `yum updateinfo list security all` or `yum check-update --security`
```
RHSA-2025:1234 Important/Sec. kernel-3.10.0-1160.88.1.el7.x86_64
RHSA-2025:2345 Moderate/Sec. openssl-1.0.2k-25.el7_9.x86_64
RHSA-2025:3456 Low/Sec. bash-4.2.46-34.el7.x86_64

```
- Show Detailed Info (e.g., severity, CVE, advisory): `yum updateinfo info security`
- Filter by Severity (e.g., only Critical or Important): `yum updateinfo list security severity=Critical`
- View detailed info about the advisory: `yum updateinfo info RHSA-2025:1234`
---

Q14. How do you apply security updates only manually? And also if you have to update all the packages?
* Apply Security Updates Only: `yum update --security -y`
* Update All Packages: `yum update -y`
---

Q15. What is the drawback or issue that may arise if you update all available packages?
* Updating all packages may lead to compatibility issues with existing applications, as newer versions of libraries or dependencies may not be compatible with the current application code.
---

Q20. How do you check if a reboot is required after patching?
```bash
needs-restarting -r
```
---

Q21. How do you list the patches or packages updated recently?
* To list recently updated packages, you can use:
```bash
rpm -qa --last | head -n 10
```
---

Q22. Suppose you have updated one system and want to roll back to the previous state — how will you do that from the OS?
```bash
yum history list
yum history info <transaction_id>
yum history undo <transaction_id>
```
---

Q23. How do you manage patching for all environments — all servers in a single shot or part-wise?

## Patch Severity Levels
- **Critical**
- **Important**
- **Moderate**
- **Low**
- `yum updateinfo list security all`

# Patch Schedule:
Microsoft releases patches on the 2nd Tuesday of every month, and we apply them on the 3rd Friday of every month. We follow `n-1` patches for production servers and the latest patches for non-production servers.
- 1st Friday Night: Production Servers - `n-1` patch (Windows)
- 2nd Friday: Production Servers - `n-1` patch (Linux)
- 3rd Friday: Non-Production Servers - Latest patch (Windows + Linux)

### For every patching batch, there is usually a fixed Maintenance Window (MW), or you may need to request one depending on the environment. Before initiating the patching process, it is critical to ensure that backups have been completed.
In most cases, where a fixed MW is followed, the backup window is scheduled before the patching MW. Therefore, when the patching MW starts, backups (such as AMIs or EBS snapshots) should already be completed.
Backups can be automated using AWS Backup, a Lambda function to automate the AMI Creation, or by managing the OS Disk snapshots lifecycle using DLM.
For unplanned or emergency patching scenarios involving only a few servers (e.g., 2–3), manual backups or snapshots may be performed just before patching.

For servers behind the load balancer, we patch one server at a time. Once the patches are applied and the first server is up and running properly, we proceed to the next server.

- ALB Target Group: Server1, Server2

* SSM Patch Deployment: Two patch groups
* Patch Group 1: 12 PM - Server1
* Patch Group 2: 2 PM - Server2

- If automatic update fail then will do manual patching by using the command:
* Linux - `yum update --security -y`
* Windows - `Setting - Check for updates - apply updates` once done reboot the server.
---

Q24. Suppose your two servers are running behind the Load Balancer and supporting one application. During patching, how will you ensure the application does not go down?
## Zero-Downtime Patching Behind Load Balancer Using AWS SSM

### Goal

Ensure EC2 instances behind a Load Balancer are patched via AWS SSM Patch Manager **without causing downtime**.

---

### Assumptions

* Two EC2 instances behind an LB
* SSM Patch Manager with Maintenance Windows is configured
* Load Balancer health checks are enabled

---

### Step 1: Tag Instances

Tag instances to create separate patch groups:

```
AppServer1: Patch Group = patch-group-1
AppServer2: Patch Group = patch-group-2
```

Assign each patch group to a different patch baseline.

---

### Step 2: Create Maintenance Windows

Create two separate maintenance windows:

* **MW-AppServer1**: Runs at 2:00 AM, targets `patch-group-1`
* **MW-AppServer2**: Runs at 3:00 AM, targets `patch-group-2`

---

### Step 3: Add Pre and Post Tasks

Use `AWS-RunShellScript` for pre/post tasks and `AWS-RunPatchBaseline` for patching.

#### Pre-task: Deregister from Load Balancer

```bash
#!/bin/bash
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws elbv2 deregister-targets \
  --target-group-arn <TARGET_GROUP_ARN> \
  --targets Id=$INSTANCE_ID \
  --region <REGION>
```

#### Patching Task

Use `AWS-RunPatchBaseline` with Operation = `Install`

#### Post-task: Re-register to Load Balancer

```bash
#!/bin/bash
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws elbv2 register-targets \
  --target-group-arn <TARGET_GROUP_ARN> \
  --targets Id=$INSTANCE_ID \
  --region <REGION>
```
---

### Q21. How will you patch the server running behind the Auto Scaling Group?

**Preferred Approach: Using a Golden AMI**

1. Take the existing AMI (or instance snapshot).
2. Launch a temporary EC2 instance from it.
3. Apply OS and application patches on this temporary instance.
4. Create a new AMI with all patches applied.
5. Update the Launch Template or Launch Configuration of the ASG with the new AMI.
6. Perform a rolling update or instance refresh on the ASG:
   - Old instances are gradually terminated.
   - New instances with the patched AMI are launched automatically.
---

### Q20. How do you bring unmanaged AWS resources under Terraform management?

To bring unmanaged AWS resources under Terraform management, use the `terraform import` command to import the resource into Terraform state.

**Steps to Manage Unmanaged AWS Resources in Terraform:**

1. **Identify the existing AWS resource and note its ID.**
2. **Write the corresponding Terraform resource block (e.g., EC2) without applying it:**
```hcl
resource "aws_instance" "my_ec2" {
    # Configuration will be added after import
}
```
3. **Import the resource:**
```bash
terraform import <resource_type>.<resource_name> <resource_id>
```
*Example:*
```bash
terraform import aws_instance.my_ec2 i-1234567890abcdef0
```
4. **Verify the imported resource:**
```bash
terraform show
```
5. **Update the Terraform configuration aws_instance.my_ec2 block using the output value from `terraform show`.**
6. **Check for changes:**
```bash
terraform plan
```
7. **Apply the final configuration:**
```bash
terraform apply
```

---


31. What is a provisioner in Terraform?

In Terraform, a provisioner is a mechanism used to execute scripts or commands on resources after they have been created or updated. Provisioners are typically used to perform tasks that require interacting with the newly created infrastructure, such as installing software, configuring settings, or running initialization scripts.

Q33. Suppose you need to create an EC2 instance using Terraform, and you also want to install a few packages on it. How would you do that?
1. Using user_data (Preferred)
```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"   # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = "subnet-12345678"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd git
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "Terraform-EC2"
  }
}
```
2. Using Terraform Provisioners (remote-exec)

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = "subnet-12345678"
  key_name      = "my-keypair"

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd git",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/my-keypair.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "Terraform-EC2-Provisioned"
  }
}
```
---

### 32. What is Terraform drift and how does Terraform detect drift in configuration and how can you clear those drift?

Terraform detects drift in configuration by using the `terraform plan` or `terraform apply` command. Drift occurs when the actual infrastructure state deviates from the expected state defined in the Terraform configuration.

**How Terraform Detects Drift:**

- **State Comparison:**  
  Terraform maintains a state file (`terraform.tfstate`) that records the infrastructure's last known state.  
  When you run `terraform plan`, Terraform queries the actual infrastructure and compares it with the state file.

- **Detecting Differences:**  
  If Terraform finds discrepancies (e.g., manually changed configurations in the cloud provider console), it marks those changes as drift.  
  It displays the differences in the `terraform plan` output.

**Resolving Drift:**

- Running `terraform apply` can reconcile the drift by:
  - **Reverting changes:** If the infrastructure differs from the desired state, Terraform will adjust it to match the configuration.
  - **Updating state:** If the drifted changes are intentional and should be retained, the Terraform configuration or state must be updated.34. 
---

### 36\. What happens if someone makes manual changes to the configuration of infrastructure provisioned by Terraform and then runs `terraform apply` again?

When a resource is manually changed outside of Terraform's configuration and you run `terraform apply` again, Terraform compares the current state of your infrastructure (queried from the provider) with the state file and your configuration files. If it detects any differences, it considers these as drift.

**Here's what happens:**

- **Drift Detection:** Terraform identifies that the resource's actual settings differ from what's declared in your configuration.
- **Plan Generation:** Running `terraform plan` shows a proposed change to revert the manual modifications, aligning the infrastructure back to the configuration's state.
- **Reconciliation:** When you apply the plan, Terraform makes the necessary changes to bring the resource back into the desired state.

This behavior ensures that the infrastructure remains consistent with the defined configuration. If you intend to keep the manual changes, you must update the Terraform configuration accordingly and then apply.
---

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

### Q\. What is the difference between Elastic IP, Public IP, and Private IP in AWS?

- **Elastic IP**: Static public IP you own; can be remapped to different instances.
- **Public IP**: Dynamic IP assigned by AWS; changes if the instance stops/starts.
- **Private IP**: Internal IP within a VPC; used for internal communication between instances.
---

## What is the use case of an Auto Scaling Group \(ASG\) in AWS?

**Answer:**

An Auto Scaling Group \(ASG\) automatically scales EC2 instances up or down based on demand, ensuring high availability, fault tolerance, and cost optimization. Use cases include:

- Handling traffic spikes by adding instances automatically.
- Maintaining minimum instances for HA across multiple AZs.
- Replacing unhealthy instances to ensure application availability.
- Scaling down during low traffic to reduce costs.
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

## Q. What is VPC peering, and how can you configure it in AWS?

**A:**  
VPC Peering is a networking connection between two VPCs that allows them to route traffic privately using private IPs without going through the internet or a VPN.

**Steps to Configure VPC Peering:**
1. **Create a VPC Peering Connection:**  
   Initiate from the requester VPC to the accepter VPC.

2. **Accept the Peering Request:**  
   The owner of the accepter VPC accepts the connection.

3. **Update Route Tables:**  
   Add routes in both VPCs pointing to each other’s CIDR via the peering connection.

4. **Update Security Groups:**  
   Allow traffic from the peer VPC’s CIDR in the relevant security groups.

> **Note:** VPC peering is non-transitive — traffic cannot route through one peered VPC to another.

---

## Q34. What is the use case of a NAT Gateway, and in which subnet should it be created?

**A:**

**Use Case:**  
Allows instances in private subnets to access the internet for updates, patches, or external API calls without exposing them to inbound internet traffic.

**Subnet Placement:**
- NAT Gateway must be created in a public subnet with a route to the Internet Gateway \(IGW\).
- Private subnets’ route tables point `0.0.0.0/0` traffic to the NAT Gateway.

**Summary:**  
Private instances → NAT Gateway \(public subnet\) → Internet, ensuring secure outbound connectivity.

---

## Q35. How can a VM in a private subnet reach the internet to download packages? What are the required steps and route entries?

**A:**

**Steps:**
1. **Create a NAT Gateway:**  
   Place the NAT Gateway in a public subnet with an Elastic IP.

2. **Update Route Table for Private Subnet:**  
   Add a route pointing all internet-bound traffic \(`0.0.0.0/0`\) to the NAT Gateway.

3. **Security Groups / NACLs:**
    - Ensure the VM’s security group allows outbound traffic \(e.g., HTTP/HTTPS\).
    - NACLs should allow outbound and return inbound traffic.

**Route Table Entries Example:**

**Private Subnet Route Table**
| Destination   | Target      |
|---------------|-------------|
| 10.0.0.0/16   | local       |
| 0.0.0.0/0     | NAT Gateway |

**Public Subnet Route Table \(where NAT resides\)**
| Destination   | Target      |
|---------------|-------------|
| 10.0.0.0/16   | local       |
| 0.0.0.0/0     | Internet GW |

**Summary:**  
VM in a private subnet → NAT Gateway in public subnet → Internet.  
This allows private instances to download packages or access the internet without exposing them directly.

---
### Q\. What is the difference between Security Groups \(SG\) and Network ACLs \(NACL\) in AWS?

**Feature** | **Security Group \(SG\)** | **Network ACL \(NACL\)**
--- | --- | ---
Level | Instance-level | Subnet-level
Type | Stateful \(return traffic allowed automatically\) | Stateless \(return traffic must be explicitly allowed\)
Rules | Allow rules only | Allow and deny rules
Evaluation | All rules evaluated before allowing traffic | Rules evaluated in order, first match applies
Scope | Attached to EC2, RDS, Lambda, etc\. | Applies to entire subnet

✅ **Summary:** SGs are stateful firewalls for instances, NACLs are stateless firewalls for subnets, providing an extra layer of security.

---

## 32. What happens if you stop and start an EC2 instance with an ephemeral volume?

An **ephemeral (instance store) volume** is temporary storage physically attached to the host. If the instance is stopped, all data on the ephemeral volume is lost. If the ephemeral volume is the OS disk, the instance itself will be lost upon shutdown, but rebooting the server does not affect the data.

---
## How to Create a CloudWatch Alarm for High CPU Usage Using Instance Tags (e\.g\., app=nginx)

**Steps:**

1\. **Go to CloudWatch**  
Open AWS CloudWatch → Alarms → Create Alarm.

2\. **Select Metric**  
Click Select metric → EC2 → Per-Instance Metrics.  
Use search or filter by tag:  
Example: `tag:app=nginx`  
Select CPUUtilization metric for all instances with that tag.

3\. **Set Threshold**
- Threshold type: Static
- Condition: CPU \> 75%
- Evaluation period: e\.g\., 5 minutes

4\. **Configure Actions**
- Notification: Send to an SNS topic \(email, Slack, etc\.\)

5\. **Name and Create**
- Give a descriptive name \(e\.g\., HighCPU-nginx\)
- Review → Create Alarm

**Result:**  
Any EC2 instance with the tag `app=nginx` will trigger the alarm if CPU exceeds 75%.
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
### Q. How do ALB and Auto Scaling Group (ASG) perform health checks, and what happens when an instance is unhealthy?

**ALB vs ASG Health Checks**

**ALB:**
- Checks targets in its Target Group using protocol, port, path (e\.g\., /health), and HTTP response codes\. Marks targets healthy/unhealthy to decide traffic routing\.
- Checks the application health\.
- If a target is unhealthy, ALB stops sending traffic to it until it becomes healthy again\.

**ASG:**
- Uses EC2 status checks at the instance level to mark it healthy/unhealthy\.
- If an instance is unhealthy, ASG terminates and replaces it to maintain the desired capacity\.
- If ALB marks an instance as unhealthy, the ASG will terminate and replace it \(if ALB health checks are enabled in the ASG\)\.

**Key Point:** ALB controls traffic flow, while ASG controls instance lifecycle and availability\.
---

### Q\. What is S3 bucket versioning in AWS?

**A:**  
S3 bucket versioning is a feature that keeps multiple versions of an object in the same bucket. It allows you to:

- Recover deleted or overwritten objects.
- Maintain historical versions for auditing or rollback.
- Protect data from accidental deletion or overwrites.

You cannot fully disable versioning once it’s been enabled. You can only suspend versioning, which stops creating new versions, but existing versions remain.

✅ Once enabled, every PUT, POST, or DELETE creates a unique version ID for the object.

### Q\. How can you optimize S3 costs in AWS?

**A:**

- **Use Proper S3 Storage Classes:**
  - Standard-IA / One Zone-IA for infrequently accessed data.
  - Glacier / Glacier Deep Archive for archival data.

- **Enable Lifecycle Policies:**
  - Automatically transition objects to cheaper storage or delete old objects.

- **Delete Unused Objects:**
  - Remove obsolete files, old versions, or incomplete multipart uploads.

- **Enable Versioning Carefully:**
  - Versioning keeps multiple copies; combine with lifecycle rules to delete old versions.

- **Use S3 Intelligent-Tiering:**
  - Automatically moves data between frequent/infrequent access tiers based on usage.

