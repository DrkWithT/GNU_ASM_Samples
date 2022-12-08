# parse_dec.s
# Contains a program that reads a 4 digit decimal number and prints its equivalent hex.
# Derek Tan

.text
# PROCEDURE parseDec()
# Desc: Parses an n-digit decimal number literal into an unsigned value.
# Params: %rdi for address of literal's least significant digit, %rsi for digit count.
# Uses: %rbx for place value, %rcx for digit value, %r12 for base 10, %r13 and %r14 for temp1 and sub_result, %r15 for loop counter (ends at 0).
# Returns: %rax for unsigned result.
.global parseDec
parseDec:
    # preserve registers
    push %rbx
    push %rcx
    push %r12
    push %r13  # unused but preserve it anyway
    push %r14
    push %r15

    # create stack frame to store sub_result
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp

    mov $0, %r13
    movq %r13, -8(%rbp)  # unsigned long sub_result = 0;  // sub-sum of digit_val * place_val

    # prepare literal string pointer to right most char
    add %rsi, %rdi
    dec %rdi

    # prepare locals: place_val, digit_val, base, temp1, temp2, end_iter, result
    mov $1, %rbx    # place_val = 1;
    mov $0, %rcx    # digit_val = 0;
    mov $10, %r12   # base = 10;
    mov $0, %r13    # temp1 = 0;  // constant 0 for loop test
    mov $0, %r14    # result = 0;

    mov %rsi, %r15  # count = digit_count; // count decreases from str_length to 1... ends at 0!

LoopConvert:
    cmp %r15, %r13
    je EndConvert

    # get digit value
    mov $0, %rcx
    movb (%rdi), %cl       # char c = *literal_ptr;
    sub $48, %cl           # digit_val = c - '0';

    # do multiplications
    mov %rcx, %rax
    mul %rbx               # sub_result = digit_val * place_val;
    
    # update result
    movq %rax, -8(%rbp)
    addq -8(%rbp), %r14    # result += sub_result

    # update loop vars:
    mov %rbx, %rax
    mulq %r12
    mov %rax, %rbx    # place_val *= 10

    dec %rdi          # literal_ptr--;
    dec %r15          # count--;
    jmp LoopConvert

EndConvert:
    # move result into %rax
    mov %r14, %rax  # result = sub_result;

    # destroy stack frame
    mov %rbp, %rsp
    pop %rbp

    # restore registers
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rcx
    pop %rbx
    ret

# PROCEDURE writeHexW() // TAKEN FROM: write_hex.s 
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

    mov $0, %rax
    ret

.global main
main:
    # 1. Prompt on stdout for 4 digits from stdin.
    mov $1, %rax              # syscall write
    mov $1, %rdi              # use stdout
    mov $prompt, %rsi         # src is prompt
    mov $14, %rdx              # write_len is 4
    syscall
    
    mov $0, %rax             # x64 syscall read
    mov $0, %rdi             # use stdin
    mov $input_buffer, %rsi  # read to input_buffer
    mov $4, %rdx             # read 4 digit characters
    syscall

    # 2. Call parseHex4... then compare return result to $1234 in %r8!
    mov $input_buffer, %rdi
    mov $4, %rsi
    call parseDec             # test_number = parseDec(input_buffer + 3, 4); // must be 1234

    # 3. Write hex literal equivalent to the previous result.
    mov $output_buffer, %rdi
    mov %rax, %rsi
    call writeHexW

    # 4. Print hex literal for previous result.
    mov $1, %rax              # syscall write
    mov $1, %rdi              # use stdout
    mov $output_buffer, %rsi  # src is success_msg
    mov $4, %rdx              # write_len is 4
    syscall

    mov $0, %rax
    ret

.data
input_buffer:
    .ascii "0000"              # char input_buffer[5] = "0000"; // real len is 4

output_buffer: # should be hex 0x04D2 for 1234!
    .ascii "\0\0\0\0"          # char output_buffer[5] = ""; // write len is 4

success_msg:
    .ascii "Number OK.\n"      # const char success_msg[12] = "Number OK.\n"; // real len is 11

fail_msg:
    .ascii "Wrong Val.\n"      # const char success_msg[12] = "Wrong Val.\n"; // real len is 11

prompt:
    .ascii "Put 4 digits:\n"  # const char prompt[15] = "Put 4 digits:\n"; // real len is 14
