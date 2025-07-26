**15. How do you find 30 days old a files in /tmp nad delete those files in Linux?**

* `find /tmp -type f -mtime +30 -exec rm -f {} \;`

**1. How do you find files in linux?**
* `find /path -name filename`
* `locate filename` (requires `updatedb`)

**12. How do you view the contents of a `.tar.gz` file without extracting it?**

* `tar -tzf file.tar.gz`

**10. How do you check which ports are listening?**

* `ss -tuln` or `netstat -tuln`

**6. How do you list all running processes?**

* Use `ps aux` or `top` or `ps -u <user>`.