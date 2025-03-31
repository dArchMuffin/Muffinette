#!/bin/bash

# To customize this CLI yourself, see below how to edits the cmds or to implement your own command

# I used yellow color to visualy separate the output of muffinette.sh and tastor.sh
# tastor.sh prints in white, muffinette.sh prints in yellow
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

# set -x

mkdir -p log

# Cookware has functions to display infos and set flags
# customize yourself infos displayed by editing or adding a function in cookware.sh
source cookware.sh

# theses variables set timeout duration, valgrind check and redirection check to disable by default
# just switch it to 1 to enable it by default, or use CLI cmds
TIMEOUT_DURATION=5
VALGRIND_FLAG=0
R_FLAG=0

# Here you can enable or disable files existence or permissions by default
INFILE_FLAG=0
INFILE_PERM_FLAG=0
# INFILE_FLAG = 0 means the file will be existing during tests / 1 means it will NOT exist for tests
# INFILE_PERM_FLAG = 0 means it will be chmod 644 / 1 means chmod 000

FILE1_FLAG=0
FILE1_PERM_FLAG=0

FILE2_FLAG=0
FILE2_PERM_FLAG=0

OUTFILE_FLAG=0
OUTFILE_PERM_FLAG=0

# working on ...
# AUTO_SAVE_FLAG=0

echo -en "${YELLOW}[Muffinette]\$ ${NC}"

ARGS=()

# As a simple CLI, i used a read in while, with a switch case. Each case corresponding to one command, or an input to 
# add to the sequence to test if the input does not match any command
# IFS= and -r allow user to use muffinette prompt exactly the same way we use bash or minishell
while IFS= read -r INPUT; do
# using switch cases instead of elifs makes the code cleaner more lisible and easier to edit
# see at the end of this script to add your own custom command
  case "$INPUT" in
    # the ! tests are meant to lead tests quickly, loading last sequence back and executing it with an additional option 
    # ! after a test, load back last sequence in buffer
    "!")
      ARGS=$(printf "%s\n" "${LAST_SEQ[@]}")
      printf "${YELLOW}%s\n" "${LAST_SEQ[@]}"
      ;;
    # !! after a test, load back and execute last sequence
    "!!")
      set_flags
      timeout "${TIMEOUT_DURATION}s" ./taster.sh "${FLAGS[@]}" "${LAST_SEQ[@]}" 2> /dev/null
      if [[ $? -eq 124 ]]; then
        echo -e "${RED}TIME OUT !${NC}"
      fi
      ;;
    # !! after a test, load back and execute last sequence with a valgrind test
    "!v")
      VALGRIND_FLAG=1
      set_flags
      timeout "${TIMEOUT_DURATION}s" ./taster.sh "${FLAGS[@]}" "${LAST_SEQ[@]}" 2> /dev/null
      if [[ $? -eq 124 ]]; then
        echo -e "${RED}TIME OUT !${NC}"
      fi
      VALGRIND_FLAG=0
      ;;
    # !! after a test, load back and execute last sequence with a redirection test
    "!>")
      R_FLAG=1
      set_flags
      timeout "${TIMEOUT_DURATION}s" ./taster.sh "${FLAGS[@]}" "${LAST_SEQ[@]}" 2> /dev/null
      if [[ $? -eq 124 ]]; then
        echo -e "${RED}TIME OUT !${NC}"
      fi
      R_FLAG=0
      ;;
    # -h --help : dispaly help
    "-h"|"--help")
      print_help
      ;;
    # -bye : quit and clean
    "bye"|"quit"|"exit")
      pgrep watch | tail -n +2 | xargs kill 2> /dev/null
      # if [[ ! -z log/file_without_permissions ]]; then
      #   chmod 644 log/file_without_permissions
      # fi
      rm -rf log 2> /dev/null
      exit 0
      ;;
    # --watch= : new tty with watch on a log file option
    # see README for details
    # "--auto-save")
      # if [[ $AUTO_SAVE_FLAG == 1 ]]; then
        # AUTO_SAVE_FLAG=0
      # else
        # AUTO_SAVE_FLAG=1
      # fi
      # ;;
    "--muffinator")
    # terminator -l config
    # virer tout le watch log de cookware
      ;;
    # --print=* : print log file
    "--print=stdout")
      print_stdout
      ;;
    "--print=stderr")
      print_stderr
      ;;
    "--print=valgrind")
      cat log/valgrind_output
      ;;
    "--print=outfile")
      cat log/outfile
      ;;
      # Valgrind test switch
    "--valgrind"|"-vg")
      VALGRIND_FLAG=$((1 - VALGRIND_FLAG))
      echo -e "${YELLOW}valgrind_flag = $( [[ $VALGRIND_FLAG -eq 1 ]] && echo ON || echo OFF )${NC}"
      ;;
      # Redirection test switch
    "- >")
      R_FLAG=$((1 - R_FLAG))
      echo -e "${YELLOW}> = $( [[ $R_FLAG -eq 1 ]] && echo ON || echo OFF )${NC}"
      ;;
      # Display flags status
    "--print=flags"|"-pf")
      print_flags
      ;;
      # Display sequence in buffer
    "--print=seq"|"-ps")
      printf "${YELLOW}%s\n" "${ARGS[@]}"
      echo -e "$NC"
      ;;
      # Display last sequence used
    "--print=last-seq"|"-pls")
      printf "${YELLOW}%s\n" "${LAST_SEQ[@]}"
      echo -e "$NC"
      ;;
      # run muffinette.sh with your custom tests in recipes.sh
    "--recipes")
      ./recipes.sh
      ;;
      # open a new tty with a bash shell
    "--bash")
      spatule "bash"
      ;;
      # open a new tty with a minishell shell
    "--minishell")
      spatule "minishell"
      ;;
      # open 2 tty with bash and minishell shells
    "--spatule")
      spatule "spatule"
      ;;
      # remove last input in sequence
    "--oops"|"-o")
      if [[ ${#ARGS[@]} -gt 0 ]]; then
        echo -e "${YELLOW}removed : ${ARGS[-1]}${NC}"
        unset 'ARGS[-1]'
      fi
      ;;
      # This bloc sets switches for existing files and permissions
    "--infile")
      INFILE_FLAG=$((1 - INFILE_FLAG))
      echo -e "${YELLOW}infile existing = $( [[ $INFILE_FLAG -eq 0 ]] && echo ON || echo OFF )${NC}"
      ;;
    "--infile-perm")
      INFILE_PERM_FLAG=$((1 - INFILE_PERM_FLAG))
      echo -e "${YELLOW}infile perm = $( [[ $INFILE_PERM_FLAG -eq 0 ]] && echo ON || echo OFF )${NC}"
      ;;
    "--file1")
      FILE1_FLAG=$((1 - FILE1_FLAG))
      echo -e "${YELLOW}file1 existing = $( [[ $FILE1_FLAG -eq 0 ]] && echo ON || echo OFF )${NC}"
      ;;
    "--file1-perm")
      FILE1_PERM_FLAG=$((1 - FILE1_PERM_FLAG))
      echo -e "${YELLOW}file1 perm = $( [[ $FILE1_PERM_FLAG -eq 0 ]] && echo ON || echo OFF )${NC}"
      ;;
    "--file2")
      FILE2_FLAG=$((1 - FILE2_FLAG))
      echo -e "${YELLOW}file2 existing = $( [[ $FILE2_FLAG -eq 0 ]] && echo ON || echo OFF )${NC}"
      ;;
    "--file2-perm")
      FILE2_PERM_FLAG=$((1 - FILE2_PERM_FLAG))
      echo -e "${YELLOW}file2 perm = $( [[ $FILE2_PERM_FLAG -eq 0 ]] && echo ON || echo OFF )${NC}"
      ;;
    "--outfile")
      OUTFILE_FLAG=$((1 - OUTFILE_FLAG))
      echo -e "${YELLOW}outfile existing = $( [[ $OUTFILE_FLAG -eq 0 ]] && echo ON || echo OFF )${NC}"
      ;;
    "--outfile-perm")
      OUTFILE_PERM_FLAG=$((1 - OUTFILE_PERM_FLAG))
      echo -e "${YELLOW}outfile perm = $( [[ $OUTFILE_PERM_FLAG -eq 0 ]] && echo ON || echo OFF )${NC}"
      ;;
      # after 
    "--add-recipe")
      if [[ ${#ARGS[@]} -ne 0 ]]; then 
        echo -n 'recipes ' >> recipes.sh
        for ARG in "${ARGS[@]}"; do
          printf '"%s" ' "$(echo "$ARG" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g' -e 's/`/\\`/g')" >> recipes.sh
        done
        echo >> recipes.sh
        echo -e "${YELLOW}${ARGS[@]}\nadded to recipes${NC}"
        echo
      else
        echo -n 'recipes ' >> recipes.sh
        for ARG in "${LAST_SEQ[@]}"; do
          printf '"%s" ' "$(echo "$ARG" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g' -e 's/`/\\`/g')" >> recipes.sh
        done
        echo >> recipes.sh
        echo -e "${YELLOW}${LAST_SEQ[@]}\nadded to recipes${NC}"
        echo
      fi
      ;;
      # add your custom cmd here
      #"--cmd")
      #<execution>
      #<execution>
      #;;
      # ...
      # DO NOT override following cases ! "" and * must be the lasts
      #
      # no input : if the buffer is not empty : the sequence is sent to taster.sh
      # if the buffer is empy : print a helper
    "")
      if [[ ${#ARGS[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No inputs recorded"
        echo ""
        echo "use -h or --help for usage informations${NC}"
        print_flags
      else
        set_flags
        timeout "${TIMEOUT_DURATION}s" ./taster.sh "${FLAGS[@]}" "${ARGS[@]}" 2> /dev/null
        if [[ $? -eq 124 ]]; then
          echo -e "${RED}TIME OUT !${NC}"
        fi
        LAST_SEQ=("${ARGS[@]}")
        ARGS=()
      fi
      ;;
      # Any other inputs will be considered as an input to add to the sequence to test
    *)
      ARGS+=("$INPUT")
      ;;
  esac
  echo -en "${YELLOW}[Muffinette]\$ ${NC}"
done

