#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

# Edit this line following what 
# appears in the terminal when you execute your minishell 
PROMPT_TO_CLEAN="^\[Minishell\]"
# preserving the ^ character is important, use \ for special characters 

# uncomment last line of this script to 
# disable autoclean of the log folder
mkdir -p log

# Edit this line and uncomment last lines of this script
# to save failed tests in the file of your choice using its relative or absolute path:
FAILED_TESTS_FOLDER="../failed_tests"

#comment to test non existing files
touch log/outfile
touch log/infile

#uncomment and tweak yourself to test permissions
# chmod 000 log/outfile
# chmod 000 log/infile

#comment these lines for a shorter output for quick tests or muff.sh full tests
echo -e "----------| Muffinette |----------"
echo ""
for arg in "$@"; do
    echo -e "$PROMPT_TO_CLEAN\$ $arg"
done
echo -e ""

# comment theses lines to test an empty infile
echo -e "Some people... some people like cupcakes, exclusively... 
while myself, I say, there is naught nor ought there be nothing
So exalted on the face of god's grey earth as that prince of foods... 
the muffin!

Franc Zappa - Muffin Man" > log/infile



if [[ -z $1 ]]; then
  echo -e "-----------------------------| Muffinette usage |-----------------------------\n"
  echo -e "1 : Make sure to have your minishell binary in muffinette's folder"
  echo -e "2 : Your binary must be named \"minishell\""
  echo -e "\nYour minishell probably prints its prompt and user input on stdout, bash don't"
  echo -e "To filter it and compare outputs, edit the first line of muffinette.sh: "
  echo -e "PROMPT_TO_CLEAN=\"^<your-minishell-prompt>\""
  echo -e "\n./muffinette.sh <cmd1> <cmd2> <cmd3> <cmd4>"
  echo "./muffinette.sh \"<cmd1> <args>\" <cmd2> <cmd3> <cmd4>"
  echo "./muffinette.sh \"<cmd1> <args> | <cmd2> <args>\" <cmd3> <cmd4>"
  echo -e "\nflags :"
  echo "./muffinette.sh --leaks <cmd1> <cmd2> <cmd3> <cmd4>"
  echo "./muffinette.sh --clean"
  echo -e "\nUse log/infile and log/outfile to test redirections"
  echo -e "./muffinette.sh -r <cmd1> \"<cmd2> <args> > log/outfile\""
  echo -e "\nSeveral tests as here_doc, signals or quotes management must be done manualy"
  echo -e "Some commands such as export and env will always display different outputs"
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

## THE MAGIC ##

#using \n as a separator to simulate sepearates inputs to get_next_line / read 
INPUT=$(printf "%s\n" "$@")

# Using here_doc on minishell and bash to simulate sequences of inputs
# rederecting stdout / stderr to log files 
# grep -v to clean the minishell output of his prompt
# using $? to get last exit code

./minishell << EOF 2> /dev/null | grep -v "$PROMPT_TO_CLEAN" > log/minishell_output 
$INPUT
EOF
EXIT_CODE_P=$?

bash << EOF 2> /dev/null > log/bash_output
$INPUT
EOF
EXIT_CODE_B=$?

./minishell << EOF 2> log/minishell_stderr > /dev/null
$INPUT
EOF

bash << EOF 2> log/bash_stderr > /dev/null
$INPUT
EOF

# executing diff, grep and some sweet bash syntax to compare 
# and finaly echo the results

CLEAN=0

if diff -q log/minishell_output log/bash_output > /dev/null; then
  echo -e "STDOUT : ${GREEN}OK${NC}"
else
  echo -e "STDOUT : ${RED}KO${NC}"
  CLEAN=1
  diff log/minishell_output log/bash_output
fi

. ./muffinette_stderr.sh

if [[ "$EXIT_CODE_P" -ne "$EXIT_CODE_B" ]]; then
  echo -e "EXIT : ${RED}KO${NC}"
  echo -e "bash : $EXIT_CODE_B\nminishell: $EXIT_CODE_P"
  CLEAN=1
else
  echo -e "EXIT : ${GREEN}OK${NC}"
fi

if [[ $REDIR == 1 ]]; then
  . ./muffinette_redirection.sh 2> /dev/null
fi

if [[ $REDIR_A == 1 ]]; then
  . ./muffinette_append_redirection.sh 2> /dev/null
fi

if [[ $LEAKS_FLAG == 1 ]]; then
  . ./muffinette_leaks.sh
  CLEAN=1
fi

# uncomment these lines and edit FAILED_TESTS_FOLDER to save your logs
# echo -e "----------| Muffinette |----------" > $FAILED_TESTS_FOLDER/$(date +"%Y-%m-%d_%H-%M-%S")echo "" > $FAILED_TESTS_FOLDER/input_$(date +"%Y-%m-%d_%H-%M-%S")
# for arg in "$@"; do
    # echo -e "$PROMPT_TO_CLEAN\$ $arg" >> $FAILED_TESTS_FOLDER/input_$(date +"%Y-%m-%d_%H-%M-%S")
# done
# cp log/* $FAILED_TESTS_FOLDER/

# comment to disable autoclean of log folder
if [[ $CLEAN == 0 ]]; then
  rm -rd log
fi
