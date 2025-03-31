# 🧁 Muffinette - A Minishell Taster

Muffinette is a suite of Bash scripts I’m developing using a Test-Driven Development (TDD) approach as part of my preparation for the 42 minishell project. 

It includes core features to streamline testing, along with advanced functionalities written to explore CLI possibilites and deepen my understanding of system programming and Bash scripting.

Muffinette is your personal kitchen assistant, entirely homegrown and homemade. I hope it will help you to whip up the perfect minishell recipe!

NOTE : I'm still working on Muffinette, don't blindly trust it and please let me know if you find any bugs or issues !

---
## Table of Contents
- [Features 🍽](#features)
- [Why Muffinette? 🤔](#why-muffinette)
- [🧑‍🍳 Usage 👩‍🍳](#usage)
  - [Quick Start 🍔](#quick-start)
  - [Basic Usage 🥄](#basic-usage)
- [CLI Commands 🍴](#cli-commands)
  - [Core commands 🔪](#core-commands)
  - [Flags commands 🧂](#flags-commands)
  - [Print commands 🧾](#print-commands)
- [Fancy usage 🍰](#fancy-usage)
- [Troubleshooting 🔧](#troubleshooting)
- [Contribution 🍻](#contribution)

<a id="features"></a>
## Features 🍽

Main Modules

- taster.sh: A testing engine for minishell designed to simplify and optimize the testing process.
- muffinette.sh: A mini-CLI for seamless interaction with taster.sh, minishell, and Bash, enabling users to customize their testing workflow.
- recipes.sh: An automation script for taster.sh. Define the tests your minishell must pass, add them to recipes.sh, and run it to verify if your minishell meets all requirements.

Utility Functions & Customization

- cookware.sh: A collection of utility functions. Customize the output of muffinette.sh here.

---

<a id="why-muffinette"></a>
## Why Muffinette? 🤔 
Testing a minishell can be as tedious as peeling a mountain of potatoes:
  - Opening multiple terminals.
  - Sending the same inputs to both minishell and Bash.
  - Manually comparing outputs and exit codes.

Muffinette simplifies this process:
  - Type your test inputs once.
  - Let Muffinette handle the rest—comparing STDOUT, STDERR, exit codes, and even redirections.
  - Optionally, run Valgrind checks to detect memory leaks and errors.

#### _"It's like having a food critic who also checks for hygiene!"_

The scripts are designed in a config file style when possible. Experienced Bash users will find in comments all the documentations and condiments needed to further refine, edit or build on Muffinette.

Whether you’re running predefined tests or experimenting your own, Muffinette provides the tools and guidance to make minishell testing efficient and painless. 

---

<a id="usage"></a>
## 👩‍🍳 Usage 🧑‍🍳 

<a id="quick-start"></a>
### Quick start 🍔
Clone the repos and copy minishell binary inside it.
``` bash
git clone https://github.com/dArchMuffin/Muffinette
cp /path/to/your/minishell/binary Muffinette/
cd Muffinette
``` 

Run the CLI with :
```bash
./muffinette.sh
```

Run the tester with all the tests registered in recipes.sh with :
```bash
./recipes.sh
```

To use taster.sh without his CLI, see the detailed usage in the **[former README](https://github.com/dArchMuffin/Muffinette/blob/5b1f324/README.md)** and run :

```bash
./taster.sh
```

<a id="basic-usage"></a>
### Basic usage 🥄

The CLI is designed first for quick tests. 

For a minimalist and straigthforward usage, let's say you want to see how your minishell handle the "cd .." command :
```bash
[Muffinette]$ pwd
[Muffinette]$ cd ..
[Muffinette]$ pwd
[Muffinette]$ cd ..
[Muffinette]$ pwd
[Muffinette]$ cd ..
[Muffinette]$ pwd
[Muffinette]$ cd ..
[Muffinette]$ pwd
[Muffinette]$ cd ..
[Muffinette]$ pwd
[Muffinette]$ cd ..
[Muffinette]$ 
STDOUT : OK
STDERR : OK
EXIT : OK
[Muffinette]$ !v
NO LEAKS
NO ERRORS
NO ZOMBIE PROCESS
FD CLOSED
STDOUT : OK
STDERR : OK
EXIT : OK
```
In this example, each line was successives command lines.

An empty prompt send the sequence to taster.sh and display the results : I ran 12 successives inputs to test.

Using the !v command, I ran again the last sequence of command lines, with a valgrind test in addition. I could enable persistantly valgrind check from beginning using --vg or --valgrind.

You can see the output of your minishell with a cat log/minishell_output in your shell, or using the --print=stoud CLI command.

If there is only few CLI commands you need, the --oops and the `!` `!!` `!v` `!>` CLI commands are the essentials.

After quick tests, you might want to centralize your tests to run them all at once :

`--add-recipe`

Add a sequence to recipes.sh. by default the sequence in buffer, or if empty, the last sequence sent to test. 

`[Muffinette]$ --recipes`

Runs recipes.sh with all registered tests.

You are now ready to test your minishel as you build it.

<a id="cli-commands"></a>
## CLI commands 🍴 

<a id="core-commands"></a>
### Core commands 🔪

`[Muffinette]$ bye`

Exit Muffinette.

`[Muffinette]$ --oops (or -o)`

Removes the last command entered in the sequence buffer. A step back when you accidentally added too much salt.

```bash
[Muffinette]$ pwd
[Muffinette]$ cd..
[Muffinette]$ --oops
removed : cd..
[Muffinette]$ --print=seq
pwd
```
`[Muffinette]$ !! `

Immediately run again last sequence with same options.

`[Muffinette]$ ! `

Override your current sequence in buffer with the last sequence used, without running it again immediately.

In case you want to extend the last sequence without retyping it.
```bash
[Muffinette]$ --print=seq or -ps


[Muffinette]$ !
pwd
cd ..
[Muffinette]$ --print=seq or -ps
pwd
cd ..
```
`[Muffinette]$ !> `

Runs the last sequence with an additional redirection test.

`[Muffinette]$ !v `

Runs the last sequence with an additional Valgrind memory check.

----

<a id="flags-commands"></a>
### Flag Management commands 🧂

`[Muffinette]$ --valgrind (or -vg)`

Toggles Valgrind memory check mode.
```bash
[Muffinette]$ --valgrind
valgrind_flag = ON
[Muffinette]$ --valgrind
valgrind_flag = OFF
```

`[Muffinette]$ - >`

Toggles redirection testing mode.

`[Muffinette]$ --file1`

Toggles creation of file1 for next tests : to test non-existing files

`[Muffinette]$ --file1-perm`

Toggles permissions on file1.

Since bash and minishell will use the same files for redirections, use log/infile log/outfile log/file1 /log/file2 as test files. Use this toggle withe these files names to enable or disable them.

log/file_without_permission is available but will always be chmod 000

<a id="print-commands"></a>
### Printing Logs and Sequences 🧾 

`[Muffinette]$ --print=stdout`

Displays the contents of stdout log.

Same for `--print=stderr`, `--print=outfile`, `--print=valgrind`.


`[Muffinette]$ --print=flags (or -pf)`

Displays the current state of test flags.

`[Muffinette]$ --print=seq (or -ps)`

Displays the sequence currently stored in the buffer.

`[Muffinette]$ --print=last-seq (or -pls)`

Displays the last executed sequence.

----

<a id="fancy-usage"></a>
## Fancy usage 🍰

If you don't trust the taster.sh, you can still overview by yourself all log files in real time : 

1. Make sure to have terminator and watch installed
2. copy the terminator config file provided in the repo in .config/terminator/config
3. run `./muffinette --muffinator` or `[Muffinette]$ --muffinator`

To operate or experiment with bash or minishell, `[Muffinette]$ --bash` or `[Muffinette]$ --minishell` Opens a new terminal with a bash or minishell directly from muffinette.

Use `bye` to exit Muffinette and kill all the terminals opened.

---

## _"One is never better served than by oneself"_ 😋

You will find arround lines to comment, uncomment or to tweak yourself to edit or build on Muffinette. I hope my scripts are clear enough for you to understand how it works. 

Please, share you improvements with us ! 

---
<a id="troubleshooting"></a>
## Troubleshooting  🔧
Since by default your minishell may not support non-interactive mode, it will print the prompt and input in its output.
Muffinette should automaticaly extract from minishell output the prompt and the command sent.
If STDOUT test always fail, you might need to manualy clean your minishell prompt.
Either make an interactive mode option, and disable the prompt display, or edit your code to stick to bash prompt, or edit the muffinette.sh variable PROMPT as follow :

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

Execute your minishell with here_doc as described, copy and paste the prompt line in the muffinette.sh PROMPT variable.

```bash
PROMPT="[Minishell]$"
```
---


<a id="contribution"></a>
## Contribution 🍻 _"Everything tastes better when we cook together"_
Feel free to contribute to Muffinette by submitting pull requests or creating issues.

