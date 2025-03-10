#!/bin/bash

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

if [[ $ERROR_MISSING == 0 ]] ; then
  echo -e "STDERR : ${GREEN}OK${NC}"
else
  echo -e "STDERR : ${RED}KO${NC} : diff log/bash_stderr log/minishell_stderr"
  CLEAN=1
fi

