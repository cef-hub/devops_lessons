#!/bin/bash
echo "Enter the username that will be created in the system: "
read username

if id "$username" >/dev/null 2>&1; then
  echo "Your User $username already exists"
else
  useradd -d "/home/$username" "$username" && {
    echo "Your User $username created successfully and add to wheel"
    usermod -aG wheel "$username"
    cat /etc/group | grep wheel
  }
fi
