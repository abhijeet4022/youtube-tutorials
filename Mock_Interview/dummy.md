
Q. How can you recover if ec2 key lost

Q. What is the use of Template in ansible ?
Q. How to run any job of particular role
name: Catalogue Configuration ansible.builtin.import_role: name: common tasks_from: nodejs
How to import task
name: Schema setup ansible.builtin.import_tasks: schema.yml when: schema is defined
Q. How to call any role from anisble playbook?

I have many plays in a playbook but I want only few plays in it to run. How can I achieve it?
Use --tags or --start-at-task.

To run the playbook starting from the "Copy nginx configuration" task, use the following command: ansible-playbook playbook.yml --start-at-task="Copy nginx configuration" To run only the tasks tagged with install (in this case, only the "Install nginx" task): ansible-playbook playbook.yml --tags install 28. I have a playbook whose logs I want no one to see while running. How to achieve it?

In Ansible, no_log: true is used to suppress task output and hide sensitive information (such as passwords or API keys) from being printed to the console or logs. It prevents any output (including errors) for tasks where you want to ensure confidentiality.






