#!/bin/bash
#TASK 1
echo "Created 1st test filename: 'file_with_error.txt' with error in current directory"
> file_with_error.txt
`sh -c 'cat << EOF >> file_with_error.txt
1st str
some text
here error str
N str
EOF'`
echo "Created 2d test filename: 'file_with_error1.txt' with error in current directory"
> file_with_error1.txt
`sh -c 'cat << EOF >> file_with_error1.txt
1st str
some text
here also is error str
N str
EOF'`
echo "Created 1st test filename: 'file_with_no_error.txt' without error in current directory"
> file_with_no_error.txt
`sh -c 'cat << EOF >> file_with_no_error.txt
1st str
some text
here no_error str
N str
EOF'`
echo "Enter pls 'word_mask' for files deletion: "
read word_mask
#echo "You enter: $word_mask"
echo "Enter the 'path' for files deletion: "
read del_path
cd del_path
echo "ls:" && ls
#echo "You select path: $del_path"
grep -wrsl --exclude="*.sh" $word_mask $del_path | xargs rm
echo "Delete complite"
echo 'ls:' && ls

Result:
bash ./word_del.sh
Created 1st test filename: 'file_with_error.txt' with error in current directory
Created 2d test filename: 'file_with_error1.txt' with error in current directory
Created 1st test filename: 'file_with_no_error.txt' without error in current directory
Enter pls 'word_mask' for files deletion:
error
Enter the 'path' for files deletion:
/root/devops/lesson2/1
ls:
file_with_error1.txt  file_with_error.txt  file_with_no_error.txt  word_del.sh
Delete complite
ls:
file_with_no_error.txt  word_del.sh

#TASK2

#!/bin/bash
echo "Enter the username that will be created in the system: "
read username

if id "$username" >/dev/null 2>&1; then
  echo "Your User $username already exists"
else
  useradd -d "/home/$username" "$username" && {
    echo "Your User $username created successfully"
    usermod -aG wheel "$username"
    cat /etc/group | grep wheel
  }
fi

Result:

bash ./create_user.sh
Enter the username that will be created in the system:
cef
Your User cef already exists

bash ./create_user.sh
Enter the username that will be created in the system:
Joy33
Your User Joy33 created successfully and add to wheel
wheel:x:10:cef,Joy33

TASK3:

touch echo.sh && chmod +x echo.sh
[root@localhost 3]# cat echo.sh
#!/bin/bash
echo "I am a some service and I am working!"
rm -rf file_created.txt
ls /root/devops/lesson2/3
`sh -c 'cat << EOF >> /root/devops/lesson2/3/file_created.txt
service create the file
EOF'`
ls /root/devops/lesson2/3
cat /root/devops/lesson2/3/file_created.txt

touch lesson2.service && chmod +x lesson2.service
[root@localhost 3]# cat lesson2.service
[Unit]
Description=lesson2 empty echo

[Service]
ExecStart=/root/devops/lesson2/3/echo.sh

[Install]
WantedBy=multi-user.target

[root@localhost 3]# cp lesson2.service /etc/systemd/system/
[root@localhost 3]# systemctl daemon-reload
[root@localhost 3]# systemctl start lesson2.service
[root@localhost 3]# journalctl -u lesson2.service

Feb 12 16:46:32 devops systemd[1]: Started lesson2 empty echo.
Feb 12 16:46:32 devops echo.sh[384049]: I am a some service and I am working!
Feb 12 16:46:32 devops echo.sh[384051]: echo.sh
Feb 12 16:46:32 devops echo.sh[384051]: file_created.txt
Feb 12 16:46:32 devops echo.sh[384051]: lesson2.service
Feb 12 16:46:32 devops echo.sh[384054]: echo.sh
Feb 12 16:46:32 devops echo.sh[384054]: file_created.txt
Feb 12 16:46:32 devops echo.sh[384054]: lesson2.service
Feb 12 16:46:32 devops echo.sh[384055]: service create the file
Feb 12 16:46:32 devops echo.sh[384055]: service create the file
Feb 12 16:46:32 devops echo.sh[384055]: service create the file
Feb 12 16:46:32 devops echo.sh[384055]: service create the file
Feb 12 16:46:32 devops echo.sh[384055]: service create the file
Feb 12 16:46:32 devops systemd[1]: lesson2.service: Deactivated successfully.
