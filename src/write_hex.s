# write_hex.s
# Contains code to decode a 32-bit integer into hex digits. Uses extended ASCII.
# by: Derek Tan

### CODE
.text
# PROCEDURE writeHexW()
# Writes hex digits for a WORD into an ASCII buffer.
# Params: %rdi is buf_ptr, %rsi is number.
# Uses: %rbx for buffer end ptr, %rcx for shifts, %r12 for mask, %r13 for curr_val (raw digit value), $r14 for constant $10.
# Returns: 0 always.
.global writeHexW
writeHexW:
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

  mov $0, %rax  # RETURN 0
  ret

.global main
main:
  mov $digit_buf, %rdi    # Arg 1: digit_buf
  mov $167, %rsi          # Arg 2: 0x00A7
  call writeHexW

  mov $1, %rax            # syscall write
  mov $1, %rdi            # use stdout
  mov $digit_buf, %rsi    # __u_char *digit_buf = ?
  mov $5, %rdx            # write_len = 5 (for newline too)
  syscall

  mov $0, %rax
  ret

### DATA
.data
digit_buf:
  .ascii "\0\0\0\0\n"
