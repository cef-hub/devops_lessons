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
