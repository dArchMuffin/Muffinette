#!/bin/bash

print_help()
{
  echo -e "$YELLOW"
  echo "╔═══════════════════════════════════════════════════════════════════╗"
  echo "║                         Muffinette Usage                          ║"
  echo "╠═══════════════════════════════════════════════════════════════════╣"
  echo "║ Each line you type composes the inputs sequence                   ║"
  echo "║ Just send an empty prompt to run the sequence                     ║"
  echo "║                                                                   ║"
  echo "║ Flags : (switches ON/OFF)                                         ║"
  echo "║ --valgrind         : Run a full valgrind test                     ║"
  echo "║ -- >             : Test redirection out                           ║"
  echo "║ -- >>            : Test redirection out with append               ║"
  echo "║ --print=flags   : Display flags status                            ║"
  echo "║                                                                   ║"
  echo "║ Display infos:                                                    ║"
  echo "║ --print=seq     : Print the inputs sequence in memory             ║"
  echo "║ --print=stdout  : Show minishell & bash stdout logs               ║"
  echo "║ --print=stderr  : Show minishell & bash stderr logs               ║"
  echo "║ --print=valgrind: Show valgrind logs                              ║"
  echo "║ --watch=stdout  : Open 2 terminals watching stdout logs           ║"
  echo "║ --watch=stderr  : Open 2 terminals watching stderr logs           ║"
  echo "║ --watch=valgrind: Open a terminal watching valgrind logs          ║"
  echo "║                                                                   ║"
  echo "║ Other Commands:                                                   ║"
  echo "║ --oops          : Remove last input from sequence in memory       ║"
  echo "║ --recipes       : Run recipes.sh                                  ║"
  echo "║                                                                   ║"
  echo "║ Or just type \"bye\" to quit                                        ║"
  echo "╚═══════════════════════════════════════════════════════════════════╝"
  echo -e "$NC"
}

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

