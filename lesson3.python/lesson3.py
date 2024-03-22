#TASK1
import string

my_str = input('Enter random string for counting letter in upper register: ')
num_uper = 0
for item in my_str:
    if item.isupper() == True:
        num_uper += 1
print(f'In your string number letter in upper register: {num_uper}')

#TASK2

import subprocess
import os

hostname = 'google.com'       # that's OK
hostname = 'ubuntu.alex'      #no host available
hostname = 'google525364.com' #no dns records
if os.name == 'posix':
    command = 'ping -c 1 ' + hostname
    enc = "'UTF-8'"
if os.name == 'nt':
    command = 'ping -n 1 -a ' + hostname
    enc = "'cp866'"
else:
    command = 'ping -c 1 ' + hostname
    enc = "'UTF-8'"

print(command)
proc = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True, encoding=f"{enc}")
out, err = proc.communicate()
#print(f'out: {out}')
#print(f'err: {err}')
if out.find('(0% потерь)') != -1 or out.find(', 0% packet loss') != -1:
   print(f'success {hostname} available')
if (out.find('(100% потерь)') != -1 or out.find('Проверьте имя узла и повторите попытку.') != -1) or (err.find('Name or service not known') != -1 or out.find('100% packet loss') != -1):
   print(f"{hostname} doesn't work")

#TASK3

from datetime import datetime

curr_datetime = datetime.now()
user_datetime = curr_datetime.strftime("%d.%m.%y %H:%M:%S")
print(f'Текущая дата и время в формате UTC+3: {user_datetime}')