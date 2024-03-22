#!/bin/bash
echo "I am a some service and I am working!"
rm -rf file_created.txt
ls /root/devops/lesson2/3
`sh -c 'cat << EOF >> /root/devops/lesson2/3/file_created.txt
service create the file
EOF'`
ls /root/devops/lesson2/3
cat /root/devops/lesson2/3/file_created.txt
