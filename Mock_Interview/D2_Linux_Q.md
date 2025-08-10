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

Q3. Boot Process: Can you explain what happens from the moment you power on a Linux system till you get the login prompt?
* **Answer :**

1. **BIOS** – Initializes hardware and finds boot device.
2. **MBR/GPT** – Loads the bootloader (GRUB).
3. **GRUB** – Loads the kernel and initrd.
4. **Kernel** – Initializes drivers, mounts root FS.
5. **init/systemd** – Starts target services.
6. **Login Prompt** – System ready for user login.

**Details:**
## Step 1: BIOS / UEFI

### BIOS:

* Stands for **Basic Input/Output System**.
* The first program executed, stored in read-only memory on the motherboard.
* Performs **POST (Power-On Self-Test)** to verify hardware components and peripherals.
* Checks for bootable devices like hard disk, USB, CD, etc.
* Once a bootable device is detected, it hands over control to the **first sector** of the bootable device (i.e., **MBR**).

### UEFI (Unified Extensible Firmware Interface):

* Modern replacement for BIOS.
* Stored on the motherboard; provides more advanced features:

  * Supports disks **larger than 2 TB**.
  * Boots from **GPT-partitioned** disks.
  * Provides a **graphical interface** and **mouse support**.
  * Supports **Secure Boot**, **fast boot**, and **network boot (PXE)**.
  * Looks for **EFI executable files** in the **EFI System Partition** (usually `/boot/efi/EFI/`).

---

## Step 2: MBR / GPT

### MBR (Master Boot Record)
* Stands for **Master Boot Record**.
* Located in the **first 512 bytes** of any bootable device.
* Contains machine code instructions for booting and includes:

  * **Boot Loader** (446 bytes)
  * **Partition Table** (64 bytes)
  * **Boot Signature/Error Checking** (2 bytes)
* Loads the bootloader into memory and hands over control.

### GPT (GUID Partition Table)

* Stands for **GUID Partition Table**.
* Modern replacement for MBR, used with **UEFI** firmware.
* Key features:

  * Supports **disks larger than 2 TB**.
  * Allows up to **128 partitions**.

---

## Step 3: GRUB (GRand Unified Bootloader)

* Loads the following configuration files at boot time:

  * `/boot/grub2/grub.cfg` (BIOS)
  * `/boot/efi/EFI/redhat/grub.cfg` (UEFI)
* Displays GUI/text menu to select OS or Kernel.
* Once a kernel is selected, GRUB locates:

  * Kernel binary: `/boot/vmlinuz-<version>`
  * Initramfs image: `/boot/initramfs-<version>.img`
* Main job is to load the **kernel** and **initramfs** into memory.
* **Note:**

  * `initrd` was used before Linux 7.
  * From Linux 7 onward, `initramfs` is used.
* GRUB is primarily for **x86 architectures**.

  * Other architectures may use different bootloaders (e.g., **ELILO** for Intel Itanium).

---

## Step 4: Kernel

* The **kernel** is loaded into memory by GRUB2 in **read-only** mode.
* The **initramfs** provides a minimal root filesystem to:

  * Detect hardware
  * Load required drivers/modules
  * Mount the real root filesystem (e.g., LVM, RAID)
* After the real root filesystem is mounted, initramfs is removed from memory.
* The kernel then executes the first **user-space process**: `systemd`.

> **Note:** Kernel and initramfs files are stored in the `/boot` directory.

---

## Step 5: Systemd

* First service/process started by the kernel with **PID 1**.
* Manages system boot, services, targets, and shutdown.
* Starts all required units as defined in:

  * `/etc/systemd/system/default.target`
* Brings the system to the appropriate **runlevel/target (0–6)**.
* View available targets:

  ```bash
  ls -l /usr/lib/systemd/system/runlevel*
  ```

## Step 6: Run Levels

* **Init 0** – Shutdown
* **Init 1** – Single User Mode
* **Init 2** – Multi User without Network
* **Init 3** – Multi User with Network
* **Init 4** – Unused
* **Init 5** – GUI Mode
* **Init 6** – Restart


Q4. How do you ensure a cron job ran successfully? What logs do you check and how would you debug a failing cron?
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

Q5. A log file is growing very large, and logrotate is not rotating it. What steps will you take to debug and fix this issue?
**Answer:**

* Check logrotate config: `/etc/logrotate.conf` or `/etc/logrotate.d/*`
* Run manually in debug mode:

```bash
logrotate -d /etc/logrotate.conf
```
* Check the logrotate service status or cron job is set properly or not to run the logrotate script.
* Ensure correct permissions, paths, and postrotate scripts.

---


Q6. When you are planning to patch production servers. What are the steps you take before and after patching?
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

Q7. One of your EC2 Linux servers is running slow. What Linux commands and tools do you use to troubleshoot performance issues?
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

Q8. Suppose you have received an alert stating that CPU utilization of any particular application server is high (85%). What steps will you take for this alert?
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


Q9. You deployed a web app using Nginx, but when accessing the site, you get a 502 Bad Gateway. How do you troubleshoot this?
* **Answer :**

* Check the nginx server is up and running if the server is shutdown state or due to high load sometime server won't respond.
* Check the nginx service status: `systemctl status nginx`
* Verify Nginx configuration: `nginx -t`
* Look for errors in Nginx logs: `/var/log/nginx/error.log`
* Check if the upstream server (e.g., application server) is running and reachable.
* Ensure the upstream server is correctly defined in the Nginx config
* Ensure backend app is running and reachable
* Curl backend directly: `curl localhost:<port>`

Q10. What is the minimal network traffic flow when accessing a web application hosted on an AWS Linux server from a browser?
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

Q11. How to check the current run level and user?
* `who -r`
* `whoami`

Q12. How do you view the contents of a .tar.gz file without extracting it?
* `tar -tzf file.tar.gz`

Q13. How do you check which ports are listening?
* `ss -tuln` or `netstat -tuln`

Q14. How do you list all running processes?
* Use `ps aux` or `top` or `ps -u <user>`.

Q15. What will be the cron expression if we want to run the job
* **Answer :**
1. Every one hour
2. Every one day
3. Twice in a day like morning 6 AM and 6 PM?
**Answer:**
* Every one hour: `0 */1 * * *`
* Every one day: `0 0 * * *`
* Twice a day at 6 AM and 6 PM: `0 6,18 * * *`

Q16. How will you check the security patches and severity?
* **Answer :**
- List Available Security Updates with Details: `yum updateinfo list security all`
```
RHSA-2025:1234 Important/Sec. kernel-3.10.0-1160.88.1.el7.x86_64
RHSA-2025:2345 Moderate/Sec. openssl-1.0.2k-25.el7_9.x86_64
RHSA-2025:3456 Low/Sec. bash-4.2.46-34.el7.x86_64

```
- Show Detailed Info (e.g., severity, CVE, advisory): `yum updateinfo info security`
- Filter by Severity (e.g., only Critical or Important): `yum updateinfo list security severity=Critical`
- View detailed info about the advisory: `yum updateinfo info RHSA-2025:1234`

Q17. How will you verify the severity and details of the patches for RHEL?
* We can verify the severity and details of the patches for Redhat Portal: [Red Hat Security](https://access.redhat.com/security/security-updates/)

Q18. How do you apply security updates only manually? And also if you have to update all the packages?
* Apply Security Updates Only: `yum update --security -y`
* Update All Packages: `yum update -y`

Q19. What is the drawback or issue that may arise if you update all available packages?
* Updating all packages may lead to compatibility issues with existing applications, as newer versions of libraries or dependencies may not be compatible with the current application code.

Q20. How do you check if a reboot is required after patching?
```bash
needs-restarting -r
```

Q21. How do you list the patches or packages updated recently?
* To list recently updated packages, you can use:
```bash
rpm -qa --last | head -n 10
```

Q22. Suppose you have updated one system and want to roll back to the previous state — how will you do that from the OS?
```bash
yum history list
yum history info <transaction_id>
yum history undo <transaction_id>
```

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



Q25. How can you ensure the services that were running before patching are still running after applying security patches and rebooting in RHEL?
* List active services and store the output:
`systemctl list-units --type=service --state=running > /root/running-services-before.txt`
* After reboot, list running services again:
`systemctl list-units --type=service --state=running > /root/running-services-after.txt`
Compare both lists: `diff /root/running-services-before.txt /root/running-services-after.txt`
# This will show which services are missing, added, or unchanged.