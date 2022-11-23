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
  mov $48, %rbx    # low = 48 : '0'
  mov $57, %rcx    # high = 57 : '9'

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
# Uses: %rbx for buf_curr_ptr, %rcx for base ($10), %r12 for temp_val, %r13 for digit
# Returns: %rax is 0 on error, but above 0 on success. 
.global decodeDec4
decodeDec4:
  # preserve registers
  push %rbx
  push %rcx
  push %r12
  push %r13

  # init local vars
  mov %rdi, %rbx
  add $3, %rbx    # char *buf_curr_ptr = (buf_ptr + 3)  // char of lowest place value digit

  mov $10, %rcx   # uint base = 10
  mov $0, %r12    # uint temp_val = 0
  mov $0, %r13    # uchar digit = '\0'
  mov $0, %rax    # uint result = 0

  # begin 4-dec-digit parse
BeginToInt:
  # WHILE (buf_ptr != buf_term):
  cmp %rdi, %rbx
  je EndToInt

  # get current digit value
  mov $0, %r13
  movb (%rbx), %r13b    # digit = *buf_curr_ptr  // with zeroing
  subb $48, %r13b       # digit -= '0'

  # calculate partial result
  mul %rcx, %r13

  # update result
  add %r13, %rax        # result += digit * 10

  # update loop vars
  dec %rbx              # buf_curr_ptr--
  mul %rcx, %rcx        # base *= 10
  jmp BeginToInt

EndToInt:
  # restore registers
  pop %r13
  pop %r12
  pop %rcx
  pop %rbx

  ret

# PROCEDURE writeHex4
# Writes the hex representation of the resulting decimal integer from Proc. decodeDec4.
# Params: %rdi is dst_buf. %rsi is the decimal number.
# Uses: %rbx for buf_end, %rcx for shifts, %r12 for mask, %r13 for curr_val (raw_digit_value), %r14 for constant $10.
# Returns: %rax is 0 on success, but 1 on error.
.global writeHex4
writeHex4:
  # preserve regs
  push %rbx
  push %rcx
  push %r12
  push %r13
  push %r14

  # init end_ptr
  mov %rdi, %rbx
  add $4, %rbx  # end_ptr = ADDR (buf_ptr + 4)

  # init shifts
  mov $0, %rcx  # BZERO(shifts)
  mov $12, %cl  # shifts = 12

  # init mask
  mov $15, %r12
  shl %cl, %r12

  # init curr_val
  mov $0, %r13

  # init min_alpha
  mov $10, %r14

BeginLoop:  # WHILE (ADDR buf_ptr != ADDR end_ptr):
  cmp %rdi, %rbx
  je EndLoop

  # get raw half byte for hex with zeroed upper bytes
  mov %rsi, %r13
  and %r12, %r13  # curr_val = (num & mask)

  # decode to hex digit value
  shr %cl, %r13  # curr_val >>= shifts

  # check if digit value is numeric or alpha
  cmp %r14, %r13
  jae ElseAlpha

IfNumeric:  # IF (c < 10):
  # tweak numeric value 0-9 by ASCII offset 48
  add $48, %r13
  jmp EndIfs

ElseAlpha:  # ELSE:
  # tweak alpha value 10-15 by ASCII offset 55
  add $55, %r13

EndIfs:
  # write converted hex digit to buffer
  mov %r13b, (%rdi)

  inc %rdi  # buf_ptr++
  
  # adjust bit mask vars
  sub $4, %cl  # shifts -= 4
  shr $4, %r12 # mask >>= 4
  
  jmp BeginLoop

EndLoop:
  # restore regs
  pop %r14
  pop %r13
  pop %r12
  pop %rcx
  pop %rbx

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
  mov $input_buf, %rdi    # put 4 digit input
  call decodeDec4

  mov $output_buf, %rdi   # write hex digits for prior input
  mov %rax, %rsi
  call writeHex4

  # print result from its buffer
  mov $1, %rax              # syscall write
  mov $1, %rdi              # use stdout
  mov $output_buf, %rsi
  mov $output_write_c, %rdx

IfOops:
  mov $1, %rax              # syscall write
  mov $1, %rdi              # use stdout
  mov $oops_msg, %rsi
  mov $oops_len, %rdx

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
