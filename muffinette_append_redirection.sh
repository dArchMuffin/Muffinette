#!/bin/bash

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
else
  echo -e "REDIR >> : ${GREEN}OK${NC}"
fi
