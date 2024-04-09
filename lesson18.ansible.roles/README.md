## 1. Создали файл с переменными group_vars/tomcat_vars.yml

```
pass1: "tomcat"
pass2: "cef"

```

## 2. Создали каталог roles и скачали роль для установки Tomcat

```

[root@devops lesson18.ansible.roles]# mkdir -p roles
[root@devops lesson18.ansible.roles]# ansible-galaxy role install zaxos.tomcat-ansible-role --roles-path ./roles/

```

## 3. Создали файл Playbook playbook-tomcat.yml

```

- name: "Role install Tomcat"
  hosts: ansible_preprod
  become: true

  vars_files:
    - group_vars/tomcat_vars.yml

  pre_tasks:
    - name: "Task1: Check available version Tomcat"
      shell: dnf info tomcat | grep Version
      register: tomcat_info
      when: ansible_distribution == 'CentOS' and ansible_distribution_major_version == '9'

    - set_fact:
        tomcat_version: "{{ tomcat_info.stdout_lines[0].split(':')[1].strip() }}"
      when: ansible_distribution == 'CentOS' and ansible_distribution_major_version == '9' and tomcat_info is defined

  roles:
    - role: zaxos.tomcat-ansible-role
      vars:
        tomcat_version: "{{ tomcat_version }}"
        tomcat_permissions_production: True
        tomcat_users:
          - username: "tomcat"
            password: "{{ pass1 }}"
            roles: "tomcat,admin,manager,manager-gui"
          - username: "cef"
            password: "{{ pass2 }}"
            roles: "tomcat"
      when: ansible_distribution == 'CentOS' and ansible_distribution_major_version == '9' and tomcat_version is defined
      role_dependencies:
        - { role: zaxos.tomcat-ansible-role, task: "Task1: Check available version Tomcat" }

```

## 4. Запустили Playbook playbook-tomcat.yml first time

```

[root@devops lesson18.ansible.roles]# ansible-playbook -i hosts -l ansible_preprod playbook-tomcat.yml

```

<sub>


PLAY [Role install Tomcat] ***********************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************

ok: [ansible_dev_db]

TASK [Task1: Check available version Tomcat] *****************************************************************************************************************************

changed: [ansible_dev_db]

TASK [set_fact] **********************************************************************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Install Java] **************************************************************************************************************************

changed: [ansible_dev_db] => (item={'package': 'java-1.8.0-openjdk'})

TASK [zaxos.tomcat-ansible-role : Check if tomcat is already installed] **************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Create group tomcat] *******************************************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Create user tomcat] ********************************************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Create temp directory] *****************************************************************************************************************

skipping: [ansible_dev_db] => (item=localhost)

ok: [ansible_dev_db] => (item=ansible_dev_db)

TASK [zaxos.tomcat-ansible-role : Download apache-tomcat-9.0.62.tar.gz] **************************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : apache-tomcat-9.0.62.tar.gz is transfered to the disconnected remote] ******************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Unarchive apache-tomcat-9.0.62.tar.gz at /opt] *****************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Clean up temporary files] **************************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Setup server.xml] **********************************************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set fact of user roles to be enabled] **************************************************************************************************

ok: [ansible_dev_db] => (item={'username': 'tomcat', 'password': 'tomcat', 'roles': 'tomcat,admin,manager,manager-gui'})

ok: [ansible_dev_db] => (item={'username': 'cef', 'password': 'cef', 'roles': 'tomcat'})

TASK [zaxos.tomcat-ansible-role : Setup tomcat-users.xml] ****************************************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Create symlink /opt/apache-tomcat-9.0.62 to /opt/tomcat] *******************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Configure access to Manager app (from localhost only or from anywhere)] ****************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Configure access to Host Manager (from localhost only or from anywhere)] ***************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Configure setenv.sh] *******************************************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set root directory owner/group for production installation] ****************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set recursively directories owner/group for production installation] *******************************************************************

changed: [ansible_dev_db] => (item=bin)

ok: [ansible_dev_db] => (item=conf)

ok: [ansible_dev_db] => (item=lib)

TASK [zaxos.tomcat-ansible-role : Set recursively directories owner/group for production installation] *******************************************************************

changed: [ansible_dev_db] => (item=temp)

changed: [ansible_dev_db] => (item=work)

changed: [ansible_dev_db] => (item=logs)

TASK [zaxos.tomcat-ansible-role : Set recursively webapps directory owner/group for production installation] *************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set directories permissions for production installation] *******************************************************************************

changed: [ansible_dev_db] => (item=['bin', '2750', '0640'])

changed: [ansible_dev_db] => (item=['conf', '2750', '0640'])

changed: [ansible_dev_db] => (item=['lib', '2750', '0640'])

changed: [ansible_dev_db] => (item=['logs', '0300', '0640'])

ok: [ansible_dev_db] => (item=['temp', '0750', '0640'])

ok: [ansible_dev_db] => (item=['work', '0750', '0640'])

ok: [ansible_dev_db] => (item=['webapps', '0750', '0640'])

TASK [zaxos.tomcat-ansible-role : Set files permissions for production installation] *************************************************************************************

ok: [ansible_dev_db] => (item=['bin', '2750', '0640'])

changed: [ansible_dev_db] => (item=['conf', '2750', '0640'])

ok: [ansible_dev_db] => (item=['lib', '2750', '0640'])

ok: [ansible_dev_db] => (item=['logs', '0300', '0640'])

ok: [ansible_dev_db] => (item=['temp', '0750', '0640'])

ok: [ansible_dev_db] => (item=['work', '0750', '0640'])

ok: [ansible_dev_db] => (item=['webapps', '0750', '0640'])

TASK [zaxos.tomcat-ansible-role : Set bin/*.sh permissions to allow execution] *******************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set owner and group for non-production installation] ***********************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set directories permissions for non-production installation] ***************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set files permissions for non-production installation] *********************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Configure service file tomcat.service] *************************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Remove systemd service file from old path (before role update)] ************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Enable tomcat service on startup] ******************************************************************************************************

changed: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Check if tomcat service is installed] **************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Stop tomcat service if running] ********************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Remove service file tomcat.service] ****************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Perform systemctl daemon-reload] *******************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Check if tomcat is already uninstalled] ************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Remove symlink /opt/tomcat] ************************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Create backup archive before deletion at /opt/tomcat-backup-XXX.tgz] *******************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Remove /opt/apache-tomcat-9.0.62] ******************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Delete user tomcat] ********************************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Delete group tomcat] *******************************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Uninstall Java] ************************************************************************************************************

skipping: [ansible_dev_db] => (item={'package': 'java-1.8.0-openjdk'})

skipping: [ansible_dev_db]

RUNNING HANDLER [zaxos.tomcat-ansible-role : restart tomcat] *************************************************************************************************************

changed: [ansible_dev_db]

PLAY RECAP ***************************************************************************************************************************************************************

ansible_dev_db             : ok=28   changed=21   unreachable=0    failed=0    skipped=16   rescued=0    ignored=0



</sub>


## 5. Проверяем запущенный сервис  Tomcat

```

[root@localhost ~]# systemctl status tomcat.service

```

<sub>

tomcat.service - Apache Tomcat Web Application Container

Loaded: loaded (/etc/systemd/system/tomcat.service; enabled; preset: disabled)

Active: active (running) since Fri 2024-04-05 03:55:17 EDT; 10min ago

Process: 446543 ExecStart=/opt/tomcat/bin/startup.sh (code=exited, status=0/SUCCESS)

Main PID: 446550 (java)

Tasks: 28 (limit: 23026)

Memory: 150.6M

CPU: 5.097s

CGroup: /system.slice/tomcat.service
  
└─446550 /usr/lib/jvm/jre/bin/java -Djava.util.logging.config.file=/opt/tomcat/conf/logging.properties -Djava.util.logging.>

Apr 05 03:55:17 localhost.localdomain systemd[1]: Starting Apache Tomcat Web Application Container...

Apr 05 03:55:17 localhost.localdomain startup.sh[446543]: Tomcat started.

Apr 05 03:55:17 localhost.localdomain systemd[1]: Started Apache Tomcat Web Application Container.

</sub>


## 6. Добавили в файл Playbook playbook-tomcat.yml перезагрузку сервера и перезапуск роли zaxos.tomcat-ansible-role

```

- name: "Role install Tomcat"
  hosts: ansible_preprod
  become: true

  vars_files:
    - group_vars/tomcat_vars.yml

  pre_tasks:
    - name: "Task1: Check available version Tomcat"
      shell: dnf info tomcat | grep Version
      register: tomcat_info
      when: ansible_distribution == 'CentOS' and ansible_distribution_major_version == '9'

    - set_fact:
        tomcat_version: "{{ tomcat_info.stdout_lines[0].split(':')[1].strip() }}"
      when: ansible_distribution == 'CentOS' and ansible_distribution_major_version == '9' and tomcat_info is defined

  roles:
    - role: zaxos.tomcat-ansible-role
      vars:
        tomcat_version: "{{ tomcat_version }}"
        tomcat_permissions_production: True
        tomcat_users:
          - username: "tomcat"
            password: "{{ pass1 }}"
            roles: "tomcat,admin,manager,manager-gui"
          - username: "cef"
            password: "{{ pass2 }}"
            roles: "tomcat"
      when: ansible_distribution == 'CentOS' and ansible_distribution_major_version == '9' and tomcat_version is defined
      role_dependencies:
        - { role: zaxos.tomcat-ansible-role, task: "Task1: Check available version Tomcat" }

  tasks:

    - name: "Task2: Display reboot msg on screen"
      
      debug:
        msg: "The system will be rebooted in {{ item }} seconds"
      loop: "{{ range(10, 0, -1) }}"
      loop_control:
        pause: 1
        label: "Reboot Countdown"
      register: reboot_output
      changed_when: false
    
    - name: "Task2: Reboot CentOS Server"  
      reboot:
        pre_reboot_delay: 2
        post_reboot_delay: 3
      when: reboot_output is not skipped    
      
    - name: "Task3: Wait for server to come back online"
      wait_for:
        port: 22
        delay: 3
        timeout: 300
        state: started 
      vars:
        ansible_ssh_user: "root"
        ansible_ssh_private_key_file: ./id_rsa
        
    - name: "Task4: Send info msg after Reboot on terminal"
      shell: echo "Server CentOS with Tomcat has rebooted"
    
    - name: "Task5: Send info msg after Reboot on Ansible output"
      debug:
        msg: "Server CentOS with Tomcat has rebooted"
        
    - name: "Task6: Repeate Tomcat Installation Role"
      meta: flush_handlers

```	  
	  
## 7. Запустили Playbook playbook-tomcat.yml повторный вывод

```

[root@devops lesson18.ansible.roles]# ansible-playbook -i hosts -l ansible_preprod playbook-tomcat.yml

```

<sub>

PLAY [Role install Tomcat] ***********************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************

ok: [ansible_dev_db]

TASK [Task1: Check available version Tomcat] *****************************************************************************************************************************

changed: [ansible_dev_db]

TASK [set_fact] **********************************************************************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Install Java] **************************************************************************************************************************

ok: [ansible_dev_db] => (item={'package': 'java-1.8.0-openjdk'})

TASK [zaxos.tomcat-ansible-role : Check if tomcat is already installed] **************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Create group tomcat] *******************************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Create user tomcat] ********************************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Create temp directory] *****************************************************************************************************************

skipping: [ansible_dev_db] => (item=localhost)

skipping: [ansible_dev_db] => (item=ansible_dev_db)

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Download apache-tomcat-9.0.62.tar.gz] **************************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : apache-tomcat-9.0.62.tar.gz is transfered to the disconnected remote] ******************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Unarchive apache-tomcat-9.0.62.tar.gz at /opt] *****************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Clean up temporary files] **************************************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Setup server.xml] **********************************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set fact of user roles to be enabled] **************************************************************************************************

ok: [ansible_dev_db] => (item={'username': 'tomcat', 'password': 'tomcat', 'roles': 'tomcat,admin,manager,manager-gui'})

ok: [ansible_dev_db] => (item={'username': 'cef', 'password': 'cef', 'roles': 'tomcat'})

TASK [zaxos.tomcat-ansible-role : Setup tomcat-users.xml] ****************************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Create symlink /opt/apache-tomcat-9.0.62 to /opt/tomcat] *******************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Configure access to Manager app (from localhost only or from anywhere)] ****************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Configure access to Host Manager (from localhost only or from anywhere)] ***************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Configure setenv.sh] *******************************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set root directory owner/group for production installation] ****************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set recursively directories owner/group for production installation] *******************************************************************

ok: [ansible_dev_db] => (item=bin)

ok: [ansible_dev_db] => (item=conf)

ok: [ansible_dev_db] => (item=lib)

TASK [zaxos.tomcat-ansible-role : Set recursively directories owner/group for production installation] *******************************************************************

ok: [ansible_dev_db] => (item=temp)

ok: [ansible_dev_db] => (item=work)

ok: [ansible_dev_db] => (item=logs)

TASK [zaxos.tomcat-ansible-role : Set recursively webapps directory owner/group for production installation] *************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set directories permissions for production installation] *******************************************************************************

ok: [ansible_dev_db] => (item=['bin', '2750', '0640'])

ok: [ansible_dev_db] => (item=['conf', '2750', '0640'])

ok: [ansible_dev_db] => (item=['lib', '2750', '0640'])

ok: [ansible_dev_db] => (item=['logs', '0300', '0640'])

ok: [ansible_dev_db] => (item=['temp', '0750', '0640'])

ok: [ansible_dev_db] => (item=['work', '0750', '0640'])

ok: [ansible_dev_db] => (item=['webapps', '0750', '0640'])

TASK [zaxos.tomcat-ansible-role : Set files permissions for production installation] *************************************************************************************

ok: [ansible_dev_db] => (item=['bin', '2750', '0640'])

ok: [ansible_dev_db] => (item=['conf', '2750', '0640'])

ok: [ansible_dev_db] => (item=['lib', '2750', '0640'])

ok: [ansible_dev_db] => (item=['logs', '0300', '0640'])

ok: [ansible_dev_db] => (item=['temp', '0750', '0640'])

ok: [ansible_dev_db] => (item=['work', '0750', '0640'])

ok: [ansible_dev_db] => (item=['webapps', '0750', '0640'])

TASK [zaxos.tomcat-ansible-role : Set bin/*.sh permissions to allow execution] *******************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set owner and group for non-production installation] ***********************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set directories permissions for non-production installation] ***************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Set files permissions for non-production installation] *********************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Configure service file tomcat.service] *************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Remove systemd service file from old path (before role update)] ************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : Enable tomcat service on startup] ******************************************************************************************************

ok: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Check if tomcat service is installed] **************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Stop tomcat service if running] ********************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Remove service file tomcat.service] ****************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Perform systemctl daemon-reload] *******************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Check if tomcat is already uninstalled] ************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Remove symlink /opt/tomcat] ************************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Create backup archive before deletion at /opt/tomcat-backup-XXX.tgz] *******************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Remove /opt/apache-tomcat-9.0.62] ******************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Delete user tomcat] ********************************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Delete group tomcat] *******************************************************************************************************

skipping: [ansible_dev_db]

TASK [zaxos.tomcat-ansible-role : (uninstall) Uninstall Java] ************************************************************************************************************

skipping: [ansible_dev_db] => (item={'package': 'java-1.8.0-openjdk'})

skipping: [ansible_dev_db]

TASK [Task2: Display reboot msg on screen] *******************************************************************************************************************************

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 10 seconds"
}

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 9 seconds"
}

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 8 seconds"
}

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 7 seconds"
}

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 6 seconds"
}

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 5 seconds"
}

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 4 seconds"
}

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 3 seconds"
}

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 2 seconds"
}

ok: [ansible_dev_db] => (item=Reboot Countdown) => {
    "msg": "The system will be rebooted in 1 seconds"
}

TASK [Task2: Reboot CentOS Server] ***************************************************************************************************************************************

changed: [ansible_dev_db]

TASK [Task3: Wait for server to come back online] ************************************************************************************************************************

ok: [ansible_dev_db]

TASK [Task4: Send info msg after Reboot on terminal] *********************************************************************************************************************

changed: [ansible_dev_db]

TASK [Task5: Send info msg after Reboot on Ansible output] ***************************************************************************************************************

ok: [ansible_dev_db] => {
    "msg": "Server CentOS with Tomcat has rebooted"
}

TASK [Task6: Repeate Tomcat Installation Role] ***************************************************************************************************************************

PLAY RECAP ***************************************************************************************************************************************************************

ansible_dev_db             : ok=28   changed=3    unreachable=0    failed=0    skipped=20   rescued=0    ignored=0

</sub>


## 8. Cоздали файл main.tf для создания EKS кластера

```

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "eks_cluster_role_skruhlik" {
  name = "eks_cluster_role_skruhlik"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_eks_cluster" "skruhlik_eks_cluster" {
  name     = "skruhlik_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role_skruhlik.arn

  vpc_config {
    subnet_ids = ["subnet-07c2f05d5f20031b7", "subnet-054c1db783b328393"] 
    security_group_ids = ["sg-02bed5840a3b6210f"] 
  }

  tags = {
    Environment = "skruhlik_dev"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment_skruhlik" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role_skruhlik.name
}

resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment_skruhlik" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster_role_skruhlik.name
}

resource "aws_eks_node_group" "skruhlik_node_group" {
  cluster_name    = aws_eks_cluster.skruhlik_eks_cluster.name
  node_group_name = "skruhlik_node_group"

  node_role_arn    = aws_iam_role.eks_node_role_skruhlik.arn

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  subnet_ids = ["subnet-07c2f05d5f20031b7" , "subnet-054c1db783b328393"] 
  instance_types = ["t3.small"]

  tags = {
    Environment = "skruhlik_dev"
  }
}

resource "aws_iam_role" "eks_node_role_skruhlik" {
  name = "eks_node_role_skruhlik"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_node_instance_profile_attachment_skruhlik" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role_skruhlik.name
}

resource "aws_iam_instance_profile" "eks_node_instance_profile_skruhlik" {
  name = "eks_node_instance_profile_skruhlik"
  role = aws_iam_role.eks_node_role_skruhlik.name
}

```

## 8. Запустили terraform apply

```


```

## 9. Запустили terraform destroy

```


```