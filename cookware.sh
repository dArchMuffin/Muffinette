#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"
CYAN='\033[0;36m'

# This script contains all functions i need elsewhere 

# this function runs the taster with the tests listed in recipes 
recipes()
{
  FILTERED_ARGS=()

# Filtered args is only for display purpose : showing --leaks -r makes output difficult to read
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


  KO=0

# tester si les flags sont bien pris en compte 
  OUTPUT=$(timeout "${TIMEOUT_DURATION}s" ./taster.sh "$@") 
  if [[ $? -eq 124 ]]; then
    echo -e "${FILTERED_ARGS[@]} : ${RED}TIME OUT !${NC}"
    KO=1
  fi
  TASTOR=$(echo -e "$OUTPUT" | sed 's/\x1B\[[0-9;]*m//g')

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

# a user cheatshit for CLI commands 
print_help() {
  echo -e "${YELLOW}╔════════════════════════════════ Muffinette Help ═════════════════════════════╗
║                                                                              ║
║  ${CYAN}Basic Usage:${YELLOW}                                                                ║
║    • Enter commands to build a test sequence                                 ║
║    • Press [Enter] with empty input to execute the sequence                  ║
║    • Use ${CYAN}!${YELLOW} to recall last sequence, ${CYAN}!!${YELLOW} to recall and execute it              ║
║                                                                              ║
║  ${CYAN}Quick Actions:${YELLOW}                                                              ║
║    ${CYAN}!${YELLOW}        - Recall last sequence (display only)                            ║
║    ${CYAN}!!${YELLOW}       - Recall and execute last sequence                               ║
║    ${CYAN}!v${YELLOW}       - Recall and execute last sequence with valgrind                 ║
║    ${CYAN}!>${YELLOW}       - Recall and execute last sequence with redirection test         ║
║    ${CYAN}-o/--oops${YELLOW} - Remove last input from current sequence                       ║
║                                                                              ║
║  ${CYAN}Session Control:${YELLOW}                                                            ║
║    ${CYAN}bye/quit/exit${YELLOW} - Exit Muffinette and clean up                              ║
║    ${CYAN}--bash${YELLOW}        - Open new terminal with bash                               ║
║    ${CYAN}--minishell${YELLOW}   - Open new terminal with minishell                          ║
║    ${CYAN}--spatule${YELLOW}     - Open side-by-side bash and minishell terminals            ║
║                                                                              ║
║  ${CYAN}Flag Management:${YELLOW}                                                            ║
║    ${CYAN}--valgrind/-vg${YELLOW}      - Toggle valgrind check                               ║
║    ${CYAN}->${YELLOW}                  - Toggle redirection test                             ║
║    ${CYAN}--infile${YELLOW}            - Toggle infile existence                             ║
║    ${CYAN}--infile-perm${YELLOW}       - Toggle infile permissions                           ║
║    ${CYAN}--file1${YELLOW}             - Toggle file1 existence                              ║
║    ${CYAN}--file1-perm${YELLOW}        - Toggle file1 permissions                            ║
║    ${CYAN}--file2${YELLOW}             - Toggle file2 existence                              ║
║    ${CYAN}--file2-perm${YELLOW}        - Toggle file2 permissions                            ║
║    ${CYAN}--outfile${YELLOW}           - Toggle outfile existence                            ║
║    ${CYAN}--outfile-perm${YELLOW}      - Toggle outfile permissions                          ║
║    ${CYAN}-pf/--print=flags${YELLOW}   - Display current flag status                         ║
║                                                                              ║
║  ${CYAN}Print Options:${YELLOW}                                                              ║
║    ${CYAN}--print=stdout${YELLOW}     - Display stdout log                                   ║
║    ${CYAN}--print=stderr${YELLOW}     - Display stderr log                                   ║
║    ${CYAN}--print=valgrind${YELLOW}   - Display valgrind output                              ║
║    ${CYAN}--print=outfile${YELLOW}    - Display outfile contents                             ║
║    ${CYAN}-ps/--print=seq${YELLOW}    - Display current sequence                             ║
║    ${CYAN}-pls/--print=last-seq${YELLOW} - Display last executed sequence                    ║
║                                                                              ║
║  ${CYAN}Advanced Features:${YELLOW}                                                          ║
║    ${CYAN}--recipes${YELLOW}       - Run custom tests from recipes.sh                        ║
║    ${CYAN}--add-recipe${YELLOW}    - Add current/last sequence to recipes.sh                 ║
║                                                                              ║
║  ${CYAN}Note:${YELLOW} Any other input will be added to the test sequence                    ║
╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# --print=stdout output 
print_stdout()
{
  echo -e "$YELLOW"
    echo "Bash STDOUT";
    echo "";
    cat log/bash_output;
    echo "";
    echo "------";
    echo "";
    echo "Minishell STDOUT";
    echo "";
    cat log/minishell_output;
    echo "";
    echo "Diff :";
    diff log/minishell_output log/bash_output
    echo -e "$NC"
}

# --print=stderr output 
print_stderr()
{
  echo -e "$YELLOW"
    echo "Bash STDERR";
    echo "";
    cat log/bash_stderr;
    echo "";
    echo "------";
    echo "";
    echo "Minishell STDERR";
    echo "";
    cat log/minishell_stderr;
    echo "";
    echo "Diff :";
    diff log/minishell_stderr log/bash_stderr
    echo -e "$NC"
}

# formate flags into arguments readable by taster.sh
set_flags()
{
  FLAGS=()
  if [[ $VALGRIND_FLAG == 1 ]]; then
    FLAGS+=("--leaks")
  fi
  if [[ $R_FLAG == 1 ]]; then
    FLAGS+=("-r")
  fi
  if [[ $AUTO_SAVE_FLAG == 1 ]]; then
    FLAGS+=("-as")
  fi
  if [[ $INFILE_FLAG == 1 ]]; then
    FLAGS+=("--infile=off")
  fi
  if [[ $INFILE_PERM_FLAG == 1 ]]; then
    FLAGS+=("--infile=000")
  fi
  if [[ $FILE1_FLAG == 1 ]]; then
    FLAGS+=("--file1=off")
  fi
  if [[ $FILE1_PERM_FLAG == 1 ]]; then
    FLAGS+=("--file1=000")
  fi
  if [[ $FILE2_FLAG == 1 ]]; then
    FLAGS+=("--file2=off")
  fi
  if [[ $FILE2_PERM_FLAG == 1 ]]; then
    FLAGS+=("--file2=000")
  fi
  if [[ $OUTFILE_FLAG == 1 ]]; then
    FLAGS+=("--outfile=off")
  fi
  if [[ $OUTFILE_PERM_FLAG == 1 ]]; then
    FLAGS+=("--outfile=000")
  fi
}

# so much flags, it needed a helper to not loose track of your tests
print_flags()
{
  echo -e "$YELLOW"
  if [[ $VALGRIND_FLAG == 1 ]]; then
    echo -e "valgrind           : ON"
  else
    echo -e "valgrind           : OFF"
  fi
  if [[ $R_FLAG == 1 ]]; then
    echo -e "redirection test   : ON"
  else
    echo -e "redirection test   : OFF"
  fi
  if [[ $AUTO_SAVE_FLAG == 1 ]]; then
    echo -e "auto-save          : ON"
  else
    echo -e "auto-save          : OFF"
  fi
  echo
  if [[ $INFILE_FLAG == 1 ]]; then
    echo -e "infile             : does not exist"
  else
    echo -e "infile             : exists"
  fi
  if [[ $INFILE_PERM_FLAG == 1 ]]; then
    echo -e "infile             : chmod 000"
  else
    echo -e "infile             : chmod 644"
  fi
  echo
  if [[ $FILE1_FLAG == 1 ]]; then
    echo -e "file1              : does not exist"
  else
    echo -e "file1              : exists"
  fi
  if [[ $FILE1_PERM_FLAG == 1 ]]; then
    echo -e "file1              : chmod 000"
  else
    echo -e "file1              : chmod 644"
  fi
  echo
  if [[ $FILE2_FLAG == 1 ]]; then
    echo -e "file2              : does not exist"
  else
    echo -e "file2              : exists"
  fi
  if [[ $FILE2_PERM_FLAG == 1 ]]; then
    echo -e "file2              : chmod 000"
  else
    echo -e "file2              : chmod 644"
  fi
  echo
  if [[ $OUTFILE_FLAG == 1 ]]; then
    echo -e "outfile            : does not exist"
  else
    echo -e "outfile            : exists"
  fi
  if [[ $OUTFILE_PERM_FLAG == 1 ]]; then
    echo -e "outfile            : chmod 000"
  else
    echo -e "outfile            : chmod 644"
  fi
  echo -e "$NC"
}

# experimental : open terminals with bash and / or minishell to operate or see behaviors 
spatule()
{
  if [[ $1 == "bash" ]]; then
    kitty --detach bash -c "bash" &
  elif [[ $1 == "minishell" ]]; then
    kitty --detach bash -c "./minishell" &
  elif [[ $1 == "spatule" ]]; then
    kitty --detach bash -c "bash" &
    kitty --detach bash -c "./minishell" &
  fi
}

# a virer ? 
watch_logs() {
  case "$1" in
    "off") pgrep watch | tail -n +2 | xargs kill ;;
    "all")
      kitty --detach bash -c 'watch -n1 cat log/minishell_output'
      kitty --detach bash -c 'watch -n1 cat log/bash_output'
      kitty --detach bash -c 'watch -n1 cat log/minishell_stderr'
      kitty --detach bash -c 'watch -n1 cat log/bash_stderr'
      kitty --detach bash -c 'watch -n1 cat log/valgrind_output'
      kitty --detach bash -c 'watch -n1 cat log/outfile' ;;
    "stdout")
      kitty --detach bash -c 'watch -n1 cat log/minishell_output'
      kitty --detach bash -c 'watch -n1 cat log/bash_output' ;;
    "stderr")
      kitty --detach bash -c 'watch -n1 cat log/minishell_stderr'
      kitty --detach bash -c 'watch -n1 cat log/bash_stderr' ;;
    "valgrind")
      kitty --detach bash -c 'watch -n1 cat log/valgrind_output' ;;
    "outfile")
      kitty --detach bash -c 'watch -n1 cat log/outfile' ;;
  esac
}

