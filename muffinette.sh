#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

# uncomment last line of this script to 
# disable autoclean of the log folder
mkdir -p log

#comment to test non existing files
touch log/outfile
touch log/infile

#uncomment and tweak yourself to test permissions
# chmod 000 log/outfile
# chmod 000 log/infile

# Edit this line and uncomment last lines of this script
# to save failed tests in the file of your choice using its relative or absolute path:
FAILED_TESTS_FOLDER="../failed_tests"
# working on ..

#if your STDOUT appears always KO for no reason, read the README and edit this line
PROMPT="$(echo -e "\n" | ./minishell | awk '{print $1}' | head -1)"

#comment these lines for a shorter output for quick tests or muff.sh full tests
echo -e "----------| Muffinette |----------"
echo ""
for arg in "$@"; do
  if [[ "$arg" != "--leaks" && "$arg" != "-r" && "$arg" != "-ra" ]]; then
    echo -e "$PROMPT $arg"
  fi
done
echo ""

# comment these lines to test an empty infile
echo -e "Some people... some people like cupcakes, exclusively... 
while myself, I say, there is naught nor ought there be nothing
So exalted on the face of god's grey earth as that prince of foods... 
the muffin!

Franc Zappa - Muffin Man" > log/infile

if [[ -z $1 ]]; then
  echo -e "-----------------------------| Muffinette usage |-----------------------------\n"
  echo -e "1 : Make sure to have your minishell binary in muffinette's folder"
  echo -e "2 : Your binary must be named \"minishell\""
  echo -e "3 : If the STDOUT test always fails for not reason, edit muffinette.sh following the README"
  exit 
fi

LEAKS_FLAG=0

if [[ $(find . -maxdepth 1 -type f -name minishell | wc -l) == 0 ]]; then
  echo "Error : no 'minishell' binary found in current working directory"
  exit 
fi

if [[ $1 == "--leaks" ]]; then
  LEAKS_FLAG=1;
  shift
fi

if [[ $1 == "-r" ]]; then
  REDIR=1;
  shift
fi

if [[ $1 == "-ra" ]]; then
  REDIR_A=1;
  shift
fi

if [[ $1 == "--clean" ]]; then
  rm -rd log
  exit 
fi

# Johann working on ...
if [[ $1 == "--muffin" ]]; then
  echo "error: bakery not implemented yet"
  exit 
fi

# using \n as a separator to delimitate inputs in get_next_line / read of minishell / bash 
INPUT=$(printf "%s\n" "$@")

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

# We execute the same test on bash to have a reference 
bash << EOF 2> /dev/null > log/bash_output
$INPUT
EOF
EXIT_CODE_B=$?

# same double test for STDERR 
./minishell << EOF 2> log/minishell_stderr > /dev/null
$INPUT
EOF

bash << EOF 2> log/bash_stderr > /dev/null
$INPUT
EOF

# some spicy stuff with valgrind
if [[ $LEAKS_FLAG == 1 ]]; then
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --show-mismatched-frees=yes --track-fds=yes --trace-children=yes ./minishell << EOF 2>&1 | tee log/valgrind_output | grep -v "$PROMPT_TO_CLEAN" > /dev/null
$INPUT
EOF

  LEAKS=0

  if grep -q "Process terminating with default action of signal 11 (SIGSEGV)" log/valgrind_output; then
    echo -e "${RED}SEGMENTATION FAULT !${NC}"
  fi

  if ! grep -q "LEAK SUMMARY" log/valgrind_output; then
    echo -e "${GREEN}NO LEAKS${NC}"
  else
    LEAKS=1
    echo -e "${RED}LEAKS !${NC}"
  fi

  NB_ERR=$(grep -v "ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)" log/valgrind_output | grep "ERROR SUMMARY: " | wc -l)
    if [[ $NB_ERR == 0 ]]; then
    echo -e "${GREEN}NO ERRORS${NC}"
  else
    LEAKS=1
    echo -e "${RED}$NB_ERR ERRORS !${NC}"
  fi

  if [[ ! $(grep -q "ERROR: Some processes were left running at exit." log/valgrind_output) ]]; then
    echo -e "${GREEN}NO ZOMBIE PROCESS${NC}"
  else
    LEAKS=1
    echo -e "${RED}ZOMBIE PROCESS !${NC}"
  fi

  # changer ca
  if [[ ! $(grep -v "FILE DESCRIPTORS: 3 open (3 std) at exit." log/valgrind_output | grep -q "FILES DESCRIPTORS") ]]; then
    echo -e "${GREEN}FD CLOSED${NC}"
  else
    LEAKS=1
    echo -e "${RED}FD OPEN AT EXIT !${NC}"
  fi

  if [[ $LEAKS == 1 ]]; then
    echo -e "Full valgrind log : \e]8;;file://$(pwd)/log/valgrind_output\alog/valgrind_output\e]8;;\a"
  fi
fi

CLEAN=0

if diff -q log/minishell_output log/bash_output > /dev/null; then
  echo -e "STDOUT : ${GREEN}OK${NC}"
else
  echo -e "STDOUT : ${RED}KO${NC}"
  CLEAN=1
  diff log/minishell_output log/bash_output
fi

ERROR_MISSING=0

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
  CLEAN = 1
fi

if [[ $ERROR_MISSING == 0 ]] ; then
  echo -e "STDERR : ${GREEN}OK${NC}"
else
  echo -e "STDERR : ${RED}KO${NC} : diff log/bash_stderr log/minishell_stderr"
  CLEAN=1
fi


if [[ "$EXIT_CODE_P" -ne "$EXIT_CODE_B" ]]; then
  echo -e "EXIT : ${RED}KO${NC}"
  echo -e "bash : $EXIT_CODE_B\nminishell: $EXIT_CODE_P"
  CLEAN=1
else
  echo -e "EXIT : ${GREEN}OK${NC}"
fi

if [[ $REDIR == 1 ]]; then
./minishell << EOF | grep -v "$PROMPT_TO_CLEAN" > log/outfile > /dev/null
$INPUT
EOF

  MINISHELL_OUTFILE=$(<log/outfile)

bash << EOF > log/outfile > /dev/null
$INPUT
EOF

  BASH_OUTFILE=$(<log/outfile)

  if diff -q "$MINISHELL_OUTFILE" "$BASH_OUTFILE" > /dev/null 2>/dev/null; then
    echo -e "REDIR > : ${RED}KO${NC}"
    diff $MINISHELL_OUTFILE $BASH_OUTFILE
    echo -e "minishell output : \n"
    echo -e $MINISHELL_OUTFILE > log/outfile
    echo -e "bash output : \n"
    echo -e $BASH_OUTFILE >> log/outfile
    $CLEAN = 1
  else
    echo -e "REDIR > : ${GREEN}OK${NC}"
  fi
fi

if [[ $REDIR_A == 1 ]]; then
./minishell << EOF | grep -v "$PROMPT_TO_CLEAN" > log/outfile > /dev/null
$INPUT
EOF

  MINISHELL_OUTFILE=$(<log/outfile)

bash << EOF > log/outfile > /dev/null
$INPUT
EOF

  BASH_OUTFILE=$(<log/outfile)

  if diff -q "$MINISHELL_OUTFILE" "$BASH_OUTFILE" > /dev/null 2>/dev/null; then
    echo -e "REDIR >> : ${RED}KO${NC}"
    diff $MINISHELL_OUTFILE $BASH_OUTFILE
    echo -e "minishell output : \n"
    echo -e $MINISHELL_OUTFILE > log/outfile
    echo -e "bash output : \n"
    echo -e $BASH_OUTFILE >> log/outfile
    $CLEAN = 1
  else
    echo -e "REDIR >> : ${GREEN}OK${NC}"
  fi
fi


# working on
# uncomment these lines and edit FAILED_TESTS_FOLDER to save your logs
# if [[ $CLEAN == 1 ]]; then
#   FAILED_TEST="Muffinette_failed_test_$(date +"%Y-%m-%d_%H-%M-%S")"
#   mkdir $FAILED_TESTS_FOLDER/$FAILED_TEST
#   echo -e "----------| Muffinette |----------" > "$FAILED_TESTS_FOLDER\/$FAILED_TEST\/input" 
#   echo -e "" >> $FAILED_TESTS_FOLDER\/$FAILED_TEST\/input
#   for arg in "$@"; do
#     if [[ "$arg" != "--leaks" && "$arg" != "-r" && "$arg" != "-ra" ]]; then
#       echo -e "$PROMPT $arg" >> $FAILED_TESTS_FOLDER\/$FAILED_TEST\/input
#     fi
#   done
#   cp log/* $FAILED_TESTS_FOLDER/$FAILED_TEST/
# fi

# comment to disable autoclean of log folder
if [[ $CLEAN == 0 ]]; then
  rm -rd log
fi

#experimenting
# kitty --detach bash -c "cat << EOF | ./minishell 2>/dev/null 
# $INPUT
# EOF
# read"
#
# kitty --detach bash -c "cat << EOF | bash 2>/dev/null
# $INPUT
# EOF
# read"
