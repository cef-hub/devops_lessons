# create Dockerfile
FROM alpine:latest

ADD google.crt /usr/local/share/ca-certificates/
ADD github.crt /usr/local/share/ca-certificates/
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.18/main ca-certificates
RUN update-ca-certificates
RUN apk update && apk add git gcc python3-dev linux-headers libffi-dev libc-dev musl-dev python3 py3-pip python3-dev

ENV PYTHONUNBUFFERED=1
ENV TZ=Europe/Minsk
RUN ln -sf python3 /usr/bin/python
RUN python3 -m venv /root/python/.venv
ENV PATH="/root/python/.venv/bin:$PATH"
RUN mkdir -p /home/AI/comp
WORKDIR /home/AI/comp
RUN pip install --upgrade pip setuptools wheel cython
RUN git clone https://github.com/pypa/setuptools.git /home/AI/comp && cd /home/AI/comp && python3 -m pip install -e /home/AI/comp
RUN pip3 install psutil

COPY requirements.txt /home/AI/comp
COPY Ussage.py /home/AI/comp

RUN pip3 install -r /home/AI/comp/requirements.txt

ENV PATH=/root/.local:$PATH

CMD [ "python3", "-u", "/home/AI/comp/Ussage.py" ]

EXPOSE 5555

# create requirements.txt
Jinja2>=3.0
click>=8.0
itsdangerous>=2.0
Werkzeug>=2.2.2
colorama
MarkupSafe>=2.0
flask>=2.2.2
mock==5.0.1
projects==1.0.9
urwid==2.1.2

# create Ussage.py with python scripts
 
import json
from flask import Flask, jsonify
import psutil
import platform
from flask import send_from_directory

app = Flask(__name__)

@app.route('/disk_io_counters', methods=['GET'])
def get_disk_io_counters():
    io_dict = psutil.disk_io_counters(perdisk=True)
    io_dict_end = {}
    for key, value in io_dict.items():
        io_list = (key, value)
        current_item = str(io_list[1])
        current_physical_drive = str(io_list[0])
        current_item = current_item.replace('sdiskio(', '').replace(')', '').replace('=',' : ').replace('read_merged_count', '"read_merged_count"').replace('write_merged_count', '"write_merged_count"').replace('busy_time', '"busy_time"')
        current_item = current_item.replace('read_count', '"read_count"').replace('write_count', '"write_count"').replace('read_bytes', '"read_bytes"').replace('write_bytes', '"write_bytes"').replace('read_time', '"read_time"').replace('write_time', '"write_time"')
        current_item = '{' + f'{current_item}' + '}'
        io_dict_end[f'{key}'] = json.loads(current_item)
    return jsonify(io_dict_end)

@app.route('/connections', methods=['GET'])
def get_connections():
    pid_list = []
    connections_dict = {}
    connections_list = []
    for pid in psutil.pids():
        try:
            connections_list = []
            process_name = psutil.Process(pid).name()
            pid_conncetions = psutil.Process(pid).connections()
            connections_dict[f'process: {process_name}({pid})'] = ''
            for item in pid_conncetions:
                connections_list.append(f'{item}')
            connections_dict[f'process: {process_name}({pid})'] = connections_list
        except psutil.NoSuchProcess:
            pass
        except RuntimeError:
            pass
    return jsonify({f'connection': connections_dict})

@app.route('/process', methods=['GET'])
def get_process():
    process_list = []
    iter = 0
    cur_process = ''
    mem_total = f'MEM Total: {psutil.virtual_memory().total / (1024 ** 3):.2f}G'
    for pid in psutil.pids():
        iter += 1
        try:
            test_list = []
            for i in range(10):
                p = psutil.Process(pid)
                p_cpu = p.cpu_percent(interval=0.1)
                test_list.append(p_cpu)
            average = round(float(sum(test_list)) / len(test_list) / psutil.cpu_count(), 2)
            process_name = psutil.Process(pid).name()
            process_mem = round(psutil.Process(pid).memory_percent(), 2)
            process_list.append(f'process: {process_name}({pid}), CPU usage: {average}%, MEM usage: {process_mem}%')
        except psutil.NoSuchProcess:
            pass
        except RuntimeError:
            pass
        # print(f'iter: {iter}')
        # if iter > 10:
        #     break
    return jsonify({'MEM Total: ': mem_total, 'All Process: ': process_list})

@app.route('/download/subscriber', methods=['GET', 'POST'])
def download():
    return send_from_directory(directory=r'D:\Download', path='nsi.json')

@app.route('/info', methods=['GET'])
def get_info_api():
    api_info = '''
    Запустив этот код, мы можем получить информацию о компьютере, IP адресе, свободном месте на диске, загрузке ЦПУ
и оперативной памяти, используя следующие запросы:

GET http://localhost:5555/computer_info
GET http://localhost:5555/ip_address
GET http://localhost:5555/disk_drive
GET http://localhost:5555/disk_io_counters
GET http://localhost:5555/cpu_usage
GET http://localhost:5555/cpu_count
GET http://localhost:5555/users
GET http://localhost:5555/process
GET http://localhost:5555/sensors_temperatures
GET http://localhost:5555/memory
GET http://localhost:5555/download/subscriber
    '''
    return api_info

@app.route('/computer_info', methods=['GET'])
def get_computer_info():
    OS = platform.platform()
    kind_os = platform.system()
    release = platform.release()
    version = platform.version()
    name_computer = platform.node()
    return jsonify({'computer_name': name_computer, 'computer_platform': kind_os, 'OS_release': release, 'OS_version:' : version})

@app.route('/users', methods=['GET'])
def get_users():
    user_list = psutil.users()
    user_dict = {}
    user_dict['Operating_System'] = platform.uname()
    for id, item in enumerate(user_list):
        cur_name = item.name
        cur_terminal = item.terminal
        cur_host = item.host
        cur_started = item.started
        cur_pid = item.pid
        user_dict[f'user{id + 1}'] = f'Name:{cur_name}, ' + f'Logging_time:{cur_started}, ' + f'Host:{cur_host}, ' + f'Terminal:{cur_terminal}, ' + f'Pid_process:{cur_pid}'
    return jsonify(user_dict)

@app.route('/ip_address', methods=['GET'])
def get_ip_address():
    end_ip_string = ''
    list_net = []
    net_if_addrs = psutil.net_if_addrs()
    for key in psutil.net_if_addrs().keys():
        list_net = [*psutil.net_if_addrs()]
    last_net = list_net[len(list_net) - 1]
    if platform.system() == 'Windows':
        template = "'ip_address_[name_net]': psutil.net_if_addrs()['[name_net]'][1].address, 'netmask_[name_net]': psutil.net_if_addrs()['[name_net]'][1].netmask"
    else:
        template = "'ip_address_[name_net]': psutil.net_if_addrs()['[name_net]'][0].address, 'netmask_[name_net]': psutil.net_if_addrs()['[name_net]'][0].netmask"
    for item in list_net:
        now_string = template.replace('[name_net]', f'{item}') + ','
        end_ip_string = end_ip_string + now_string
        if item == last_net:
            end_ip_string = end_ip_string[:-1]
    end_ip_string = '{' + end_ip_string + '}'
    return jsonify(eval(end_ip_string))

@app.route('/sensors_temperatures', methods=['GET'])
def sensors_temperatures():
    return psutil.sensors_temperatures(fahrenheit=False)

@app.route('/disk_drive', methods=['GET'])
def get_disk_drive():
    disks = psutil.disk_partitions()
    disks_device = []
    disks_map = []
    disk_info = []
    disks_mountpoint = []
    disks_usage = {}
    disks_usage_end = {}
    cur_disk = ''
    for item in disks:
        cur_disk = item.opts
        cur_mountpoint = item.mountpoint
        if cur_disk !='removable' and cur_disk !='cdrom':
            disks_mountpoint.append(f'{item}')
            disks_device.append(f'{item}')
            disks_usage[f'{cur_mountpoint}'] = f'{psutil.disk_usage(cur_mountpoint)}'
    index = 0
    for key, val in disks_usage.items():
        val = val[11:-1]
        disks_map.append(key)
        disk_info.append(val)
        disks_usage_end[key] = disk_info[index]
        index += 1
    return jsonify({'disks': disks_usage_end})

@app.route('/cpu_usage', methods=['GET'])
def get_cpu_usage():
    cpu_ussage = '''    ctx_switches: number of context switches (voluntary + involuntary) since boot.
    interrupts: number of interrupts since boot.
    soft_interrupts: number of software interrupts since boot. Always set to 0 on Windows and SunOS.
    syscalls: number of system calls since boot. Always set to 0 on Linux.'''
    cpu_ussage_list = []
    cpu_ussage_list = cpu_ussage.split('\n')
    cpu_freq = {}
    cpu_freq = psutil.cpu_freq()
    return jsonify({'cpu_usage %': psutil.cpu_percent(), 'ctx_switches': psutil.cpu_stats().ctx_switches,'interrupts': psutil.cpu_stats().interrupts,'soft_interrupts': psutil.cpu_stats().soft_interrupts,'syscalls': psutil.cpu_stats().syscalls, 'cpu_stats': cpu_ussage_list, 'cpu_frequency' : {'current': round(cpu_freq.current,2),'min': round(cpu_freq.min,2),'max': round(cpu_freq.max,2)}})

@app.route('/cpu_count', methods=['GET'])
def get_cpu_count():
    return jsonify({'cpu_count': psutil.cpu_count()})

@app.route('/memory', methods=['GET'])
def get_memory():
    mem = psutil.virtual_memory()
    mem_str = str(round(mem.available / 1024 / 1024, 2)) + 'MB'
    return jsonify({'memory_total MB': round(psutil.virtual_memory().total / 1024 /1024, 2), 'memory_percent_usage %': psutil.virtual_memory().percent, 'memory_used MB': round(psutil.virtual_memory().used / 1024 /1024, 2), 'memory_free MB': round(psutil.virtual_memory().free / 1024 /1024, 2)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5555)


"""
Запустив этот код, мы можем получить информацию о компьютере, IP адресе, свободном месте на диске, загрузке ЦПУ
и оперативной памяти, используя следующие запросы:

GET http://localhost:5555/computer_name
GET http://localhost:5555/ip_address
GET http://localhost:5555/disk_drive
GET http://localhost:5555/disk_io_counters
GET http://localhost:5555/cpu_usage
GET http://localhost:5555/cpu_count
GET http://localhost:5555/users
GET http://localhost:5555/process
GET http://localhost:5555/sensors_temperatures
GET http://localhost:5555/memory
GET http://localhost:5555/info
GET http://localhost:5555/download/subscriber

Мы можем использовать библиотеку requests для отправки запросов на этот REST сервис.

Например, мы можем получить информацию об имени компьютера, используя следующий код:

import requests
response = requests.get('http://localhost:5555/computer_name')
print(response.json()['computer_name'])
"""

# run build docker container

[root@devops lesson5.docker]# docker build -t ussage:latest .
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
STEP 1/22: FROM alpine:latest
STEP 2/22: ADD google.crt /usr/local/share/ca-certificates/
--> Using cache 6e621dfc76ab1ea3a1228e379f37ab53ff6d5f8307329e51ce8fc3e1c350518d
--> 6e621dfc76ab
STEP 3/22: ADD github.crt /usr/local/share/ca-certificates/
--> Using cache f4d699ef12dbfd4f9a4ba5fd06ee127c02158ddb18b97a4174cda7d455961ec1
--> f4d699ef12db
STEP 4/22: RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.18/main ca-certificates
--> Using cache 9c311dd5d0cc6779ea32e50da85da7daee96068a42258e80a53aea56bc09f805
--> 9c311dd5d0cc
STEP 5/22: RUN update-ca-certificates
--> Using cache 81f50c74ecd01e8f9a4cadf8e0fce36ea028b9334d06112bbd77d26fd65d414c
--> 81f50c74ecd0
STEP 6/22: RUN apk update && apk add git gcc python3-dev linux-headers libffi-dev libc-dev musl-dev python3 py3-pip python3-dev
--> Using cache 80e0acd2e31371d9b5c0d08037f8f5209a4dd5ba354b417025720ed5ea2626f9
--> 80e0acd2e313
STEP 7/22: ENV PYTHONUNBUFFERED=1
--> Using cache c94307065fb632fec6302561bf3ff99a8c84985a59bb38dd8639f77fe819644c
--> c94307065fb6
STEP 8/22: ENV TZ=Europe/Minsk
--> Using cache ecda0cf66c0ccff08ac3eb9c6f0a73e4090f5f82f49213bd80df119feca437c3
--> ecda0cf66c0c
STEP 9/22: RUN ln -sf python3 /usr/bin/python
--> 688028e59671
STEP 10/22: RUN python3 -m venv /root/python/.venv
--> 7a1659ab6a14
STEP 11/22: ENV PATH="/root/python/.venv/bin:$PATH"
--> 8bc20d836218
STEP 12/22: RUN mkdir -p /home/AI/comp
--> 526bdcaa520d
STEP 13/22: WORKDIR /home/AI/comp
--> cd21f01a86bc
STEP 14/22: RUN pip install --upgrade pip setuptools wheel cython
Requirement already satisfied: pip in /root/python/.venv/lib/python3.11/site-packages (24.0)
Requirement already satisfied: setuptools in /root/python/.venv/lib/python3.11/site-packages (65.5.0)
Collecting setuptools
  Downloading setuptools-69.1.0-py3-none-any.whl.metadata (6.1 kB)
Collecting wheel
  Downloading wheel-0.42.0-py3-none-any.whl.metadata (2.2 kB)
Collecting cython
  Downloading Cython-3.0.8-cp311-cp311-musllinux_1_1_x86_64.whl.metadata (3.2 kB)
Downloading setuptools-69.1.0-py3-none-any.whl (819 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 819.3/819.3 kB 1.2 MB/s eta 0:00:00
Downloading wheel-0.42.0-py3-none-any.whl (65 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 65.4/65.4 kB 2.6 MB/s eta 0:00:00
Downloading Cython-3.0.8-cp311-cp311-musllinux_1_1_x86_64.whl (3.6 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 3.6/3.6 MB 4.1 MB/s eta 0:00:00
Installing collected packages: wheel, setuptools, cython
  Attempting uninstall: setuptools
    Found existing installation: setuptools 65.5.0
    Uninstalling setuptools-65.5.0:
      Successfully uninstalled setuptools-65.5.0
Successfully installed cython-3.0.8 setuptools-69.1.0 wheel-0.42.0
--> 0cb12ae45ad2
STEP 15/22: RUN git clone https://github.com/pypa/setuptools.git /home/AI/comp && cd /home/AI/comp && python3 -m pip install -e /home/AI/comp
Cloning into '/home/AI/comp'...
Obtaining file:///home/AI/comp
  Checking if build backend supports build_editable: started
  Checking if build backend supports build_editable: finished with status 'done'
  Getting requirements to build editable: started
  Getting requirements to build editable: finished with status 'done'
  Installing backend dependencies: started
  Installing backend dependencies: finished with status 'done'
  Preparing editable metadata (pyproject.toml): started
  Preparing editable metadata (pyproject.toml): finished with status 'done'
Building wheels for collected packages: setuptools
  Building editable for setuptools (pyproject.toml): started
  Building editable for setuptools (pyproject.toml): finished with status 'done'
  Created wheel for setuptools: filename=setuptools-69.1.0.post20240220-0.editable-py3-none-any.whl size=6284 sha256=faaa797e635c1613f46f7e3c56209c76e76026f73b532aed193ef1418b3018a8
  Stored in directory: /tmp/pip-ephem-wheel-cache-kov97umw/wheels/38/21/05/cea628f98104a008e0b6fd1607f7494b9d0396344d1bd7fd1f
Successfully built setuptools
Installing collected packages: setuptools
  Attempting uninstall: setuptools
    Found existing installation: setuptools 69.1.0
    Uninstalling setuptools-69.1.0:
      Successfully uninstalled setuptools-69.1.0
Successfully installed setuptools-69.1.0.post20240220
--> 812a6cfcce86
STEP 16/22: RUN pip3 install psutil
Collecting psutil
  Downloading psutil-5.9.8.tar.gz (503 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 503.2/503.2 kB 4.8 MB/s eta 0:00:00
  Installing build dependencies: started
  Installing build dependencies: finished with status 'done'
  Getting requirements to build wheel: started
  Getting requirements to build wheel: finished with status 'done'
  Preparing metadata (pyproject.toml): started
  Preparing metadata (pyproject.toml): finished with status 'done'
Building wheels for collected packages: psutil
  Building wheel for psutil (pyproject.toml): started
  Building wheel for psutil (pyproject.toml): finished with status 'done'
  Created wheel for psutil: filename=psutil-5.9.8-cp311-abi3-linux_x86_64.whl size=280511 sha256=159b89a5a14a1af381d5099d6cdc7f1406e68612ccf5d2da0a8575d83c83ab0c
  Stored in directory: /root/.cache/pip/wheels/a6/1e/65/fb0ad37886dca3f25a0aa8e50f4903c5bdbde4bb8a9b1e27de
Successfully built psutil
Installing collected packages: psutil
Successfully installed psutil-5.9.8
--> 5854d906eed2
STEP 17/22: COPY requirements.txt /home/AI/comp
--> 4c7e4ab1ee90
STEP 18/22: COPY Ussage.py /home/AI/comp
--> bd663d323fc1
STEP 19/22: RUN pip3 install -r /home/AI/comp/requirements.txt
Collecting Jinja2>=3.0 (from -r /home/AI/comp/requirements.txt (line 1))
  Downloading Jinja2-3.1.3-py3-none-any.whl.metadata (3.3 kB)
Collecting click>=8.0 (from -r /home/AI/comp/requirements.txt (line 2))
  Downloading click-8.1.7-py3-none-any.whl.metadata (3.0 kB)
Collecting itsdangerous>=2.0 (from -r /home/AI/comp/requirements.txt (line 3))
  Downloading itsdangerous-2.1.2-py3-none-any.whl (15 kB)
Collecting Werkzeug>=2.2.2 (from -r /home/AI/comp/requirements.txt (line 4))
  Downloading werkzeug-3.0.1-py3-none-any.whl.metadata (4.1 kB)
Collecting colorama (from -r /home/AI/comp/requirements.txt (line 5))
  Downloading colorama-0.4.6-py2.py3-none-any.whl.metadata (17 kB)
Collecting MarkupSafe>=2.0 (from -r /home/AI/comp/requirements.txt (line 6))
  Downloading MarkupSafe-2.1.5-cp311-cp311-musllinux_1_1_x86_64.whl.metadata (3.0 kB)
Collecting flask>=2.2.2 (from -r /home/AI/comp/requirements.txt (line 7))
  Downloading flask-3.0.2-py3-none-any.whl.metadata (3.6 kB)
Collecting mock==5.0.1 (from -r /home/AI/comp/requirements.txt (line 8))
  Downloading mock-5.0.1-py3-none-any.whl.metadata (3.1 kB)
Collecting projects==1.0.9 (from -r /home/AI/comp/requirements.txt (line 9))
  Downloading projects-1.0.9.tar.gz (43 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 43.3/43.3 kB 1.4 MB/s eta 0:00:00
  Preparing metadata (setup.py): started
  Preparing metadata (setup.py): finished with status 'done'
Collecting urwid==2.1.2 (from -r /home/AI/comp/requirements.txt (line 10))
  Downloading urwid-2.1.2.tar.gz (634 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 634.6/634.6 kB 7.8 MB/s eta 0:00:00
  Preparing metadata (setup.py): started
  Preparing metadata (setup.py): finished with status 'done'
Collecting pyyaml (from projects==1.0.9->-r /home/AI/comp/requirements.txt (line 9))
  Downloading PyYAML-6.0.1-cp311-cp311-musllinux_1_1_x86_64.whl.metadata (2.1 kB)
Collecting termcolor (from projects==1.0.9->-r /home/AI/comp/requirements.txt (line 9))
  Downloading termcolor-2.4.0-py3-none-any.whl.metadata (6.1 kB)
Collecting blinker>=1.6.2 (from flask>=2.2.2->-r /home/AI/comp/requirements.txt (line 7))
  Downloading blinker-1.7.0-py3-none-any.whl.metadata (1.9 kB)
Downloading mock-5.0.1-py3-none-any.whl (30 kB)
Downloading Jinja2-3.1.3-py3-none-any.whl (133 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 133.2/133.2 kB 29.1 MB/s eta 0:00:00
Downloading click-8.1.7-py3-none-any.whl (97 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 97.9/97.9 kB 27.3 MB/s eta 0:00:00
Downloading werkzeug-3.0.1-py3-none-any.whl (226 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 226.7/226.7 kB 40.4 MB/s eta 0:00:00
Downloading colorama-0.4.6-py2.py3-none-any.whl (25 kB)
Downloading MarkupSafe-2.1.5-cp311-cp311-musllinux_1_1_x86_64.whl (33 kB)
Downloading flask-3.0.2-py3-none-any.whl (101 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 101.3/101.3 kB 25.7 MB/s eta 0:00:00
Downloading blinker-1.7.0-py3-none-any.whl (13 kB)
Downloading PyYAML-6.0.1-cp311-cp311-musllinux_1_1_x86_64.whl (748 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 748.5/748.5 kB 32.3 MB/s eta 0:00:00
Downloading termcolor-2.4.0-py3-none-any.whl (7.7 kB)
Building wheels for collected packages: projects, urwid
  Building wheel for projects (setup.py): started
  Building wheel for projects (setup.py): finished with status 'done'
  Created wheel for projects: filename=projects-1.0.9-py3-none-any.whl size=48614 sha256=1ef52d51de968b76db922dd1452da3ea7f2d0b0a4b352c463fa8dcb4ec992f35
  Stored in directory: /root/.cache/pip/wheels/4c/ab/60/b7fc650fa083840f83fd9cb157f2bb070c01dfbbe6e73cb6c2
  Building wheel for urwid (setup.py): started
  Building wheel for urwid (setup.py): finished with status 'done'
  Created wheel for urwid: filename=urwid-2.1.2-cp311-cp311-linux_x86_64.whl size=257669 sha256=c186bc82f5af285b8cc570cfff22d73b2b7b8f15ae26ef1c0d8d3b0db7e8f253
  Stored in directory: /root/.cache/pip/wheels/54/de/c3/b2fb02a7673009024f2aed6aa1e2a5e99e015909680b64da07
Successfully built projects urwid
Installing collected packages: urwid, termcolor, pyyaml, mock, MarkupSafe, itsdangerous, colorama, click, blinker, Werkzeug, projects, Jinja2, flask
Successfully installed Jinja2-3.1.3 MarkupSafe-2.1.5 Werkzeug-3.0.1 blinker-1.7.0 click-8.1.7 colorama-0.4.6 flask-3.0.2 itsdangerous-2.1.2 mock-5.0.1 projects-1.0.9 pyyaml-6.0.1 termcolor-2.4.0 urwid-2.1.2
--> 00cdf051c162
STEP 20/22: ENV PATH=/root/.local:$PATH
--> fbe20c161458
STEP 21/22: CMD [ "python3", "-u", "/home/AI/comp/Ussage.py" ]
--> fe0111d385a6
STEP 22/22: EXPOSE 5555
COMMIT ussage:latest
--> 7c10ec94189f
Successfully tagged localhost/ussage:latest
7c10ec94189fb63dfb2b37be32dd0b9ae515675c2d3ec88db3033fb1baf00a9f

# run docker and check it's work

[root@devops lesson5.docker]# docker images

Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
REPOSITORY                TAG         IMAGE ID      CREATED            SIZE
localhost/ussage          latest      7c10ec94189f  17 seconds ago     444 MB
docker.io/library/alpine  latest      05455a08881e  3 weeks ago        7.67 MB

[root@devops lesson5.docker]# docker run -d 7c10ec94189f

Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
ad8efc1e02d012f44c7627fab6c55f62c822e8d22c50a3502c45913d141b4063

[root@devops lesson5.docker]# docker ps -all

Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
CONTAINER ID  IMAGE                    COMMAND               CREATED        STATUS        PORTS       NAMES
ad8efc1e02d0  localhost/ussage:latest  python3 -u /home/...  7 seconds ago  Up 7 seconds              bold_napier

[root@devops lesson5.docker]# docker exec -it ad8efc1e02d0 /bin/sh
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
/home/AI/comp # ifconfig
eth0      Link encap:Ethernet  HWaddr BE:10:0A:82:BD:E5
          inet addr:10.88.0.36  Bcast:10.88.255.255  Mask:255.255.0.0
          inet6 addr: fe80::bc10:aff:fe82:bde5/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:54 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:6740 (6.5 KiB)  TX bytes:838 (838.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/home/AI/comp # exit

[root@devops ~]# curl 10.88.0.36:5555/info

    Запустив этот код, мы можем получить информацию о компьютере, IP адресе, свободном месте на диске, загрузке ЦПУ
и оперативной памяти, используя следующие запросы:

GET http://localhost:5555/computer_info
GET http://localhost:5555/ip_address
GET http://localhost:5555/disk_drive
GET http://localhost:5555/disk_io_counters
GET http://localhost:5555/cpu_usage
GET http://localhost:5555/cpu_count
GET http://localhost:5555/users
GET http://localhost:5555/process
GET http://localhost:5555/sensors_temperatures
GET http://localhost:5555/memory
GET http://localhost:5555/download/subscriber

[root@devops ~]# curl 10.88.0.36:5555/memory
{"memory_free MB":11106.85,"memory_percent_usage %":19.7,"memory_total MB":15706.17,"memory_used MB":2763.89}
[root@devops ~]# curl 10.88.0.36:5555/computer_info
{"OS_release":"5.14.0-412.el9.x86_64","OS_version:":"#1 SMP PREEMPT_DYNAMIC Wed Jan 24 21:50:18 UTC 2024","computer_name":"ad8efc1e02d0","computer_platform":"Linux"}

# docker push to https://docker.io

[root@devops ~]# docker login -u cefcefcef https://docker.io
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
Password:
Login Succeeded!
[root@devops ~]# docker tag 7c10ec94189f cefcefcef/devops:ussage
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
[root@devops ~]# docker push cefcefcef/devops:ussage
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
Getting image source signatures
Copying blob 1a8e4032a478 done   |
Copying blob c86af69d63bd done   |
Copying blob cca6328be7b5 done   |
Copying blob bf8ec1ba7b95 done   |
Copying blob 7afc07601882 done   |
Copying blob 4abcf2066143 skipped: already exists
Copying blob ac095fecec67 done   |
Copying blob 1e4f14bd48ad done   |
Copying blob ad7317ba51c6 done   |
Copying blob cfda0a844ddf done   |
Copying blob 22a61c298c81 done   |
Copying blob 43ab56f13fc9 done   |
Copying blob 03a6471b3af1 done   |
Copying blob 5811ba51da98 done   |
Copying blob 76a74f645269 done   |
Copying config 7c10ec9418 done   |
Writing manifest to image destination

