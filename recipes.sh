#!/bin/bash

mkdir -p log

#each argument is an input, use double quotes to delimate it
./tastor.sh "pwd" "cd" "pwd"

#so make sure to gather arguments
./tastor.sh "ls -l" "cd .." "ls -l"

#test pipe as an argument 
./tastor.sh "ls -l | wc -l" "pwd"

#or even a redirection, but dont forget the flag as first argument !
./tastor.sh "-r" "echo '180g milk' > log/outfile" 

#always put the --leaks as flag first !
./tastor.sh "--leaks" "-ra" "echo '5g vanilla' >> log/outfile"

#to test quotes, use \" or ' or \' ... 
./tastor.sh "echo \"two eggs\"" "echo '100g sugar'" 

#test by yourself !
# ./tastor.sh "your" "own"
# ./tastor.sh "t" "e" "s" "t" "S"

