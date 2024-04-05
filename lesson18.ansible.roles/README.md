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

## 3. Создали файл Playbook playbook-tomcat.ymlcat

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

## 4. Запустили Playbook playbook-tomcat.yml

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

● tomcat.service - Apache Tomcat Web Application Container
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