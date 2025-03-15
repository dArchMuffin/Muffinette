# 🧁 Muffinette - A MiniTester for a MiniShell 

Muffinette is a set of Bash scripts I created during my 42 cursus, applying the Bash fundamentals I learned through the 42 projects, in a Test-Driven Development (TDD) approach before starting minishell project. 

Muffinette is a test engine for your minishell project. By comparing its output and behavior to the standard Bash shell, it helps to identify differences in STDOUT, STDERR, exit codes, redirections, and more. It also runs a Valgrind check during execution.

The scripts are designed to be user-friendly. You can use it as config files, comments in muffinette.sh and muff.sh will guide you to cook by yourself, leading and creating your own tests. 

---

## Features 🍽

#### Default :
- **STDOUT Comparison**: Compares the standard output of `minishell` and `bash`.
- **STDERR Comparison**: Compares the standard error of `minishell` and `bash`.
- **Exit Code Comparison**: Verifies if the exit codes of `minishell` and `bash` match.
- **Cleanup**: Automatically cleans up log files after successful tests.
  
#### With options :
- **Redirection Testing**: Supports only output redirection testing for the moment.
- **Memory Leak Detection**: Optionally checks for memory leaks using `valgrind`.

---

## 👩‍🍳 Usage 🧑‍🍳 

First, copy your minishell binary in this repo.

### Basic usage 🥄

muffinette.sh is desgined first for quick tests such as :
```bash
./muffinette.sh pwd "cd .." pwd "cd .." pwd
```
```bash
----------| Muffinette |----------

[Minishell]$ pwd
[Minishell]$ cd ..
[Minishell]$ pwd
[Minishell]$ cd ..
[Minishell]$ pwd
[Minishell]$ cd ..
[Minishell]$ pwd

STDOUT : OK
STDERR : OK
EXIT : OK
```
It will send a sequence of 5 inputs in both your minishell and bash, and compare STDOUT, STDERR and the exit code.
The output of your minishell is redirected in file to compare with bash output
If you disable autoclean option, and cat log/minishell_output, you could find this output :
```bash
/home/muffin/Muffinette
/home/muffin
/home
/
```

### Flags 🍴
Add a valgrind test seeking definitely losts, errors, zombie process and fd opened at exit.

```bash
./muffinette.sh --leaks pwd
```
Use the -r / -ra flag to include the redirection. Use log/outfile for convinience : it will be automaticaly cleaned if the tests succeed.
And you can easily tweak his permission or existence commenting some lines in the muffinette.sh script.
```bash
./muffinette.sh -r "ls -l > log/outfile"
./muffinette.sh -ra "ls -l >> log/outfile"
```
Always use --leaks flag first over -r or -ra
```bash
./muffinette --leaks -r "echo 'muffin' > log/outfile"
```
Use --clean will remove log folder. If the last test succeeded, the log folder will be automaticaly removed.
You can comment the last lines of muffinette.sh if you prefer to keep log foler even if tests succeeded.
```bash
./muffinette.sh --clean
```
### Special features testing 🔪 

use \\" and or ' to test quote management :
```bash
./muffinette.sh "echo \"muffin\"" "echo 'man'"
```

Don't forget to use | quoted with the commands piped :
```bash
./muffinette.sh "echo 'muffin' | wc -l"
```

Same for arguments of a command, it must be quoted with :
```bash
./muffinette "ls -l"
```

Example :
  ```bash
  ./muffinette.sh --leaks -r ls "cd .." "pwd" "ls -l | wc -l" "echo '42' > log/outfile" 
  ```
### muff.sh 🥗

In order to automate series of tests, use muff.sh and test by yourself !
You will probably want to tweak muffinette.sh output to keep tracks of what you test.
I'm working on a better log output of muff.sh

#### _"One is never better served than by oneself"_ 😋

You will find arround lines to comment, uncomment or to tweak yourself to lead the tests as you want (permissions on infile / outfile, testing non existing files ...)

If you are ready to get your hands dirty, I hope my scripts are commented enough for you to understand how it works. 

Please, share you improvements with us ! 

---

## Troubleshooting 
Normally, muffinette should automaticaly extract from minishell output the prompt and the command sent.
If STDOUT test always fail, you might need to manualy clean your minishell prompt.
Edit your code to stick to bash prompt, or edit the muffinette.sh variable PROMPT as follow :

By running your minishell in a here_doc, you will see that its output differs of the bash one because of minishell printing in the STDOUT its output and the user input : 
```bash
./minishell << EOF
pwd
EOF
```
```bash
[Minishell]$ pwd
/home/muffin/Muffinette
[Minishell]$ exit
```
Bash only prints the outputs of its inputs :
```bash
bash << EOF
pwd
EOF
```
```bash
/home/muffin/Muffinette
```
So, in order to compare outputs, we need to clean your minishell output.

Execute your minishell with here_doc as described, copy and paste the prompt line in the muffinette.sh PROMPT_TO_CLEAN variable, preserving the ^ character.

If you use characters that the shell would interpret, use \ before : 
```bash
PROMPT="^\[Minishell\]\$"
```

---

### Logs 📜
If all tests are succeed, the log folder will be automaticaly cleaned. 

In case of a failed test, you can consult outputs produced by the last test in the log folder.

You can comment last lines of muffinette.sh to disable autoclean of log folder.

Use `./muffinette --clean` or `rm -rd log` to remove it manualy.

---

## Contribution 🍻 _"Everything tastes better when we cook together"_
Feel free to contribute to Muffinette by submitting pull requests or creating issues.
