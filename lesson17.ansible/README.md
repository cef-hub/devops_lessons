## 1. Создали файл с переменными group_vars/vars_ec2.yml

```
access_key: <access_key>
secret_key: <secret_key>
region: us-east-1
name_ec2_node1: s.kruhlik-ec2-ansible

```

## 2. Создали файл Playbook playbook-ec2.yml

```

- name: "PlaybookName: Create EC2 instance"
  hosts: localhost
  become: yes
  vars_files:
    - group_vars/vars_ec2.yml

  tasks:

    - name: "Task2: Install Python pakets"
      pip:
        name:
          - botocore
          - boto3

    - name: "Task3: Start ec2 instances"
      amazon.aws.ec2_instance:
        name: "{{ name_ec2_node1 }}"
        instance_type: t2.micro
        image_id: ami-044a3516c1b05985f
#        count: 1
        region: "{{ region }}"
        network:
          assign_public_ip: true
          security_group: lesson10
          vpc_subnet_id: default
        key_name: devops
        aws_access_key: "{{ access_key }}"
        aws_secret_key: "{{ secret_key }}"
        region: "{{ region }}"
        tags:
          s.kruhlik: dev_environment

    - name: "Task4: Pause for 60 seconds"
      pause:
        seconds: 60
        
    - name: "Task5: Run script to get ec2_tag_Name and ip_address"
      command: ./parser_tag.py
      register: parser_output
      become: true

    - set_fact:
        ec2_tag_Name: "{{ parser_output.stdout | from_json | json_query(\"ec2_tag_Name\") }}"
        ip_address_ec2: "{{ parser_output.stdout | from_json | json_query(\"ip_address_ec2\") }}"
        ec2_instance_ids: "{{ parser_output.stdout | from_json | json_query(\"ec2_id\") }}"

    - name: "Task6: Install Docker"
      delegate_to: "{{ ip_address_ec2 }}"
      become: true
      remote_user: ec2-user
      environment:
        ANSIBLE_REMOTE_TMP: /tmp/.ansible/tmp     
      vars:
        ansible_ssh_private_key_file: ./devops.pem
      shell: "curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
      when: ec2_tag_Name is defined

    - name: "Task7: Start Docker service"
      delegate_to: "{{ ip_address_ec2 }}"
      become: true
      remote_user: ec2-user
      environment:
        ANSIBLE_REMOTE_TMP: /tmp/.ansible/tmp     
      vars:
        ansible_ssh_private_key_file: ./devops.pem
      service:
        name: docker
        state: started
      when: ec2_tag_Name is defined

    - name: "Task8: Run Docker container"
      delegate_to: "{{ ip_address_ec2 }}"
      become: true
      remote_user: ec2-user
      environment:
        ANSIBLE_REMOTE_TMP: /tmp/.ansible/tmp     
      vars:
        ansible_ssh_private_key_file: ./devops.pem
      docker_container:
        name: docker_httpd
        image: httpd:latest
        state: started
        ports:
          - "80:80"
      when: ansible_os_family == 'RedHat' and ec2_tag_Name is defined

    - name: "Task9 Terminate instances that were previously launched"
      amazon.aws.ec2_instance:
        state: "absent"
        instance_ids: "{{ ec2_instance_ids }}"

```

## 3. Создали файл parser_tag.py парсер для ec2.py ec2.ini

```

#!/usr/bin/python3.9

import subprocess
import json
import os
import yaml

path = './group_vars/'
ans_vars = 'vars_ec2.yml'

with open(f'{path + ans_vars}', 'r', encoding='utf-8') as file:
    data = yaml.safe_load(file)
    
name_ec2_node1_value = None

for key, value in data.items():
    if key == 'name_ec2_node1':
        name_ec2_node1_value = value
        break 
        
os.environ["EC2_TAG_NAME"] = name_ec2_node1_value
output = subprocess.check_output(['./ec2.py', '--list'])
output_json = json.loads(output)
#print(output_json)

try:
    for ip_address, details in output_json["_meta"]["hostvars"].items():
        if "ec2_tag_Name" in details:
            ec2_tag_Name = details["ec2_tag_Name"]
            if ec2_tag_Name == os.environ["EC2_TAG_NAME"]:
                ip_address_ec2 = ip_address
                ec2_id = details["ec2_id"]
    if ec2_tag_Name is not None and ip_address_ec2 is not None:
        result = {"ec2_tag_Name": ec2_tag_Name, "ip_address_ec2": ip_address_ec2, "ec2_id": ec2_id}
        print(json.dumps(result))
        #print(type(result))
    else:
        print(json.dumps({}))
except KeyError as e:
    print("Ошибка:", e)

```

## 4. Запустили Playbook playbook-ec2.yml

```

[root@devops lesson17.ansible]# ansible-playbook playbook-ec2.yml

```

<sub>


PLAY [PlaybookName: Create EC2 instance] *********************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************
ok: [localhost]

TASK [Task2: Install Python pakets] **************************************************************************************************************************************
ok: [localhost]

TASK [Task3: Start ec2 instances] ****************************************************************************************************************************************

[WARNING]: Both option access_key and its alias aws_access_key are set.

[WARNING]: Both option secret_key and its alias aws_secret_key are set.

changed: [localhost]

TASK [Task4: Pause for 60 seconds] ***************************************************************************************************************************************

Pausing for 60 seconds

(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)

ok: [localhost]

TASK [Task5: Run script to get ec2_tag_Name and ip_address] **************************************************************************************************************
changed: [localhost]

TASK [set_fact] **********************************************************************************************************************************************************
ok: [localhost]

TASK [Task6: Install Docker] *********************************************************************************************************************************************

The authenticity of host '54.234.140.245 (54.234.140.245)' can't be established.

ED25519 key fingerprint is SHA256:pca9bS10GXGg4Pbko1c7ddPGLS7Rfm3aSbhb/faMS0k.

This key is not known by any other names

Are you sure you want to continue connecting (yes/no/[fingerprint])? yes

changed: [localhost -> 54.234.140.245]

TASK [Task7: Start Docker service] ***************************************************************************************************************************************

changed: [localhost -> 54.234.140.245]

TASK [Task8: Run Docker container] ***************************************************************************************************************************************

changed: [localhost -> 54.234.140.245]

TASK [Task9 Terminate instances that were previously launched] ***********************************************************************************************************
changed: [localhost]

PLAY RECAP ***************************************************************************************************************************************************************

localhost                  : ok=10   changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


</sub>