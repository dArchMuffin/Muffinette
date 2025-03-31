#!/bin/bash

mkdir -p log

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

#if your STDOUT appears always KO, read the README and edit this line
PROMPT="$(echo -e "\n" | ./minishell | awk '{print $1}' | head -1)"

# uncommenting following lines will always displays the sequence sent to test in head of the tastor output
# for arg in "$@"; do
#   if [[ "$arg" != "--leaks" && "$arg" != "-r" && "$arg" != "-ra" ]]; then
#     echo -e "$PROMPT $arg"
#   fi
# done
# echo ""

# comment these lines to test an empty infile, or customize for your taste
echo -e "Some people... some people like cupcakes, exclusively... 
while myself, I say, there is naught nor ought there be nothing
So exalted on the face of god's grey earth as that prince of foods... 
the muffin!

Franc Zappa - Muffin Man" > log/infile

if [[ -z $1 ]]; then
  echo -e "-----------------------------| Muffinette usage |-----------------------------\n"
  # echo "Each line you type compose the inputs sequence"
  # echo "Just send an empty prompt to run the sequence"
  # echo ""
  # echo "Consult log files with : --log=stdout --log=stderr --log=valgrind"
  # echo "Run your recipes with : --recipes"
  # echo ""
  # echo "Or just say \"bye\" to quit"
  # echo ""
  echo "No input received"
  exit 
fi

# customize default files variables
#infile = 1 means it exists
INFILE=1
#infile_perm = 1 means chmod 644
INILE_PERM=1
OUTFILE=1
OUTFILE_PERM=1
FILE1=1
FILE1_PERM=1
FILE2=1
FILE2_PERM=1

LEAKS_FLAG=0

# WORKING ON Bye default, auto-save of failed tests logs is disable, switch this variable to 1 to enable it
# AUTO_SAVE=0
#
# edit this variable to set your own failed test folder for auto save of logs
# FAILED_TEST="failed_tests"

if [[ $(find . -maxdepth 1 -type f -name minishell | wc -l) == 0 ]]; then
  echo "Error : no 'minishell' binary found in current working directory"
  exit 
fi

# All these lines are switches to enable or disable some features 
# To change default values, edit the variables in CLI directly
if [[ $1 == "--leaks" ]]; then
  LEAKS_FLAG=1;
  shift
fi

# if [[ $1 == "--as" ]]; then
#   if [[ $AUTO_SAVE == 1 ]]; then
#     AUTO_SAVE=0
#   else
#     AUTO_SAVE=1
#   fi
#   shift
# fi

if [[ $1 == "-r" ]]; then
  REDIR=1;
  shift
fi

if [[ $1 == "--infile=off" ]]; then
  INFILE=0
  shift
fi
if [[ $1 == "--infile=000" ]]; then
  INFILE_PERM=0
  shift
fi
if [[ $1 == "--file1=off" ]]; then
  FILE1=0
  shift
fi
if [[ $1 == "--file1=000" ]]; then
  FILE1_PERM=0
  shift
fi
if [[ $1 == "--file2=off" ]]; then
  FILE2=0
  shift
fi

if [[ $1 == "--file2=000" ]]; then
  FILE2_PERM=0
  shift
fi
if [[ $1 == "--outfile=off" ]]; then
  OUTFILE=0
  shift
fi

if [[ $1 == "--outfile=000" ]]; then
  OUTFILE_PERM=0
  shift
fi

# We clean all existing files first
[ -f "log/outfile" ] && rm -f "log/outfile"
[ -f "log/file1" ] && rm -f "log/file1"
[ -f "log/file2" ] && rm -f "log/file2"
[ -f "log/infile" ] && rm -f "log/infile"

# Then, following the flags sent to tastor.sh, we create and chmod the files
if [[ $INFILE == 1 ]]; then
  touch log/infile
  if [[ $INFILE_PERM == 0 ]]; then
    chmod 000 log/infile
  fi
fi
if [[ $OUTFILE == 1 ]]; then
  touch log/outfile
  if [[ $OUTFILE_PERM == 0 ]]; then
    chmod 000 log/outfile
  fi
fi
if [[ $FILE1 == 1 ]]; then
  touch log/file1
  if [[ $FILE1_PERM == 0 ]]; then
    chmod 000 log/file1
  fi
fi
if [[ $FILE2 == 1 ]]; then
  touch log/file2
  if [[ $FILE2_PERM == 0 ]]; then
    chmod 000 log/file2
  fi
fi

# There is a no perm file available anyway
touch log/file_without_permissions
chmod 000 log/file_without_permissions

# Johann working on ...
if [[ $1 == "--muffin" ]]; then
  echo "error: bakery not implemented yet"
  exit 
fi

# using \n as a separator to delimitate inputs in get_next_line / read of minishell / bash 
INPUT=$(printf "%s\n" "$@")

#recording original state of files for redirection check
OLD_OUTFILE=$(<log/outfile)
OLD_FILE1=$(<log/file1)
OLD_FILE2=$(<log/file2)

# using here_doc on minishell and bash to simulate sequences of inputs
# rederecting stdout  
./minishell << EOF 2> /dev/null > log/minishell_output 
$INPUT
EOF
#using $? to get last exit code
EXIT_CODE_P=$?

# Since minishell prints its prompt and input these lines clean it from its output file
# but first, PROMPT probably include special characters, sed can make it readable 
ESCAPED_PROMPT=$(printf "%s" "$PROMPT" | sed 's/[]\/$*.^[]/\\&/g')

# now we use sed to remove lines begnning with your minishell prompt
sed -i "/^$ESCAPED_PROMPT/d" log/minishell_output
# -i edit a file
# ^ lines beginning with 
# /d deletion

# getting output in files for redirections check
MINISHELL_OUTFILE=$(<log/outfile)
MINISHELL_FILE1=$(<log/file1)
MINISHELL_FILE2=$(<log/file2)

# get files back to original state for bash to use it in same conditions now
echo "$OLD_OUTFILE" > log/outfile
echo "$OLD_FILE1" > log/file1
echo "$OLD_FILE2" > log/file2

# Execute the same test on bash to have a reference 
bash << EOF 2> /dev/null > log/bash_output
$INPUT
EOF
EXIT_CODE_B=$?

# getting output in files for bash redirection reference
BASH_OUTFILE=$(<log/outfile)
BASH_FILE1=$(<log/file1)
BASH_FILE2=$(<log/file2)

# same double test for STDERR 
./minishell << EOF 2> log/minishell_stderr > /dev/null
$INPUT
EOF

bash << EOF 2> log/bash_stderr > /dev/null
$INPUT
EOF

CLEAN=0
# some spicy stuff with valgrind
if [[ $LEAKS_FLAG == 1 ]]; then
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --show-mismatched-frees=yes --track-fds=yes --trace-children=yes ./minishell << EOF 2>&1 | tee log/valgrind_output | grep -v "$PROMPT" > /dev/null
$INPUT
EOF

  LEAKS=0

  # Basicaly, if we find this line in the log file, it means there's a segfault, so print in red KO etc...
  if grep -q "Process terminating with default action of signal 11 (SIGSEGV)" log/valgrind_output; then
    echo -e "${RED}SEGMENTATION FAULT !${NC}"
    LEAKS=1
  fi

  # if there is definitely lost or still reachable, this line appears in valgrind output
  if ! grep -q "LEAK SUMMARY" log/valgrind_output; then
    echo -e "${GREEN}NO LEAKS${NC}"
  else
    LEAKS=1
    echo -e "${RED}LEAKS !${NC}"
  fi

  # conditionnal jump or invalid read of size will prevent this line to appear on the valgrind output
  # Here we will have all children reports, so we need to clean first the "expected outputs" for the line "ERROR SUMMARY" and if we still find a line "ERROR SUMMARY" it can be only errors
  NB_ERR=$(grep -v "ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)" log/valgrind_output | grep "ERROR SUMMARY: " | wc -l)
    if [[ $NB_ERR == 0 ]]; then
    echo -e "${GREEN}NO ERRORS${NC}"
  else
    LEAKS=1
    echo -e "${RED}$NB_ERR ERRORS !${NC}"
  fi

  # This line appears if your minishell creates zombie process
  if [[ ! $(grep -q "ERROR: Some processes were left running at exit." log/valgrind_output) ]]; then
    echo -e "${GREEN}NO ZOMBIE PROCESS${NC}"
  else
    LEAKS=1
    echo -e "${RED}ZOMBIE PROCESS !${NC}"
  fi

  # This line is found only if there is at least one fd still open at exit in a processm excluding the 3 standards ones
  if [[ $(grep -v "Open file descriptors" log/valgrind_output) ]]; then
    echo -e "${GREEN}FD CLOSED${NC}"
  else
    LEAKS=1
    echo -e "${RED}FD OPEN AT EXIT !${NC}"
  fi

  # if any of previous if was activated, invite user to consult the valgrind log 
  if [[ $LEAKS == 1 ]]; then
    echo -e "Full valgrind log : \e]8;;file://$(pwd)/log/valgrind_output\alog/valgrind_output\e]8;;\a"
  fi
fi


# All following lines basicaly operate diffs and greps on the logs files, to determine if the test is passed or not
CLEAN=$LEAKS

# print result for STDOUT : a diff on the two outputfiles 
if diff -q log/minishell_output log/bash_output > /dev/null; then
  echo -e "STDOUT : ${GREEN}OK${NC}"
else
  echo -e "STDOUT : ${RED}KO${NC}"
  CLEAN=1
  diff log/minishell_output log/bash_output
fi

ERROR_MISSING=0

# checking stderr : the -i option ignore upper/lowercase difference. We assume you stick to bash
# you can still customize the second grep for your custom error message
if [[ $(grep -i "command not found" log/bash_stderr | wc -l) != $(grep -i "command not found" log/minishell_stderr | wc -l) ]]; then
  ERROR_MISSING=1
fi
if [[ $(grep -i "Permission denied" log/bash_stderr | wc -l) != $(grep -i "Permission denied" log/minishell_stderr | wc -l) ]]; then
  ERROR_MISSING=1
fi
if [[ $(grep -i "Is a directory" log/bash_stderr | wc -l) != $(grep -i "Is a directory" log/minishell_stderr | wc -l) ]]; then
  ERROR_MISSING=1
fi
if [[ $(grep -i "No such file or directory" log/bash_stderr | wc -l) != $(grep -i "No such file or directory" log/minishell_stderr | wc -l) ]]; then
  ERROR_MISSING=1
fi
# //too many files open

if [[ $ERROR_MISSING != 0 ]]; then
  CLEAN=1
fi

# printing result for STDERR
if [[ $ERROR_MISSING == 0 ]] ; then
  echo -e "STDERR : ${GREEN}OK${NC}"
else
  echo -e "STDERR : ${RED}KO${NC}"
  diff log/minishell_stderr log/bash_stderr
  CLEAN=1
fi

# comparing exit code
if [[ "$EXIT_CODE_P" -ne "$EXIT_CODE_B" ]]; then
  echo -e "EXIT : ${RED}KO${NC}"
  echo -e "bash : $EXIT_CODE_B\nminishell: $EXIT_CODE_P"
  CLEAN=1
else
  echo -e "EXIT : ${GREEN}OK${NC}"
fi

# Option redirection : we compare all files available to test redirections
if [[ $REDIR == 1 ]]; then
  if [[ $(diff -q "$MINISHELL_OUTFILE" "$BASH_OUTFILE" > /dev/null 2> /dev/null) ]] || 
    [[ $(diff -q "$MINISHELL_FILE1" "$BASH_FILE1" > /dev/null 2> /dev/null) ]] ||
    [[ $(diff -q "$MINISHELL_FILE2" "$BASH_FILE2" > /dev/null 2> /dev/null) ]]; then
    echo -e "REDIR > : ${RED}KO${NC}"
    diff $MINISHELL_OUTFILE $BASH_OUTFILE
    diff $MINISHELL_FILE1 $BASH_FILE1
    diff $MINISHELL_FILE2 $BASH_FILE2
    $CLEAN = 1
  else
    echo -e "REDIR > : ${GREEN}OK${NC}"
  fi
    echo -e "minishell outfile : \n" > log/outfile
    echo -e $MINISHELL_OUTFILE >> log/outfile
    echo -e "--------------------------------" >> log/outfile
    echo -e "bash outfile : \n" >> log/outfile
    echo -e $BASH_OUTFILE >> log/outfile
    echo -e "minishell file1 : \n" > log/file1
    echo -e $MINISHELL_FILE1 >> log/file1
    echo -e "--------------------------------" >> log/file1
    echo -e "bash file1 : \n" >> log/file1
    echo -e $BASH_FILE2 >> log/file2
    echo -e "minishell file2 : \n" > log/file2
    echo -e $MINISHELL_FILE2 >> log/file2
    echo -e "--------------------------------" >> log/file2
    echo -e "bash file2 : \n" >> log/file2
    echo -e $BASH_FILE2 >> log/file2
fi

# if [[ $CLEAN == 1 && $AUTO_SAVE == 1 ]]; then
#   mkdir -p $FAILED_TEST
#   TEST_FOLDER=$FAILED_TEST/$(printf "%s_" "$@")
#   mkdir -p $TEST_FOLDER
#   cp log/* $TEST_FOLDER
#   echo "Failed test saved in $FAILED_TEST"
# fi

chmod 644 log/infile
chmod 644 log/file1
chmod 644 log/file2
chmod 644 log/outfile
echo "" > log/outfile
