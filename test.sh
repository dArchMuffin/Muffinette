#!/bin/bash

# kitty --detach bash -c '


# TODO
# meilleur output pour muff.sh
# option pour flags persistants 

if [[ $1 == "--leaks" ]]; then
  FLAGS+=("$1");
  shift
fi

if [[ $1 == "-r" ]]; then
  FLAGS+=("$1");
  shift
fi

if [[ $1 == "-ra" ]]; then
  FLAGS+=("$1");
  shift
fi

echo -n "[Muffinette]$ "
while IFS= read -r INPUT; do
    if [[ "$INPUT" == "-h" ]] || [[ "$INPUT" == "--help" ]]; then
      echo "consult log files with :"
      echo "--log=stdout"
      echo "--log=stderr"
      echo "--log=valgrind"
      echo "run your recipes with : --recipes"
      echo "or just say \"bye\" to quit"
    elif [[ "$INPUT" == "bye" ]]; then
        break
    elif [[ "$INPUT" == "--show-log=stdout" ]]; then
      kitty --detach bash -c '
      echo "Bash STDOUT";
      echo "";
      cat log/bash_output;
      echo "";
      echo "------";
      echo "";
      echo "Minishell STDOUT";
      echo "";
      cat log/minishell_output;
      read'
    elif [[ "$INPUT" == "--show-log=stderr" ]]; then
      kitty --detach bash -c '
      echo "Bash STDERR";
      echo "";
      cat log/bash_stderr;
      echo "";
      echo "------";
      echo "";
      echo "Minishell STDERR";
      echo "";
      cat log/minishell_stderr;
      read'
    elif [[ "$INPUT" == "--show-log=valgrind" ]]; then
      kitty --detach bash -c '
      cat log/valgrind_output;
      read'
    elif [[ "$INPUT" == "--recipes" ]]; then
      kitty --detach bash -c '
      ./muff.sh;
      read'
    elif [[ "$INPUT" == "" ]]; then
        ./muffinette.sh "${ARGS[@]}"
        ARGS=("${FLAGS[@]}") 
        echo ""
    else
        ARGS+=("$INPUT") 
    fi
    echo -n "[Muffinette]$ "
done
#
#

# while true; do
#   ARGS=()
#     echo -n "[Muffinette]$ "
#     IFS= read -r INPUT
#     if [[ "$INPUT" == "-h" ]] || [[ "$INPUT" == "--help" ]]; then
#       echo "just say bye to quit"
#     elif [[ "$INPUT" == "bye" ]]; then
#         break
#     elif [[ "$INPUT" == "" ]]; then
#         ./muffinette.sh "${ARGS[@]}"
#         ARGS=()  # Réinitialise les arguments
#     else
#         ARGS+=("$INPUT")  # Ajoute chaque ligne comme un argument
#     fi
# done

