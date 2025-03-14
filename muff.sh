#!/bin/bash

mkdir -p log

#each argument is an input, use double quotes to delimate it
./muffinette.sh "pwd" "cd" "pwd"

#so make sure to gather arguments
./muffinette.sh "ls -l" "cd .." "ls -l"

#test pipe as an argument 
./muffinette.sh "ls -l | wc -l" "pwd"

#or even a redirection, but dont forget the flag as first argument !
./muffinette.sh "-r" "echo '180g milk' > log/outfile" 

#always put the --leaks as flag first !
./muffinette.sh "--leaks" "-ra" "echo '5g vanilla' >> log/outfile"

#to test quotes, use \" or ' or \' ... 
./muffinette.sh "echo \"two eggs\"" "echo '100g sugar'" 

#test by yourself !
# ./muffinette.sh "your" "own"
# ./muffinette.sh "t" "e" "s" "t" "S"

