# 🧁 Muffinette - A MiniTester for a MiniShell 

Muffinette is a set of Bash scripts written by following the side quests of 42 cursus inviting to understand and use bash syntax and commands.

Muffinette is designed to test your `minishell` project by sending sequences of inputs and comparing its output and behavior to that of the standard `bash` shell. It helps you identify differences in standard output (STDOUT), standard error (STDERR), exit codes, redirections...
Additionaly it runs a valgrind check while executing your 'minishell'.

My scripts are meant to be user-friendly. You will find in muffinette.sh and muff.sh some comments to help you to cook by yourself, and may be improve the muffinette by editing it yourself.

The muff.sh script is a blueprint for your tests : it automates the process of running several muffinette.sh and show examples of tricky tests for special features.

---

## Features 🍷

- **STDOUT Comparison**: Compares the standard output of `minishell` and `bash`.
- **STDERR Comparison**: Compares the standard error of `minishell` and `bash`.
- **Exit Code Comparison**: Verifies if the exit codes of `minishell` and `bash` match.
- **Redirection Testing**: Supports only output redirection testing for the moment.
- **Quotes Management**: using \\" or ' to test quotes, but some tests might be done manualy.
- **Memory Leak Detection**: Optionally checks for memory leaks using `valgrind`.
- **Cleanup**: Automatically cleans up log files after successful tests.
  
Working on :

- **STDIN redirections**
- **here_doc**
- **variable expansion**
- **env and export specific behavior**
- **User custom log file** 

---
## Configuration : set the table 🍽 
First, copy your minishell binary in this repo.

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
### Clean your prompt 🧼✋ _"The first step in any recipe is to first wash your hands."_ 

So, in order to compare outputs, we need to clean your minishell output using grep -v "^" (-v suppresses lines matching with the pattern in arg, ^ seeks only the lines beginning with the pattern in arg).

Execute your minishell with here_doc as described, copy and paste the prompt line in the muffinette.sh PROMPT_TO_CLEAN variable, preserving the ^ character.

If you use characters that the shell would interpret, use \ before : 
```bash
PROMPT_TO_CLEAN="^\[Minishell\]\$"
```

Now, we are ready to cook !

---

### _"One is never better served than by oneself"_ 😋

You will find arround a lot of lines to comment, uncomment or to tweak yourself to lead the tests as you want (permissions on infile / outfile, testing non existing files ...)

If you are ready to get your hands dirty, I hope my scripts are commented enough for you to understand how it works. 

Please, share you improvements with us ! 

## 👩‍🍳 Usage 🧑‍🍳 

### Basic usage 🥄

muffinette.sh is desgined first for quick tests such as :
```bash
./muffinette.sh pwd "cd .." pwd "cd .." pwd
```
```bash
----------| Muffinette |----------

^\[Minishell\]$ pwd
^\[Minishell\]$ cd ..
^\[Minishell\]$ pwd
^\[Minishell\]$ cd ..
^\[Minishell\]$ pwd

STDOUT : OK
STDERR : OK
EXIT : OK
```
Note : If you want a shorter output, just comment lines displaying fancy stuff in muffinette.sh. 

Without flags, it will send a sequence of 5 inputs in your minishell and bash, and compare STDOUT, STDERR and the exit code.

Using flags, you can extend the tests :

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
Use --clean will remove log folder. If the last test succeeded, the log folder will be automaticaly removed.
You can comment the last lines of muffinette.sh if you prefer to keep log foler even if tests succeeded.
```bash
./muffinette.sh --clean
```
Always use --leaks flag first over -r or -ra
```bash
./muffinette --leaks -r "echo 'muffin' > log/outfile"
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
  ./muffinette.sh -leaks -r ls "cd .." "pwd" "ls -l | wc -l" "echo '42' > log/outfile" 
  ```
### muff.sh 🥗

In order to automate series of tests, use muff.sh and test by yourself !
You will probably want to tweak muffinette.sh output to keep tracks of what you test.
I'm working on a better log output of muff.sh

---

### Logs 📜
If all tests are succeed, the log folder will be automaticaly cleaned. 

In case of a failed test, you can consult outputs produced by the last test in the log folder.

You can comment last lines of muffinette.sh to disable autoclean of log folder.

Use `./muffinette --clean` or `rm -rd log` to remove it manualy.

In the log folder you will find these files from the very last test executed : 

- bash_output : STDOUT of bash
- minishell_output : STDOUT of minishell
- bash_stderr : STDERR of bash
- minishell_stderr : STDERR of minishell
- infile / outfile : files used for redirection tests

---

## Contribution 🍻 _"Everything tastes better when we cook together"_
Feel free to contribute to Muffinette by submitting pull requests or creating issues.
