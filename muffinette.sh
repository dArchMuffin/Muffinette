#!/bin/bash

PROMPT_TO_CLEAN="^\[Minishell\]"

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

LEAKS_FLAG=0

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
  # log/infile to implement
  # # input redir to implement
  exit 1
fi

if [[ $(find . -maxdepth 1 -type f -name minishell | wc -l) == 0 ]]; then
  echo "Error : no 'minishell' binary found in current working directory"
  exit 1
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
  exit 1
fi

# Johann working on ...
if [[ $1 == "--muffin" ]]; then
  echo "error: bakery not implemented yet"
  exit 1
fi

mkdir -p log
touch log/outfile
touch log/infile

INPUT=$(printf "%s\n" "$@")

./minishell << EOF 2> /dev/null | grep -v "$PROMPT_TO_CLEAN" > log/minishell_output 
$INPUT
EOF
EXIT_CODE_P=$?

bash << EOF 2> /dev/null | grep -v "$PROMPT_TO_CLEAN" > log/bash_output
$INPUT
EOF
EXIT_CODE_B=$?

./minishell << EOF 2> log/minishell_stderr > /dev/null
$INPUT
EOF

bash << EOF 2> log/bash_stderr > /dev/null
$INPUT
EOF

CLEAN=0

echo -e "----------| Muffinette |----------\n"
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

if [[ $CLEAN == 0 ]]; then
  rm -rd log
fi
