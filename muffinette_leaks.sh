#!bin/bash

valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --show-mismatched-frees=yes --track-fds=yes --trace-children=yes ./minishell << EOF 2>&1 | tee log/valgrind_output | grep -v "$PROMPT_TO_CLEAN" > /dev/null
$INPUT
EOF

if ! grep -q "LEAK SUMMARY" log/valgrind_output; then
  echo -e "${GREEN}NO LEAKS${NC}"
else
  echo -e "${RED}LEAKS !${NC} : \e]8;;file://$(pwd)/log/valgrind_output\alog/valgrind_output\e]8;;\a"
fi

if [[ ! $(grep -v "ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)" log/valgrind_output | grep -q "ERROR SUMMARY: ") ]]; then
  echo -e "${GREEN}NO ERRORS${NC}"
else
  echo -e "${RED}ERRORS !${NC} : \e]8;;file://$(pwd)/log/valgrind_output\alog/valgrind_output\e]8;;\a"
fi

if [[ ! $(grep -q "ERROR: Some processes were left running at exit." log/valgrind_output) ]]; then
  echo -e "${GREEN}NO ZOMBIE PROCESS${NC}"
else
  echo -e "${RED}ZOMBIE PROCESS !${NC} : \e]8;;file://$(pwd)/log/valgrind_output\alog/valgrind_output\e]8;;\a"
fi

if [[ ! $(grep -v "FILE DESCRIPTORS: 3 open (3 std) at exit." log/valgrind_output | grep -q "FILES DESCRIPTORS") ]]; then
  echo -e "${GREEN}FD CLOSED${NC}"
else
  echo -e "${RED}FD OPEN AT EXIT !${NC} : \e]8;;file://$(pwd)/log/valgrind_output\alog/valgrind_output\e]8;;\a"
fi

