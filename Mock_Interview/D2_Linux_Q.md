**Linux Interview FAQs**

1. What is the use case of /opt and /var/lib? Explain with one example.

   * `/opt` is used for installing third-party applications, For example, installing third-party software like Google Chrome or Splunk.
     Example: `/opt/splunk`

   * `/var/lib` is used to store persistent and dynamic data for services and system applications.
     For example:

      * MySQL stores database files in `/var/lib/mysql`.

      * systemd stores persistent journal logs in `/var/lib/systemd/journald`, especially when `/var/log/journal` is not configured. This ensures logs are preserved across reboots.

      * Package managers may also store metadata here (e.g., `/var/lib/dpkg` for APT, `/var/lib/rpm` for YUM).

     > This directory is essential for maintaining the operational state of services between system restarts.

2. Which folder is responsible for storing logs?

   * `/var/log` is the default directory for storing log files in Linux.

3. In which file are SSH-related logs stored?

   * SSH logs are usually found in `/var/log/auth.log` or `/var/log/secure`, depending on the Linux distribution.

4. Suppose you're on a call with a user trying to SSH into a machine. How would you view SSH-related logs in real time?

   * Use: `tail -f /var/log/auth.log` or `journalctl -f -u sshd`

5. What do the five fields (stars) in a cron job represent?

   * Minute, Hour, Day of Month, Month, Day of Week.

6. You need to run a script every night at 12:30 AM. How would you schedule that using a cron job?

   * `30 0 * * * /path/to/script.sh`
     This is a cron job format and should be placed in the crontab. We can add it using `crontab -e` for user-specific jobs or `/etc/crontab` for system-wide.

7. You have a requirement: /var/log/messages should rotate weekly, retain 4 files, have permissions "root root 640", be compressed, and not rotate if empty. How would you configure this using logrotate?

   * Create a file `/etc/logrotate.d/messages` with:

     ```
     /var/log/messages {
         weekly
         rotate 4
         compress
         missingok
         notifempty
         create 640 root root
     }
     ```

8. How would you extend swap space on an LVM-based system from 4GB to 8GB?

   * Steps:

     ```
     free -h  # Check current swap space
     cat /proc/swaps  # Verify swap devices
     swapoff -v /dev/mapper/vg0-swap # Disable swap
     lvresize -L 8G /dev/mapper/vg0-swap # Resize the logical volume
     mkswap /dev/mapper/vg0-swap # Recreate the swap area
     swapon /dev/mapper/vg0-swap # Enable the swap
     swapon -s  # Verify the new swap space
     ```

9. You are trying to create a file, but even though there is enough space, it fails. What could be the reasons?

   * Possible reasons: inode exhaustion, permission issues, disk quota limits, or read-only file system.
     If the issue is due to inode exhaustion, you can:

      * Identify the problem using: `df -i`
      * Locate directories with a high number of small files using: `find /path -xdev -type f | cut -d/ -f2 | sort | uniq -c | sort -n`
      * Remove or archive old/unnecessary files
      * Alternatively, repartition the disk with a larger inode ratio.

10. How can you ensure that a specific service runs automatically after the server reboots?

   * Use: `systemctl enable service-name`

11. What is the directory where all systemd service unit files are stored?

   * `/etc/systemd/system` for custom services, `/usr/lib/systemd/system` for package-installed services.

12. Which directories typically contain all commands in Linux?

   * `/bin`, `/sbin`, `/usr/bin`, `/usr/sbin`

13. What is the use case of NFS and how can you configure it? Suppose you want to share a 20GB mount point (/mnt/share) using NFS—how would you set it up, and how would a client machine mount it permanently?

   * On server: Add `/mnt/share *(rw,sync)` in `/etc/exports`, run `exportfs -a` and start `nfs-server`
     On client: Add `server:/mnt/share /mnt nfs defaults 0 0` in `/etc/fstab` and run `mount -a`

14. Can you explain the entries inside /etc/fstab and the use case of this file?

   * `/etc/fstab` stores persistent mount info. Fields: device, mount point, fs type, options, dump, pass.

15. Suppose you have a directory /mnt/share and the requirement is that any new files or folders created should have group ownership set to "linuxteam". How would you configure that?

   * Set group: `chgrp linuxteam /mnt/share`
     Enable SGID: `chmod g+s /mnt/share`

16. In a directory (e.g., /mnt) where all users have full permissions, how would you restrict other users from deleting any files.?

   * Use sticky bit: `chmod +t /mnt`

17. How would you identify whether a path is a file or a directory in Linux?

   * Use: `ls -l` or `file path`
     In `ls -l`, the first character indicates the file type:

      * `-` = regular file
      * `d` = directory
      * `l` = symbolic link
        This helps you quickly distinguish between file types in the listing.

18. What is a soft link and how do you create one?

   * A soft link points to another file path. Create with: `ln -s target linkname`

19. How can you set the owner of /sap directory to "root" and the group owner to "sap"?

   * `chown root:sap /sap`

20. How do you set permissions on /boot directory so the user has rwx, the group has read-only, and others have no access?

   * `chmod 740 /boot`

21. How would you give both "linux" and "sap" teams rwx permissions on the /sap directory?

   * Using ACL:
     `setfacl -m g:linux:rwx /sap`
     `setfacl -m g:sap:rwx /sap`

     > Ensure ACLs are enabled on the filesystem. You can view them with `getfacl /sap`.

22. Which file stores user account information and what kind of details does it hold?

   * `/etc/passwd` holds username, UID, GID, home, shell, etc.

23. What are the default home directories for normal users and the root user?

   * Normal users: `/home/username`
     Root: `/root`

24. What is a umask value and how do you change it temporarily and permanently?

   * `umask` defines default permissions.
     Temporary: `umask 027`
     Permanent: in `~/.bashrc` or `/etc/profile`

25. When a user logs in to the server, which default file executes automatically to load the user's environment?

   * Files like `~/.bash_profile`, `~/.bashrc`, and `/etc/profile`

26. How do you list all disks and their mount points?

   * Use: `lsblk`, `df -h`, or `mount`

27. Suppose you’re using an httpd web server and there’s a file named private.html inside /var/www/html. How would you change its context to restrict access using SELinux?

   * Use:

     ```bash
     semanage fcontext -a -t default_t "/var/www/html/private.html"
     restorecon -v /var/www/html/private.html
     ```

     > Note: `httpd_sys_content_t` allows the web server to read content. If you want to deny access, avoid assigning this type or use a type like `default_t`.

28. What is the difference between -9 and -15 signals when using kill or pkill?

   * `-15` (SIGTERM) asks process to terminate gracefully. `-9` (SIGKILL) forcefully kills it.

29. There is a user named "abc". How would you grant this user sudo access without prompting for a password?

   * Add line in sudoers: `abc ALL=(ALL) NOPASSWD:ALL`

30. What are the default port numbers for SSH, RDP, HTTP, HTTPS, and NFS?

   * SSH: 22, RDP: 3389, HTTP: 80, HTTPS: 443, NFS: 2049

31. What is an SSL certificate?

   * A digital certificate for encrypted communication and identity verification over HTTPS.

32. How do you install a package like httpd in Linux?

   * RHEL/CentOS: `yum install httpd`
     Ubuntu: `apt install apache2`

33. Can you set up a custom repository in Linux?

   * Yes. Create a `.repo` file under `/etc/yum.repos.d/` (RHEL) or add APT source in `/etc/apt/sources.list`

     For YUM (RHEL/CentOS):

     Save this in `/etc/yum.repos.d/myrepo.repo`

     ```
     [myrepo]
     name=My Custom Repo
     baseurl=http://example.com/repo/
     enabled=1
     gpgcheck=0
     ```

     For APT (Debian/Ubuntu):
     Add to `/etc/apt/sources.list`:

     ```
     deb http://example.com/debian stable main
     ```

34. What is the internal process flow when installing a package using a package manager?

   * Checks repo -> resolves dependencies -> downloads -> installs files -> runs post-scripts

35. How do you list all configured repositories on a Linux system?

   * For RHEL/CentOS: `yum repolist all` or `dnf repolist all`
     For Debian/Ubuntu: `apt-cache policy` or `apt list --installed`

36. Which default file stores user password expiry information?

   * `/etc/shadow`

37. You need to enforce a password policy: expiration every 90 days, a warning 14 days before expiry, and automatic account disablement if not changed within 115 days. How would you implement this?

   * Use `chage` command:

     ```
     chage -M 90 -W 14 -I 25 username
     ```
38. Which file is responsible to carry the default values related to user password policy?

   * `/etc/login.defs` – This file defines site-specific configuration for the shadow password suite. It includes default password aging and user ID control values such as:

   ```
   PASS_MAX_DAYS   90     # Maximum number of days a password is valid. After 90 days, the user must change the password.
   PASS_MIN_DAYS   7      # Minimum number of days between password changes. Users can't change the password within 7 days of the last change.
   PASS_WARN_AGE   14     # Number of days before password expiry that the user will be warned.
   UID_MIN         1000   # Minimum UID for regular (non-system) user accounts.
   UID_MAX         60000  # Maximum UID for regular user accounts.
   ```
   > These defaults are used when creating new users and enforcing password policies.

39. How do you find 30 days old a files in /tmp nad delete those files in Linux?**

    * `find /tmp -type f -mtime +30 -exec rm -f {} \;`