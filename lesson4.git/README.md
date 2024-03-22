#TASK1

echo "again text" > text_file.txt
echo "some text" > some.txt
echo "1" > text.txt
echo "2" > text1.txt
echo "3" > text2.txt
echo "i am pdf file" > 1.pdf
echo "again pdf" > 2.pdf
echo "image" > image.png

ls

1.pdf  first_file.sh  README.md       some.txt   text2.txt      text.txt
2.pdf  image.png      second_file.sh  text1.txt  text_file.txt  third_file.sh

echo 'lesson4/*.txt' > .gitignore

git branch
* main

git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   2.pdf

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        README.md
        image.png

		
git ls-files -o --ignored --exclude-standard
some.txt
text.txt
text1.txt
text2.txt
text_file.txt

git add lesson4/

git commit -m "add some file txt and other"
[main e1363d6] add some file txt and other
 3 files changed, 4 insertions(+)
 create mode 100644 lesson4/2.pdf
 create mode 100644 lesson4/README.md
 create mode 100644 lesson4/image.png

git push -u origin main
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 2 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (6/6), 534 bytes | 267.00 KiB/s, done.
Total 6 (delta 1), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To github.com:cef-hub/devops_lessons.git
   df6e287..e1363d6  main -> main
branch 'main' set up to track 'origin/main'.

#TASK2

git checkout -b dev
Switched to a new branch 'dev'

git branch
* dev
  main
  
echo "I am a python script" > lesson4/python_script1.py
echo "I am a python script2" > lesson4/python_script2.py
ls lesson4/
1.pdf  first_file.sh  python_script1.py  README.md       some.txt   text2.txt      text.txt
2.pdf  image.png      python_script2.py  second_file.sh  text1.txt  text_file.txt  third_file.sh

git add lesson4/
git commit -m "add two python scripts to branch DEV"
[dev 924d629] add two python scripts to branch DEV
 3 files changed, 62 insertions(+)
 create mode 100644 lesson4/python_script1.py
 create mode 100644 lesson4/python_script2.py
 
git log -3
commit 924d6296c1d0a9e211fdbe446e25a033944fd7b4 (HEAD -> dev)
Author: cef <wanna_be@tut.by>
Date:   Fri Feb 16 09:52:21 2024 +0300

    add two python scripts to branch DEV

commit e1363d6a9b6d64562fedfdae20ecc11a102eedba (origin/main, main)
Author: cef <wanna_be@tut.by>
Date:   Fri Feb 16 09:33:31 2024 +0300

    add some file txt and other

commit df6e287a60558ab24cf916626b1a8dc6a39b79d7
Author: cef <wanna_be@tut.by>
Date:   Fri Feb 16 09:01:45 2024 +0300

    add .gitignore file

echo "I am a python script3 and I am wont to MAIN branch merge" > lesson4/python_script3.py
git add lesson4/
git commit -m "add next one script to branch DEV and that is we need in MAIN branch"
[dev 9d7a647] add next one script to branch DEV and that is we need in MAIN branch
 1 file changed, 1 insertion(+)
 create mode 100644 lesson4/python_script3.py
git log -4
commit 9d7a647d33bad436e5ae2367628fee7d29bce168 (HEAD -> dev)
Author: cef <wanna_be@tut.by>
Date:   Fri Feb 16 09:54:47 2024 +0300

    add next one script to branch DEV and that is we need in MAIN branch

commit 924d6296c1d0a9e211fdbe446e25a033944fd7b4
Author: cef <wanna_be@tut.by>
Date:   Fri Feb 16 09:52:21 2024 +0300

    add two python scripts to branch DEV

commit e1363d6a9b6d64562fedfdae20ecc11a102eedba (origin/main, main)
Author: cef <wanna_be@tut.by>
Date:   Fri Feb 16 09:33:31 2024 +0300

    add some file txt and other

ls
1.pdf  first_file.sh  python_script1.py  python_script3.py  second_file.sh  text1.txt  text_file.txt  third_file.sh
2.pdf  image.png      python_script2.py  README.md          some.txt        text2.txt  text.txt

git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
ls # NO python scripts
1.pdf  first_file.sh  README.md       some.txt   text2.txt      text.txt
2.pdf  image.png      second_file.sh  text1.txt  text_file.txt  third_file.sh

git cherry-pick 9d7a647d33bad436e5ae2367628fee7d29bce168
ls # we merge only python_script3.py from branch DEV with hash 9d7a647d33bad436e5ae2367628fee7d29bce168
1.pdf  first_file.sh  python_script3.py  second_file.sh  text1.txt  text_file.txt  third_file.sh
2.pdf  image.png      README.md          some.txt        text2.txt  text.txt#TASK1

git branch -D dev
git branch
* main