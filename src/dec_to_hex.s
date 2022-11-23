# dec_to_hex.s
# Gets a 4 digit decimal number and then prints the hex representation.
# By: Derek Tan

.text
### PROCEDURES ###

# PROCEDURE checkInput
# Checks if /[0-9]+/ is satisfied in the user's input.
# Params: %rdi is buf_ptr.
# Uses: %rbx for lower ASCII limit (48), %rcx for upper ASCII limit (57), %r12 for buf_term (buf_ptr + 4), %r13 for curr_char.
# Returns: %rax is 0 if input was valid, and 1 on invalid input.
.global checkInput
checkInput:
  # preserve registers
  push %rbx
  push %rcx
  push %r12
  push %r13

  # init local vars
  mov $48, %rbx    # low = 48
  mov $57, %rcx    # high = 57

  mov %rdi, %r12
  add $4, %r12     # buf_term = buf_ptr + 4
  
  mov $0, %r13     # c = 0

  mov $0, %rax     # ok = 0

StartCheck:
  # WHILE (buf_ptr != buf_term)
  cmp %rdi, %r12
  je EndCheck

  # load curr_char with zero padding
  movb (%rdi), %r13b

  # IF (curr_char >= low): ...
  cmp %rbx, %r13
  jae SkipBad

  # IF (curr_char <= high): ...
  cmp %rcx, %r13
  jbe SkipBad

# ELSE: // Break on a non-digit ASCII char!
  mov $1, %rax
  jmp EndCheck

SkipBad:
  # update loop vars
  inc %rdi        # buf_ptr++
  mov $0, %r13    # curr_char = 0
  jmp StartCheck

EndCheck:
  # restore registers
  push %r13
  push %r12
  push %rcx
  push %rbx
  ret

# PROCEDURE decodeDec4
# Parses a 4 digit string as a unsigned decimal integer.
# Params: %rdi is buf_ptr. (right to left by digits!).
# Uses: %rbx for buf_end, %rcx for base ($10), %r12 for tem_val, %r13 for temp_char
# Returns: %rax is 0 on error, but above 0 on success. 
.global decodeDec4
decodeDec4:
  # todo
  mov $0, %rax
  ret

# PROCEDURE writeHex4
# Writes the hex representation of the resulting decimal integer from Proc. decodeDec4.
# Params: %rdi is dst_buf. %rsi is the decimal number.
# Uses: %rbx for buf_end, %rcx for shifts, %r12 for mask, %r13 for curr_val (raw_digit_value), %r14 for constant $10.
# Returns: %rax is 0 on success, but 1 on error.
.global writeHex4
writeHex4:
  # todo
  mov $0, %rax
  ret

.global main
main:
# prompt for 4 input digits
  mov $1, %rax          # syscall write
  mov $1, %rdi          # use stdout
  mov $prompt_msg, %rsi
  mov $prompt_len, %rdx

  mov $0, %rax          # syscall read
  mov $0, %rdi          # use stdin
  mov $input_buf, %rsi
  mov $input_c, %rdx

# validate input
  mov $input_buf, %rdi
  call checkInput

  cmpl $1, %rax    # IF (checkInput(input_buf) != 1): // do conversion if input is valid
  je IfOops
  jmp IfOkay

IfOkay:
  # convert if input is valid
  # TODO: Use decodeDec4 and writeHex4!

# print input from its buffer
  mov $1, %rax              # syscall write
  mov $1, %rdi              # use stdout
  mov $output_buf, %rsi
  mov $output_write_c, %rdx

IfOops:

EndIfs:
  mov $0, %rax
  ret

.data
### Messages ###
prompt_msg:
  .ascii "Enter a 4 digit number:\n"

prompt_len:
  .long 24

oops_msg:
  .ascii "Invalid input.\n"

oops_len:
  .long 15

### Input Storage ###
input_buf:
  .ascii "\0\0\0\0"

input_c:
  .long 4

### Output Storage ###
output_buf:
  .ascii "0000\n\0"

output_write_c:
  .long 5
