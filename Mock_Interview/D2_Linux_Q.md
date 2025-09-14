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

### Q. How does Terraform manage the state of resources it creates?

**A:**  
Terraform uses a state file \(`terraform.tfstate`\) to track the resources it manages. This file maps Terraform configuration to the real-world infrastructure.

---

### Q\. How do you manage the Terraform state file in a team environment?

**A:**  
In a team environment, Terraform state should be stored remotely instead of locally to ensure collaboration, consistency, and safety.
---

### Q. What is state lock and how will you deal if a conflict happens?

* State lock prevents multiple Terraform processes from modifying the same state file at once.
* If a conflict happens:
  * Wait and retry (another user may be running Terraform).
  * If the lock is stuck, use `terraform force-unlock <LOCK_ID>` \(only if sure no other process is running\).
---

Q. 40. What are modules and how are they useful in provisioning infrastructure?

In Terraform, a module is a collection of resources that are grouped together for reuse. It helps organize infrastructure code and allows you to easily replicate configurations across different environments or projects.

Modules are useful because they promote reusability, enabling you to define infrastructure once and use it multiple times. They also help simplify code by reducing duplication, ensuring consistency across deployments, and making maintenance easier—any updates made to a module automatically reflect in all instances where it's used.

For example, you can create a module for provisioning a VPC and then call it in different parts of your configuration to set up multiple VPCs without rewriting the same code. Modules help save time, avoid repetition, and make sharing configurations easier.

Q. How can you recover if ec2 key lost

- What is the use of Template in ansible ?
- How to run any job of particular role
- - name: Catalogue Configuration
    ansible.builtin.import_role:
    name: common
    tasks_from: nodejs
- How to import task
- - name: Schema setup
    ansible.builtin.import_tasks: schema.yml
    when: schema is defined

Q. How to call any role from anisble playbook?


27. I have many plays in a playbook but I want only few plays in it to run. How can I achieve it?

Use --tags or --start-at-task.

To run the playbook starting from the "Copy nginx configuration" task, use the following command:
ansible-playbook playbook.yml --start-at-task="Copy nginx configuration"
To run only the tasks tagged with install (in this case, only the "Install nginx" task):
ansible-playbook playbook.yml --tags install
28. I have a playbook whose logs I want no one to see while running. How to achieve it?

In Ansible, no_log: true is used to suppress task output and hide sensitive information (such as passwords or API keys) from being printed to the console or logs. It prevents any output (including errors) for tasks where you want to ensure confidentiality.

30. What is the difference between ALB and NLB in AWS?
31. What happens if you stop and start an EC2 instance with an ephemeral volume?
32. How do you create a CloudWatch alarm for high CPU usage ?
33. Can you design an web server with HA along with loadbalcing.
34. What is the use case of NAT Gateway and in which subnet will you create this.
35. How VM from private subnet can reach to internet to download any package.
36. What is VPC peering and how can u configure it.
37. What is the diff between SG and NACL ?
38. What is the diff between Elastic IP and Public IP and Private IP ?
39. What is the diff between ALB and NLB ?
40. What is the usecase of ASG ?
41. Your Private EC2 instance need to connect to S3 bucket. How will you achieve this ?
42. How can u optimize the S3 cost ?
43. What is s3 bucket versioning ?
44. What is the diff between Authentication and Authorization ?
45. What is the diff between IAM role and IAM policy ?
