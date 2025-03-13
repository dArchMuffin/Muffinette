#!bin/bash

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

if [[ ! $(grep -v "FILE DESCRIPTORS: 3 open (3 std) at exit." log/valgrind_output | grep -q "FILES DESCRIPTORS") ]]; then
  echo -e "${GREEN}FD CLOSED${NC}"
else
  LEAKS=1
  echo -e "${RED}FD OPEN AT EXIT !${NC}"
fi

if [[ $LEAKS == 1 ]]; then
  echo -e "Full valgrind log : \e]8;;file://$(pwd)/log/valgrind_output\alog/valgrind_output\e]8;;\a"
fi
