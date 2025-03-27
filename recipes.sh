
#!/bin/bash

mkdir -p log

source cookware.sh

TIMEOUT_DURATION="${TIMEOUT_DURATION:-5}"

recipes "pwd" "cd" "pwd"

#so make sure to gather arguments
recipes "ls -l" "cd .." "ls -l"

#test pipe as an argument 
recipes "ls -l | wc -l" "pwd"

#or even a redirection, but dont forget the flag as first argument !
recipes "-r" "echo -e '180g milk' > log/outfile" 

#always put the --leaks as flag first !
recipes "--leaks" "-r" "echo -e '5g vanilla' >> log/outfile"

#to use quotes, use \" or ' or \' ... 
recipes "echo -e \"two eggs\"" "echo -e '100g sugar'" 

#test by yourself !
# recipes "your" "own"
# recipes "t" "e" "s" "t" "S"

#each argument is an input, use double quotes to delimate it

recipes "pwd" "cd" "ls" 
recipes "echo \"hello\"" 
recipes "echo \"hello\"" "ls -l" "cd .." "pwd" 
recipes "--leaks" "ls -l" "pwd" "cd .." "pwd" "cd " 
recipes "pwd" "cd .." "ls" "echo \"hello\"" "ls | wc -l" 
recipes "sleep 6" 
