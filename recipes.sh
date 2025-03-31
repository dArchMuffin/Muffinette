
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

# You can either add your own tests here manualy, or you can use the --add-recipe command, 
# the sequence in buffer will be added after this linesm ready to run with ./recipes.sh or --recipes in CLI. 

# I highly recommend to keep this file clean and organized by sorting tests in categories here 
# Comments are your friends !
