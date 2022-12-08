# Example GAS Programs
## By: Derek Tan / DrkWithT at GitHub

### Requirements:
 - Editor: any one that works on Unix / Unix-like systems!
 - VCS: Git
 - System: Linux distro, MacOS, BSD variant, etc.

### Summary:
This repo contains sample programs written in GNU Assembly. The list below gives brief information on the code and its usage. Here, I assume that the reader is new to using GNU `make` with GNU assembly code.

### Programs:
 1. `test1.s`: Tells whether a hardcoded 32-bit integer is greater than 10 or not.
 2. `write_hex.s`: Prints a hardcoded _word_ value in hex representation.
 3. `dec_to_hex.s`: Gets a 4 digit decimal number and then prints the hex representation.

### Assembling:
 - The command to build a _single, one file_ program is `make ./bin/<source file name>.out`.
 - The command to clear out old executables is `make clean`.
