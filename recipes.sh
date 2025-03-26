
#!/bin/bash

mkdir -p log

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

recipes()
{
  FILTERED_ARGS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --leaks|--as|-r|--infile=*|--file1=*|--file2=*|--outfile=*)
        shift
        ;;
      *)
        FILTERED_ARGS+=("$1")
        shift
        ;;
    esac
  done

# ajouter le timeout !!
  OUTPUT=$(./taster.sh "${FILTERED_ARGS[@]}") 
  TASTOR=$(echo -e "$OUTPUT" | sed 's/\x1B\[[0-9;]*m//g')

  KO=0

  if echo -e "$TASTOR" | grep -q "STDOUT : KO"; then
    echo -en "${FILTERED_ARGS[@]} : STDOUT :$RED KO$NC"
    echo
    KO=1
  fi

  if echo -e "$TASTOR" | grep -q "STDERR : KO"; then
    echo -en "${FILTERED_ARGS[@]} : STDERR :$RED KO$NC"
    echo
    KO=1
  fi

  if echo -e "$TASTOR" | grep -q "EXIT : KO"; then
    echo -en "${FILTERED_ARGS[@]} : EXIT :$RED KO$NC"
    echo
    KO=1
  fi

  if echo -e "$TASTOR" | grep -q "SEGMENTATION FAULT"; then
    echo -en "${FILTERED_ARGS[@]} : $RED SEGMENTATION FAULT$NC"
    echo
    KO=1
  fi

  if echo -e "$TASTOR" | grep -q "LEAKS !"; then
    echo -en "${FILTERED_ARGS[@]} : LEAKS :$RED KO$NC"
    echo
    KO=1
  fi

  if echo -e "$TASTOR" | grep -q "ZOMBIE PROCESS !"; then
    echo -en "${FILTERED_ARGS[@]} : ZOMBIE PROCESS :$RED KO$NC"
    echo
    KO=1
  fi

  if echo -e "$TASTOR" | grep -q "ERRORS !"; then
    echo -en "${FILTERED_ARGS[@]} : VALGRIND ERRORS :$RED KO$NC"
    echo
    KO=1
  fi

  if echo -e "$TASTOR" | grep -q "FD OPEN AT EXIT !"; then
    echo -en "${FILTERED_ARGS[@]} : FD :$RED KO$NC"
    echo
    KO=1
  fi

  if echo -e "$TASTOR" | grep -q "REDIR > : KO"; then
    echo -en "${FILTERED_ARGS[@]} : REDIR > :$RED KO$NC"
    echo
    KO=1
  fi

  if [[ $KO == 0 ]]; then
    echo -en "${FILTERED_ARGS[@]} :$GREEN OK$NC"
    echo
  fi
}

#test by yourself !
# recipes "your" "own"
# recipes "t" "e" "s" "t" "S"

#each argument is an input, use double quotes to delimate it
recipes "pwd" "cd" "pwd"
#
# #so make sure to gather arguments
recipes "ls -l" "cd .." "ls -l"
#
# #test pipe as an argument 
recipes "ls -l | wc -l" "pwd"
#
# #or even a redirection, but dont forget the flag as first argument !
recipes "-r" "echo -e '180g milk' > log/outfile" 
#
# #always put the --leaks as flag first !
recipes "--leaks" "-r" "echo -e '5g vanilla' >> log/outfile"
#
# #to test quotes, use \" or ' or \' ... 
recipes "echo -e \"two eggs\"" "echo -e '100g sugar'" 
#
#

recipes "pwd" "cd" "ls" 
recipes "echo \"hello\"" 
recipes "echo \"hello\"" "ls -l" "cd .." "pwd" 
recipes "ls -l" "pwd" "cd .." "pwd" "cd " 
recipes "pwd" "cd .." "ls" "echo \"hello\"" "ls | wc -l" 
