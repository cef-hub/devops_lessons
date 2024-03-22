# run windows agent
D:\Jenkins>curl.exe -sO http://172.16.0.131:8080/jnlpJars/agent.jar
D:\Jenkins>java -jar agent.jar -url http://172.16.0.131:8080/ -secret b29f27536eda5ae8c56d828c5d0e323a597bd851603792a31aa5e0260d92092b -name "jenkins-windows" -workDir "D:\Jenkins\home"
мар. 04, 2024 1:04:31 PM hudson.remoting.Launcher$CuiListener status
INFO: Locating server among [http://172.16.0.131:8080/]
мар. 04, 2024 1:04:31 PM org.jenkinsci.remoting.engine.JnlpAgentEndpointResolver resolve
INFO: Remoting server accepts the following protocols: [JNLP4-connect, Ping]
мар. 04, 2024 1:04:31 PM hudson.remoting.Launcher$CuiListener status
INFO: Agent discovery successful
  Agent address: 172.16.0.131
  Agent port:    35229
  Identity:      0e:41:e0:94:5c:3d:87:c8:4e:f6:5b:c5:4c:89:9e:46
мар. 04, 2024 1:04:31 PM hudson.remoting.Launcher$CuiListener status
INFO: Handshaking
мар. 04, 2024 1:04:31 PM hudson.remoting.Launcher$CuiListener status
INFO: Connecting to 172.16.0.131:35229
мар. 04, 2024 1:04:31 PM hudson.remoting.Launcher$CuiListener status
INFO: Server reports protocol JNLP4-connect-proxy not supported, skipping
мар. 04, 2024 1:04:31 PM hudson.remoting.Launcher$CuiListener status
INFO: Trying protocol: JNLP4-connect
мар. 04, 2024 1:04:31 PM org.jenkinsci.remoting.protocol.impl.BIONetworkLayer$Reader run
INFO: Waiting for ProtocolStack to start.
мар. 04, 2024 1:04:31 PM hudson.remoting.Launcher$CuiListener status
INFO: Remote identity confirmed: 0e:41:e0:94:5c:3d:87:c8:4e:f6:5b:c5:4c:89:9e:46
мар. 04, 2024 1:04:31 PM hudson.remoting.Launcher$CuiListener status
INFO: Connected

Log Status Jenkins:
Inbound agent connected from KPIT08.main.nces.by/172.24.173.28:24025
Remoting version: 3206.vb_15dcf73f6a_9
Launcher: JNLPLauncher
Communication Protocol: JNLP4-connect
This is a Windows agent
Updating existing installations for jenkins-windows
Agent successfully connected and online

# bat file on windows run simple netstat -abn and save to file

@echo off

for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set "now=%%a"
set "formattedDateTime=%now:~0,14%"
echo %formattedDateTime%

netstat -abn > "D:\Jenkins\home\netstat-%formattedDateTime%.txt"

# pipeline run bat on windows

pipeline {
    agent {
        label 'jenkins-windows'
    }
    
    stages {
        stage('Run Batch File') {
            steps {
                script {
                    def batchFilePath = 'D:\\Jenkins\\home\\netstat_now.bat'
                    bat script: "call ${batchFilePath}", label: 'jenkins-windows'
                }
            }
        }
    }
}

# console output

Started by user cef
[Pipeline] Start of Pipeline
[Pipeline] node
Running on jenkins-windows in D:\Jenkins\home\workspace\run_job_windows
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Run Batch File)
[Pipeline] script
[Pipeline] {
[Pipeline] bat (windows-agent)

D:\Jenkins\home\workspace\run_job_windows>call D:\Jenkins\home\netstat_now.bat 
20240304143157
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS

# files in D:\Jenkins\home

D:\Jenkins\home>dir
 Том в устройстве D имеет метку Новый том
 Серийный номер тома: CE78-0125

 Содержимое папки D:\Jenkins\home

04.03.2024  14:38    <DIR>          .
04.03.2024  14:38    <DIR>          ..
04.03.2024  14:31            15 973 netstat-20240304143157.txt
04.03.2024  14:32               230 netstat_now.bat
04.03.2024  12:33    <DIR>          remoting
04.03.2024  13:04                 0 slave_setup.ini
04.03.2024  14:30    <DIR>          workspace
               3 файлов         16 203 байт
               4 папок  195 224 846 336 байт свободно
