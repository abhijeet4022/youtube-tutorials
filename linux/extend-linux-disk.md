🔧 **In this video, learn how to safely extend the root OS or data disk on an AWS EC2 Linux instance — whether you're using LVM (Logical Volume Manager) or a standard partition setup.** If your server is running out of space or you're preparing for future growth, these steps will help you scale efficiently and without downtime.

> ⚠️ Note: Downtime is required for Azure VM OS disk extension.

---

📌 **Topics Covered in the Video:**
- Increasing EBS volume size from the AWS Console
- Extending the disk inside the Linux OS
- Resizing the Physical Volume (PV)
- Extending the Logical Volume (LV)
- Resizing the filesystem (XFS or EXT4)

---

🖥️ **Steps Covered in Detail:**

### ✅ Step 1: Verify current disk and partition layout
```bash
lsblk
```

### ✅ Step 2: Extend the partition using `growpart`
```bash
sudo growpart /dev/nvme0n1 4
```
⚠️ Replace `4` with your actual partition number.

### ✅ Step 3: Inform the kernel about partition changes
```bash
sudo partprobe /dev/nvme0n1
```
Alternative: `sudo partx -u /dev/nvme0n1`

### ✅ Step 4: Resize the LVM physical volume
```bash
sudo pvresize /dev/nvme0n1p4
```

### ✅ Step 5: Extend the logical volume
```bash
sudo lvextend -l +100%FREE /dev/RootVG/homeVol
```

### ✅ Step 6: Resize the filesystem based on type

Check filesystem type:
```bash
df -Th /home
```

If XFS:
```bash
sudo xfs_growfs /home
```

If EXT4:
```bash
sudo resize2fs /dev/RootVG/homeVol
```

---

🛡️ **Best Practices:**
- Always create an EBS snapshot before making changes.
- Use commands like `lsblk`, `pvs`, `lvs`, and `df -h` to verify each step.

---

📁 **Useful Commands:**
- `lsblk`, `growpart`, `partprobe`, `pvresize`, `lvextend`, `xfs_growfs`, `resize2fs`

---

💬 **Don’t forget to Like 👍, Comment 💬, and Subscribe 🔔 for more AWS & Linux tutorials!**

---

**#AWS #Linux #EC2 #LVM #RootDiskExtension #CloudOps #SysAdmin #DevOps #AWSLinuxTutorial**
