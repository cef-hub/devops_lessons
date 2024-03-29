## 1.[root@devops lesson16.ansible]# ansible-playbook -i hosts -l playbook-file-copy-del.yml

```
- name: "PlaybookName: Copy file and delete them"
  hosts: ansible_preprod
  become: yes
  vars:
    myfile: ansible.cfg

  tasks:

  - name: "Task1: Creates directory"
    ansible.builtin.file:
      path: /root/devops/lesson16.ansible/creade_directory/
      state: directory

  - name: "Task2: copy file"
    ansible.builtin.copy:
      src: "/root/devops/lesson16.ansible/{{ myfile }}"
      dest: /root/devops/lesson16.ansible/creade_directory/
      owner: root
      group: root
      mode: 0600

  - name: "Task3: delete file"
    ansible.builtin.file:
      path: "/root/devops/lesson16.ansible/creade_directory/{{ myfile }}"
      state: absent

```

<sub>
PLAY [PlaybookName: Copy file and delete them] ***********************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************
ok: [ansible_dev_db]

TASK [Task1: Creates directory] **************************************************************************************************
ok: [ansible_dev_db]

TASK [Task2: copy file] **********************************************************************************************************
changed: [ansible_dev_db]

TASK [Task3: delete file] ********************************************************************************************************
changed: [ansible_dev_db]

PLAY RECAP ***********************************************************************************************************************
ansible_dev_db             : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
</sub>

## 2.[root@devops lesson16.ansible]# ansible-playbook -i hosts -l ansible_preprod playbook-user-create.yml

```

- name: "Playbook_name: Create user with home directory"
  hosts: ansible_preprod
  become: yes
  vars:
    username: lesson16

  tasks:
  - name: "Task1: Ping the ansible_dev environment"
    ping:

  - name: "Task2: create group {{ username }}"
    ansible.builtin.group:
      name: "{{ username }}"
      state: present

  - name: "Task3: Create user with user group home directory and passwd"
    ansible.builtin.user:
      name: "{{ username }}"
      shell: /bin/bash
      home: "/home/{{ username }}"
      groups: "{{ username }}"
      password: "{{ lookup('file', '/root/devops/lesson16.ansible/passwords.yml') | from_yaml | json_query('users[?name==`lesson16`].password') | first }}"
      append: yes

```

PLAY [Playbook_name: Create user with home directory] ****************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************
ok: [ansible_dev_db]

TASK [Task1: Ping the ansible_dev environment] ***********************************************************************************
ok: [ansible_dev_db]

TASK [Task2: create group lesson16] **********************************************************************************************

ok: [ansible_dev_db]

TASK [Task3: Create user with user group home directory and passwd] **************************************************************
ok: [ansible_dev_db]

PLAY RECAP ***********************************************************************************************************************
ansible_dev_db             : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

## 3.[root@devops lesson16.ansible]#  ansible-playbook -i hosts -l ansible_preprod playbook-docker.yml

```
- name: "Playbook_name: Docker install"
  hosts: ansible_preprod
  become: yes
  vars:
    username: lesson16

  tasks:
  - name: "Task1: Ping the ansible_dev environment"
    ping:

  - name: "Task2: Add Docker repo"
    yum_repository:
      name: docker
      description: repo for docker
      baseurl: https://download.docker.com/linux/centos/9/x86_64/stable/
      gpgcheck: no

  - name: "Task3: Installing docker"
    command:
      cmd: yum install docker-ce --nobest -y


  - name: "Task4: Starting and enabling docker service"
    service:
      name: docker
      state: started
      enabled: yes

  - name: "Task5: Install python3.12"
    package:
      name: python3
      state: present

  - name: "Task6: Install pip3"
    yum:
      name: python3-pip
      state: present

  - name: "Task7: Add conf pip for docker"
    pip:
      name: docker-py
      executable: pip3

  - name: "Task8: Add the user {{ username }} to a primary group dcoker"
    ansible.builtin.user:
      name: "{{ username }}"
      group: docker

```

PLAY [Playbook_name: Docker install] *********************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************
ok: [ansible_dev_db]

TASK [Task1: Ping the ansible_dev environment] ***********************************************************************************
ok: [ansible_dev_db]

TASK [Task2: Add Docker repo] ****************************************************************************************************
ok: [ansible_dev_db]

TASK [Task3: Installing docker] **************************************************************************************************
changed: [ansible_dev_db]

TASK [Task4: Starting and enabling docker service] *******************************************************************************
ok: [ansible_dev_db]

TASK [Task5: Install python3.12] *************************************************************************************************
ok: [ansible_dev_db]

TASK [Task6: Install pip3] *******************************************************************************************************
ok: [ansible_dev_db]

TASK [Task7: Add conf pip for docker] ********************************************************************************************
ok: [ansible_dev_db]

TASK [Task8: Add the user lesson16 to a primary group dcoker] ********************************************************************
ok: [ansible_dev_db]

PLAY RECAP ***********************************************************************************************************************
ansible_dev_db             : ok=9    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
