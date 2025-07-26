# AWS and Linux Interview Questions with Answers (For 3+ Years Experience)

“Hi Abhijeet, thank you for joining. Let's begin with a few technical questions related to your resume.”

---

### Topics Covered:

* Linux (LVM, Cron, Boot Process, etc.)
* AWS (EC2, ELB, S3, CloudWatch, etc.)

---

## 🐧 Linux Questions & Answers

### 1. **LVM**

You're running out of space on `/var`, which is an LVM volume. Walk me through the steps to increase the size of `/var` by 5GB. Assume a new disk `/dev/xvdf` is attached.

**Answer:**

```bash
# 1. Create a new partition
fdisk /dev/xvdf
# Create primary partition and save

# 2. Create physical volume
pvcreate /dev/xvdf1

# 3. Extend volume group
vgextend <vg_name> /dev/xvdf1

# 4. Extend logical volume
lvextend -L +5G /dev/<vg_name>/<lv_name>

# 5. Resize filesystem
resize2fs /dev/<vg_name>/<lv_name>   # For ext4
xfs_growfs /var                       # For xfs
```

---

### 2. **Boot Process**

Can you explain what happens from the moment you power on a Linux system till you get the login prompt?

**Answer:**

1. **BIOS** – Initializes hardware and finds boot device.
2. **MBR/GPT** – Loads the bootloader (GRUB).
3. **GRUB** – Loads the kernel and initrd.
4. **Kernel** – Initializes drivers, mounts root FS.
5. **init/systemd** – Starts target services.
6. **Login Prompt** – System ready for user login.

---

### 3. **Cron Job**

How do you ensure a cron job ran successfully? What logs do you check and how would you debug a failing cron?

**Answer:**

```bash
grep CRON /var/log/cron   # or journalctl -u crond
```

* Ensure the script is executable.
* Add logging: `myjob.sh > /tmp/myjob.log 2>&1`

---

### 4. **Logrotate**

A log file is growing very large, and logrotate is not rotating it. What steps will you take to debug and fix this issue?

**Answer:**

* Check logrotate config: `/etc/logrotate.conf` or `/etc/logrotate.d/*`
* Run manually in debug mode:

```bash
logrotate -d /etc/logrotate.conf
```

* Ensure correct permissions, paths, and postrotate scripts

---

### 5. **OS Patching**

Your team is planning to patch production servers. What are the steps you take before, during, and after patching?

**Answer:**
**Before:**

* Notify stakeholders
* Backup or snapshot
* Check disk, memory, uptime

**During:**

* Use `dnf/yum update` or `apt upgrade`
* Log output for review

**After:**

* Reboot if needed
* Validate service health
* Verify kernel version

---

### 6. **Performance Monitoring**

One of your EC2 Linux servers is running slow. What Linux commands and tools do you use to troubleshoot performance issues?

**Answer:**

```bash
top/htop       # CPU, memory
vmstat         # Memory and CPU activity
iostat -x      # Disk I/O
free -h        # Memory usage
df -h / du -sh # Disk usage
sar            # Historical stats
```

---

## ☁️ AWS Questions & Answers

### 7. **EC2 & EBS**

A user reports they can’t SSH into an EC2 instance. What steps do you take to troubleshoot?

**Answer:**

* Check security group (port 22 allowed)
* Check network ACL
* Validate key pair used
* Use EC2 serial console or Systems Manager if locked out

---

### 8. **S3**

You need to allow access to a private S3 bucket only from a specific VPC. How would you implement that?

**Answer:**
Use S3 Bucket Policy with VPC condition and a VPC endpoint:

```json
{
  "Condition": {
    "StringEquals": {
      "aws:SourceVpc": "vpc-xxxxxx"
    }
  }
}
```

---

### 9. **ELB & ASG**

An EC2 in an ASG is marked as unhealthy and getting replaced. How do you investigate what’s going wrong?

**Answer:**

* Check ELB health check path and response (expect HTTP 200)
* Ensure backend service is up and responding
* Review logs: `/var/log/cloud-init.log`, `/var/log/messages`
* Validate user-data script and app readiness

---

### 10. **IAM**

Explain how IAM policies and roles differ. Also, how do you give an EC2 instance access to read an S3 bucket?

**Answer:**

* **IAM Role**: Assigned to resources; grants temporary permissions
* **IAM Policy**: Defines permissions; can be attached to users, groups, roles

To give EC2 S3 access:

* Create IAM Role with S3 read policy
* Attach the role to EC2 instance

---

### 11. **Route 53 & DNS**

How does Route 53 work with multiple availability zones? What routing policy would you use for low-latency global access?

**Answer:**

* Route 53 routes to healthy AZs via ELB
* Use **Latency-based routing** for best global performance

---

### 12. **Monitoring – CloudWatch, Prometheus, Grafana**

You want to monitor disk usage across all EC2 instances and send alerts if it goes above 80%. How would you do that using CloudWatch and/or Prometheus-Grafana?

**Answer:**
**Using CloudWatch:**

* Install CloudWatch Agent
* Push `disk_used_percent` metric
* Create alarm for `> 80%`

**Using Prometheus + Grafana:**

* Install node\_exporter
* Create Grafana alert panel
* Define PromQL rule: `node_filesystem_usage > 0.8`

---

### 13. **EFS vs EBS**

What is the difference between EBS and EFS? When would you prefer one over the other?

**Answer:**

| Feature     | EBS                        | EFS                     |
| ----------- | -------------------------- | ----------------------- |
| Mount Type  | One EC2 (AZ-specific)      | Multiple EC2 (multi-AZ) |
| Performance | Block storage, low latency | Scalable, shared FS     |
| Use Case    | DB, OS disk, local storage | Shared access, NFS-like |

---

### 14. **Web Servers (Nginx/httpd)**

You deployed a web app using Nginx, but when accessing the site, you get a 502 Bad Gateway. How do you troubleshoot this?

**Answer:**

* Check `upstream` block in Nginx config
* Ensure backend app is running and reachable
* Curl backend directly: `curl localhost:<port>`
* Check Nginx logs: `/var/log/nginx/error.log`

---

### 15. How do you create a new user and set a password?**

* `useradd -m username`
* `passwd username`

---

### 16. How to check the current run level and user?**
* `who -r`
* `whoami`

---