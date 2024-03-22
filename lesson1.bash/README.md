1.
`> ~/devops/lesson1/README.md` && `echo "1." >> ~/devops/lesson1/README.md` && `echo >> ~/devops/lesson1/README.md` && `du -S -B M /* | sort -n -r | head -n 7 &>> ~/devops/lesson1/README.md`

704M	/usr/lib64
299M	/usr/share/fonts/google-noto-cjk
279M	/usr/bin
254M	/boot
214M	/usr/lib/locale
194M	/usr/lib64/firefox
182M	/var/log/pcp/pmlogger/localhost.localdomain

2.
`echo >> ~/devops/lesson1/README.md` && `useradd -d /home/new_user new_user` && `echo usermod -aG wheel new_user` && `cat /etc/group | grep whe* &>> ~/devops/lesson1/README.md`

wheel:x:10:cef,new_user
