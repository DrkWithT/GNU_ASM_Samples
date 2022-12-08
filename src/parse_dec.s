# parse_dec.s
# Contains decimal literal parsing code without any stdc function calls. Syscalls are okay.
# Derek Tan

.text
# PROCEDURE parseDec()
# Desc: Parses an n-digit decimal number literal into an unsigned value.
# Params: %rdi for address of literal's least significant digit, %rsi for digit count.
# Uses: %rbx for place value, %rcx for digit value, %rdx for division remainder, %r12 for base 10, %r13 and %r14 for temp1 and sub_result, %r15 for loop counter (ends at 0).
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

.global main
main:
    # 1. Call parseHex4... then compare return result to $1234 in %r8!
    mov $input_buffer, %rdi
    mov $4, %rsi
    call parseDec            # test_number = parseDec(input_buffer + 3, 4);

    mov $1234, %r8
    cmp %r8, %rax
    jne FailBlock

    # 2a. print success msg if 1234 was parsed from "1234".
    mov $1, %rax            # syscall write
    mov $1, %rdi            # use stdout
    mov $success_msg, %rsi  # src is success_msg
    mov $11, %rdx           # write_len is 11
    syscall

    jmp EndBlock1

FailBlock:
    # 2b. print failure msg if 1234 was not parsed correctly.
    mov $1, %rax            # syscall write
    mov $1, %rdi            # use stdout
    mov $fail_msg, %rsi     # src is fail_msg
    mov $11, %rdx           # write_len is 11
    syscall

EndBlock1:
    mov $0, %rax
    ret

.data
input_buffer:
    .ascii "1234"            # char input_buffer[5] = "1234"; // real len is 4

success_msg:
    .ascii "Number OK.\n"      # const char success_msg[12] = "Number OK.\n"; // real len is 11

fail_msg:
    .ascii "Wrong Val.\n"      # const char success_msg[12] = "Wrong Val.\n"; // real len is 11
