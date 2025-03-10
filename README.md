# Muffinette - A Minishell MiniTester

Muffinette is a Bash script designed to test your `minishell` project by comparing its output and behavior to that of the standard `bash` shell. It helps you identify differences in standard output (STDOUT), standard error (STDERR), exit codes, redirections.
Additionaly it runs a valgrind check while executing your 'minishell'.

---

## Features

- **STDOUT Comparison**: Compares the standard output of `minishell` and `bash`.
- **STDERR Comparison**: Compares the standard error of `minishell` and `bash`.
- **Exit Code Comparison**: Verifies if the exit codes of `minishell` and `bash` match.
- **Redirection Testing**: Supports only output redirection testing for the moment.
- **Memory Leak Detection**: Optionally checks for memory leaks using `valgrind`.
- **Cleanup**: Automatically cleans up log files after successful tests.

---

## Usage

### Basic Usage
1. Place your `minishell` binary in the same directory as `muffinette.sh`.
2. Your minishell probably prints its prompt and user input on stdout, bash don't. 
To filter it and compare outputs, edit the first line of muffinette.sh, preserving the "^" character:
   ```bash
   PROMPT_TO_CLEAN=\"^<your-minishell-prompt>\""
    ```
3. Run the script with commands to test:
   ```bash
   ./muffinette.sh <command1> <command2> ...
   ```
Example :
  ```bash
  ./muffinette.sh ls "cd .." "pwd" "ls -l | wc -l" "echo 42 > log/outfile" 
  ```
### Flags
- --clean: cleans up log files.
- --leaks: check fds, zombie process and leaks.
- -r and -ra: check redirections > >> 
  ```bash
  ./muffinette.sh --leaks -ra "<command1>" "<command2> >> log/outfile"
  ```

### Output
- STDOUT: Displays OK if the outputs match, otherwise KO with a diff.
- STDERR: Displays OK if the errors match, otherwise KO with a diff.
- EXIT: Displays OK if the exit codes match, otherwise KO with the codes.
- Memory Leaks: If enabled, displays valgrind output for memory leak detection.
```bash
----------| Muffinette |----------

STDOUT : OK
STDERR : OK
EXIT : OK
REDIR > : OK
LEAKS ! : log/valgrind_output
NO ERRORS
NO ZOMBIE PROCESS
FD CLOSED
```
### Logs
If all tests are succeed, the log folder will be automaticaly cleaned. Othwerwise, you can consult outputs produced by the last test in the log folder.
Use `./muffinette --clean` to remove it.

### Notes
- Ensure your minishell binary is named minishell and is in the same directory as muffinette.sh.
- For commands like export and env, outputs may differ due to environment variable handling.
- Manual testing is required for advanced features like here-docs and quote management.

### Contribution
Feel free to contribute to Muffinette by submitting pull requests or creating issues.
