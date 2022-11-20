# test1.s
# By: Derek Tan

### CODE
.text
# PROC main()
# Desc: Runs some test code as the driver procedure.
# Returns: int 0 on success.
.global main
main:
  # test comparison of num1 to 10
  mov $num1, %rbx
  mov $10, %rdx

  # IF (num1 > 10):
  cmp %rbx, %rdx
  jle BlockLeq

  # print("Greater\n")
  mov $4, %rax    # syscall write
  mov $1, %rbx    # use stdout
  mov $msg_gr, %rcx
  mov $msg_gr_len, %rdx
  int $0x80

  jmp EndBlock

BlockLeq:
  # ELSE:
  # print("Less-equal\n")
  mov $4, %rax
  mov $1, %rbx
  mov $msg_leq, %rcx
  mov $msg_leq_len, %rdx
  int $0x80

EndBlock:
  # exit out with status 0
  mov $0, %rax
  ret

### DATA
.data
msg_gr:
  .ascii "Greater\n"

msg_gr_len:
  .long 8

msg_leq:
  .ascii "Less-equal\n"

msg_leq_len:
  .long 11

# test number!
num1:
  .long 2
