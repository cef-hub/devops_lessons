#!/bin/bash
echo "Created 1st test filename: 'file_with_error.txt' with error in current directory"
> file_with_error.txt
`sh -c 'cat << EOF >> file_with_error.txt 
1st str
some text
here error str
N str 
EOF'`
echo "Created 2st test filename: 'file_with_error1.txt' with error in current directory"
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
echo "ls:" && ls
echo "Enter pls 'word_mask' for files deletion: "
read word_mask
#echo "You enter: $word_mask"
echo "Enter the 'path' for files deletion: "
read del_path
#echo "You select path: $del_path"
grep -wrsl --exclude="*.sh" $word_mask $del_path | xargs rm
echo "Delete complite"
echo 'ls:' && ls

