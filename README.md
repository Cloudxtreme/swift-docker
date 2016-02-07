This repository provides Ansible configuration for setting up a Tailor
application environment in AWS.

### Getting Started

Before you can use these scripts, you must provide some custom information:

1.  Copy the files from roles/vars into vars/, and fill in the details of your
    credentials and your environment's structure.

You also have to install ansible and docker.

Then, you can just run `ansible-playbook -i aws.py main.yml` to create a
development environment. To create a different kind of environment, you can
set the `env` variable: `ansible-playbook -i aws.py -e env=staging main.yml`.