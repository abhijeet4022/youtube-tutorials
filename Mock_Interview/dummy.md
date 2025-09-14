## Q1. What is Ansible and why is it used?

**Answer:**

Ansible is an agentless automation tool for configuration management, application deployment, and orchestration.

- Uses YAML-based playbooks to define tasks.
- Works over SSH (Linux) or WinRM (Windows).
- **Use cases:** Automating server setup, deploying applications, managing multi-tier infrastructure.

---

## Q2. What is the main difference between Ansible and shell scripting?

| Feature        | Shell Script                  | Ansible                                 |
|---------------|------------------------------|-----------------------------------------|
| Execution     | Runs on a single machine     | Runs across multiple hosts simultaneously|
| Idempotency   | Manual checks needed         | Idempotent by default                   |
| Reusability   | Limited                      | High (playbooks, roles)                 |
| Error Handling| Manual                       | Built-in error handling and reporting   |
| Syntax        | Bash/PowerShell              | YAML, readable & structured             |

✅ **Summary:** Ansible is more scalable, reusable, and readable than plain shell scripts.

---

## Q3. How do you run an Ansible playbook (nginx.yaml) on a specific host (e.g., 192.168.1.10) using a custom inventory file (app)?
ansible-playbook -i app nginx.yaml -l 192.168.1.10


---

## Q4. What are Ansible Roles and why do we use them?

**Answer:**

Roles allow organizing playbooks into reusable components.

**Standard directory structure:**
```
roles/                      # Directory containing roles (modular, reusable units)
│   └── nginx/                  # Example of a role for configuring Nginx
│       ├── tasks/              # Tasks define the main actions to be performed
│       │   └── main.yml        # Main task file for the role (e.g., installing/configuring nginx)
│       │
│       ├── handlers/           # Handlers to manage specific services or actions (triggered by tasks)
│       │   └── main.yml        # Handler file for the role (e.g., restarting nginx)
│       │
│       ├── templates/          # Jinja2 templates to be used in the tasks (configuration files, etc.)
│       │   └── nginx.conf.j2   # Example of a template for nginx.conf
│       │
│       ├── vars/               # Variables specific to the role
│       │   └── main.yml        # Define variables for Nginx configuration
│       │
│       ├── defaults/           # Default variables for the role (can be overridden in playbooks)
│       │   └��─ main.yml        # Default values for variables
│       │
│       └── meta/               # Metadata for the role (role dependencies, author, etc.)
│           └── main.yml        # Role metadata (e.g., dependencies, author info)
```
---

## Q5. How do you pass variables and call them in Ansible?

**Answer:**

### 1️⃣ Play-level variables (defined in the playbook)
```yaml
- hosts: webservers
  vars:
    app_version: 3.0
  tasks:
    - name: Show app version
      debug:
        msg: "Deploying version {{ app_version }}"
```
*`app_version` is global for all hosts in this play.*

### 2️⃣ Extra-vars (at runtime)
```bash
ansible-playbook -i app nginx.yaml -e "app_version=3.0"
```

---

## Q6. What is the use of Template in Ansible?

**Answer:**

Templates are Jinja2 files used to dynamically generate/override the configuration files.
They allow us to use variables and expressions in config files.

**Example:** While we are copying the configuration file we need to replace some values based on the host we can do that by templates.

## Q6. What is difference between Template and Copy module in Ansible?
Template is for deploying dynamic files with variables replaced at runtime, while Copy is for static files deployed as-is.

---

## Q7. How to run any job of a particular role?

**Answer:**
```yaml
- name: Catalogue Configuration
  ansible.builtin.import_role:
    name: common
    tasks_from: nodejs
```
`tasks_from` specifies which tasks file in the role to execute.

---

## Q8. How to import tasks in a playbook?

**Answer:**
```yaml
- name: Schema setup
  ansible.builtin.import_tasks: schema.yml
  when: schema is defined
```
`import_tasks` is static and brings in tasks at playbook parse time.

---

## Q9. How to call a role from an Ansible playbook?

**Answer:**
```yaml
- hosts: webservers
  roles:
    - common
    - nginx
```
Roles are executed in the order they appear.

---

## Q10. You have many plays in a playbook but need to run a particular play. How can you achieve it?

**Answer:**
- Use `--tags` to run tasks with specific tags.
- Use `--start-at-task` to start execution from a specific task.

**Example:**
```bash
ansible-playbook playbook.yml --start-at-task="Copy nginx configuration"
ansible-playbook playbook.yml --tags install
```

---

## Q11. I have a playbook whose logs I want no one to see while running. How to achieve it?

**Answer:**
Use `no_log: true` in the task to suppress output.

```yaml
- name: Install secret package
  yum:
    name: secretpkg
    state: present
  no_log: true
```
Prevents sensitive information from being displayed in console or logs.

---

## Q12. What is dynamic inventory in Ansible and how do you manage it?

**Answer:**

In Ansible, an inventory is a list of managed nodes. A dynamic inventory allows Ansible to fetch this list dynamically from external sources such as cloud providers (AWS, Azure, GCP), databases, or APIs, instead of using a static file.

This is particularly useful in cloud environments where servers are provisioned or terminated dynamically. Instead of manually updating an inventory file, Ansible can query live instances and retrieve host information on demand.

### Example: Configuring Dynamic Inventory for AWS EC2 using Inventory Plugin

#### Step 1: Install Required Dependencies
Before setting up the inventory, install the boto3 and botocore Python libraries, which allow Ansible to interact with AWS.

```bash
pip install boto3 botocore
```

#### Step 2: Create an AWS EC2 Inventory File (`aws_ec2.yml`)

```yaml
plugin: amazon.aws.aws_ec2  # Specifies the AWS EC2 inventory plugin
regions:
  - ap-southeast-1          # Define the AWS region(s) to query instances from
keyed_groups:
  - key: tags.Name          # Group EC2 instances based on their "Name" tag
    prefix: instance_       # Prefix groups with "instance_" (e.g., instance_webserver)
filters:
  instance-state-name: running  # Only include running instances
compose:
  ansible_host: public_ip_address  # Use the public IP for SSH connections
```

#### Step 3: Test the Inventory Configuration
Run the following command to retrieve a list of AWS EC2 instances dynamically:

```bash
ansible-inventory -i aws_ec2.yml --list
```
This will output a real-time inventory of all running instances in `ap-southeast-1`, grouped by their tags.

#### Step 4: Use Dynamic Inventory in a Playbook
Once the dynamic inventory is working, you can use it in an Ansible playbook:

```bash
ansible-playbook -i aws_ec2.yml playbook.yml
```
This ensures that Ansible runs on the latest set of instances without manually updating inventory files.