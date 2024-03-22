[root@devops .ssh]# hostnamectl
 Static hostname: devops.nces.by
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 58afa63c2ff44b859ef6bed1f29367fa
         Boot ID: 8f03efa2ebc34abdbf6d2df051889774
  Virtualization: vmware
Operating System: CentOS Stream 9
     CPE OS Name: cpe:/o:centos:centos:9
          Kernel: Linux 5.14.0-412.el9.x86_64
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00
[root@devops lesson7.jenkins]# cd /var/lib/jenkins/
[root@devops lesson7.jenkins]# mkdir -p .ssh
[root@devops lesson7.jenkins]# chmod 700 .ssh
[root@devops lesson7.jenkins]# cd /var/lib/jenkins/.ssh
[root@devops lesson7.jenkins]# ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins_agent_key
[root@devops lesson7.jenkins]# chmod 600 .ssh/*
[root@devops .ssh]# ls -lah
total 24K
drwx------  2 jenkins jenkins  120 Feb 28 17:04 .
drwxr-xr-x 17 jenkins jenkins 4.0K Feb 29 13:54 ..
-rw-------  1 jenkins jenkins  411 Feb 28 17:04 authorized_keys
-rw-------  1 jenkins jenkins 1.8K Feb 28 17:04 id_rsa_132
-rw-------  1 jenkins jenkins 3.4K Feb 28 14:10 jenkins_agent_key
-rw-------  1 jenkins jenkins  748 Feb 28 14:10 jenkins_agent_key.pub
-rw-------  1 jenkins jenkins 1.8K Feb 29 11:36 known_hosts

[root@devops .ssh]# cat jenkins_agent_key.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuguF2l1hxEtr0w21wgJ2+6v7lBDUBWOJIZzIAU+uYHfn1ZOk+Xl+ftPtmDIt4fh5HoVzxdOxHnGz6pSEh3+mLx2zg7W1pG/4vGWqtaSfI+6pFw4hMQh/b0gm62Szrr5v9vgH1JV8mfxVPQsL8ttaOC7gGoQwwiow8v3LfAQWCloh6UHm2DuvkCP8NbTjD1L/U3yT2mbdAlQdRqB5NnV23WpADcop9EHvIcHUiqWjY6B+1Jwaldejmy5ywRP6FJ/AFBrvGwIdp76bDe/ThjHyxq3x2EltqDYhLUxsX7/Zt17gNV4oXni2Glf+5Yk89HJm8a4GZkDaHo18Ih/GGxnM4c7K4/2HKSLUouu2hXE1hKvB5UJF48/OGAl6rGkoumiiBjIPinmrmYr18F2RwZPvAJHkAx9spTgiHDRXnrl4KW342Cg+Ae4u11Fczit24c68qXGe9YPFc3LhBrnQqLARbzHrfvMo68dfzOogvcEwdzEUIZtz8FfUe7FEf6NCSPORuHbgYYHz1d4pOyDV+7nLA5LU4QdO3he/i7SqmK1+0eoR867XotVGnuD1QsXCsP6wXoD76DCdSreMWXXR95N2fYtCdgHxHifcifoLxJg72iLAHCpzZPT6/ksGLq2UjFt4AdwNBorkkWiAsbvRnJXqvppw9WVNKXY4aZuKCHQvQ9Q== jenkins@devops.nces.by

[root@jenkins-slave ELK on slave jenkins]# hostnamectl
 Static hostname: jenkins-slave.nces.by
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 58afa63c2ff44b859ef6bed1f29367fa
         Boot ID: 7993b9c5c6a545ca94d8191fd260f4d2
  Virtualization: vmware
Operating System: CentOS Stream 9
     CPE OS Name: cpe:/o:centos:centos:9
          Kernel: Linux 5.14.0-419.el9.x86_64
    Architecture: x86-64
 Hardware Vendor: VMware, Inc.
  Hardware Model: VMware Virtual Platform
Firmware Version: 6.00

[root@jenkins-slave ELK on slave jenkins]# echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuguF2l1hxEtr0w21wgJ2+6v7lBDUBWOJIZzIAU+uYHfn1ZOk+Xl+ftPtmDIt4fh5HoVzxdOxHnGz6pSEh3+mLx2zg7W1pG/4vGWqtaSfI+6pFw4hMQh/b0gm62Szrr5v9vgH1JV8mfxVPQsL8ttaOC7gGoQwwiow8v3LfAQWCloh6UHm2DuvkCP8NbTjD1L/U3yT2mbdAlQdRqB5NnV23WpADcop9EHvIcHUiqWjY6B+1Jwaldejmy5ywRP6FJ/AFBrvGwIdp76bDe/ThjHyxq3x2EltqDYhLUxsX7/Zt17gNV4oXni2Glf+5Yk89HJm8a4GZkDaHo18Ih/GGxnM4c7K4/2HKSLUouu2hXE1hKvB5UJF48/OGAl6rGkoumiiBjIPinmrmYr18F2RwZPvAJHkAx9spTgiHDRXnrl4KW342Cg+Ae4u11Fczit24c68qXGe9YPFc3LhBrnQqLARbzHrfvMo68dfzOogvcEwdzEUIZtz8FfUe7FEf6NCSPORuHbgYYHz1d4pOyDV+7nLA5LU4QdO3he/i7SqmK1+0eoR867XotVGnuD1QsXCsP6wXoD76DCdSreMWXXR95N2fYtCdgHxHifcifoLxJg72iLAHCpzZPT6/ksGLq2UjFt4AdwNBorkkWiAsbvRnJXqvppw9WVNKXY4aZuKCHQvQ9Q== jenkins@devops.nces.by' >> /var/lib/jenkins/.ssh/sshauthorized_keys

[root@jenkins-slave ELK on slave jenkins]# touch known_hosts

# UI Jenkins master http://172.16.0.131:8080/ add creds key and add node Agent to second node: jenkins-slave

Warning: no key algorithms provided; JENKINS-42959 disabled
SSHLauncher{host='172.16.0.132', port=22, credentialsId='0134e3e1-b6aa-4bbf-8d6e-7b9ec8d6127f', jvmOptions='', javaPath='', prefixStartSlaveCmd='', suffixStartSlaveCmd='', launchTimeoutSeconds=60, maxNumRetries=10, retryWaitTime=15, sshHostKeyVerificationStrategy=hudson.plugins.sshslaves.verifiers.KnownHostsFileKeyVerificationStrategy, tcpNoDelay=true, trackCredentials=true}
[02/28/24 14:21:05] [SSH] Opening SSH connection to 172.16.0.132:22.
Searching for 172.16.0.132 in /var/lib/jenkins/.ssh/known_hosts
Searching for 172.16.0.132:22 in /var/lib/jenkins/.ssh/known_hosts
[02/28/24 14:21:05] [SSH] SSH host key matches key in Known Hosts file. Connection will be allowed.
[02/28/24 14:21:05] [SSH] Authentication successful.
[02/28/24 14:21:05] [SSH] The remote user's environment is:
BASH=/usr/bin/bash
BASHOPTS=checkwinsize:cmdhist:complete_fullquote:extquote:force_fignore:globasciiranges:hostcomplete:interactive_comments:progcomp:promptvars:sourcepath
BASH_ALIASES=()
BASH_ARGC=([0]="0")
BASH_ARGV=()
BASH_CMDS=()
BASH_EXECUTION_STRING=set
BASH_LINENO=()
BASH_SOURCE=()
BASH_VERSINFO=([0]="5" [1]="1" [2]="8" [3]="1" [4]="release" [5]="x86_64-redhat-linux-gnu")
BASH_VERSION='5.1.8(1)-release'
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/972/bus
DIRSTACK=()
EUID=972
GROUPS=()
HOME=/var/lib/jenkins
HOSTNAME=jenkins-slave.nces.by
HOSTTYPE=x86_64
IFS=$' \t\n'
LOGNAME=jenkins
MACHTYPE=x86_64-redhat-linux-gnu
MOTD_SHOWN=pam
OPTERR=1
OPTIND=1
OSTYPE=linux-gnu
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
PPID=888595
PS4='+ '
PWD=/var/lib/jenkins
SHELL=/bin/bash
SHELLOPTS=braceexpand:hashall:interactive-comments
SHLVL=1
SSH_CLIENT='172.16.0.131 37272 22'
SSH_CONNECTION='172.16.0.131 37272 172.16.0.132 22'
TERM=dumb
UID=972
USER=jenkins
XDG_RUNTIME_DIR=/run/user/972
XDG_SESSION_CLASS=user
XDG_SESSION_ID=48
XDG_SESSION_TYPE=tty
_=bash
Checking Java version in the PATH
openjdk version "17.0.6" 2023-01-17 LTS
OpenJDK Runtime Environment (Red_Hat-17.0.6.0.10-3.el9) (build 17.0.6+10-LTS)
OpenJDK 64-Bit Server VM (Red_Hat-17.0.6.0.10-3.el9) (build 17.0.6+10-LTS, mixed mode, sharing)
[02/28/24 14:21:05] [SSH] Checking java version of /var/lib/jenkins/slave-job/jdk/bin/java
Couldn't figure out the Java version of /var/lib/jenkins/slave-job/jdk/bin/java
bash: line 1: /var/lib/jenkins/slave-job/jdk/bin/java: No such file or directory

[02/28/24 14:21:05] [SSH] Checking java version of java
[02/28/24 14:21:05] [SSH] java -version returned 17.0.6.
[02/28/24 14:21:05] [SSH] Starting sftp client.
[02/28/24 14:21:05] [SSH] Copying latest remoting.jar...
[02/28/24 14:21:06] [SSH] Copied 1,369,595 bytes.
Expanded the channel window size to 4MB
[02/28/24 14:21:06] [SSH] Starting agent process: cd "/var/lib/jenkins/slave-job" && java  -jar remoting.jar -workDir /var/lib/jenkins/slave-job -jar-cache /var/lib/jenkins/slave-job/remoting/jarCache
Feb 28, 2024 2:21:06 PM org.jenkinsci.remoting.engine.WorkDirManager initializeWorkDir
INFO: Using /var/lib/jenkins/slave-job/remoting as a remoting work directory
Feb 28, 2024 2:21:06 PM org.jenkinsci.remoting.engine.WorkDirManager setupLogging
INFO: Both error and output logs will be printed to /var/lib/jenkins/slave-job/remoting
<===[JENKINS REMOTING CAPACITY]===>channel started
Remoting version: 3206.vb_15dcf73f6a_9
Launcher: SSHLauncher
Communication Protocol: Standard in/out
This is a Unix agent
Agent successfully connected and online

[root@devops lesson7.jenkins]# cat docker-compose.yml
version: '3'

services:
  # service1 lesson7 pipeline docker-compose Elasticsearch
  elasticsearch:
    image: docker.io/elasticsearch:8.12.2
    environment:
      - TZ=Europe/Minsk
    restart: always
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - ./elasticsearch/data:/usr/share/elasticsearch/data
    networks:
      - docker-compose

  # service2 lesson7 pipeline docker-compose Logstash
  logstash:
    image: docker.io/logstash:8.12.2
    depends_on:
      - elasticsearch
    environment:
      - TZ=Europe/Minsk
    restart: always
    ports:
      - "9600:9600"
      - "5044:5044"
    volumes:
      - ./logstash/data:/usr/share/logstash/data
    networks:
      - docker-compose

  # service3 lesson7 pipeline docker-compose Kibana
  kibana:
   image: docker.io/kibana:8.12.2
   depends_on:
      - elasticsearch
   environment:
      - TZ=Europe/Minsk
    restart: always
    ports:
      - "5601:5601"
    networks:
      - docker-compose

networks:
  docker-compose:
    driver: bridge

volumes:
  elasticsearch:
  logstash:

# pipeline on master jenkins. It was not possible for me to transfer the docker file to the slave node using jenkins.
# simple ssh scp copy to slave jenkins node workspace "/var/lib/jenkins/slave-job/workspace/ELK on slave jenkins"

pipeline {
    agent {
        label 'jenkins-slave'
            }
    stages {
        stage('On Slave. Install ELK') {
            steps {
                script {
                    sh 'docker-compose --project-name net -f "/var/lib/jenkins/slave-job/workspace/ELK on slave jenkins/docker-compose.yml" up -d'
                }
            }
        }
    }
}


# Web UI console log on master jenkins

[Pipeline] Start of Pipeline
[Pipeline] node
Running on jenkins-slave in /var/lib/jenkins/slave-job/workspace/ELK on slave jenkins
[Pipeline] {
[Pipeline] stage
[Pipeline] { (On Slave. Install ELK)
[Pipeline] script
[Pipeline] {
[Pipeline] sh
+ docker-compose --project-name net -f '/var/lib/jenkins/slave-job/workspace/ELK on slave jenkins/docker-compose.yml' up -d
Container net-elasticsearch-1  Creating
Container net-elasticsearch-1  Created
Container net-logstash-1  Creating
Container net-kibana-1  Creating
Container net-kibana-1  Created
Container net-logstash-1  Created
Container net-elasticsearch-1  Starting
Container net-elasticsearch-1  Started
Container net-kibana-1  Starting
Container net-logstash-1  Starting
Container net-kibana-1  Started
Container net-logstash-1  Started
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS


[root@jenkins-slave ELK on slave jenkins]# docker ps -a
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                                                                                  NAMES
67b93595ed88   kibana:8.12.2          "/bin/tini -- /usr/l…"   23 seconds ago   Up 21 seconds   0.0.0.0:5601->5601/tcp, :::5601->5601/tcp                                              net-kibana-1
95cd0c19728b   logstash:8.12.2        "/usr/local/bin/dock…"   23 seconds ago   Up 21 seconds   0.0.0.0:5044->5044/tcp, :::5044->5044/tcp, 0.0.0.0:9600->9600/tcp, :::9600->9600/tcp   net-logstash-1
609984c8d5e1   elasticsearch:8.12.2   "/bin/tini -- /usr/l…"   23 seconds ago   Up 22 seconds   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 0.0.0.0:9300->9300/tcp, :::9300->9300/tcp   net-elasticsearch-1

