#ifndef _CONSTANTS_H_ASM
#define _CONSTANTS_H_ASM

    DEFC BUFFER_SIZE = 256
    DEFC DATA_STACK_size = 2048
    DEFC DATA_STACK_head = data_stack + DATA_STACK_size
    DEFC DATA_STACK_tail = data_stack
    DEFC RETURN_STACK_size = 1024
    DEFC RETURN_STACK_head = return_stack + RETURN_STACK_size
    DEFC RETURN_STACK_tail = return_stack
    DEFC Z80_STACK = 0xFFFF
    DEFC Z80_STACK_SIZE = 2048
    DEFC __Z80_STACK_tail = Z80_STACK - Z80_STACK_SIZE

    ; Bottom of the heap, if the head reaches this value, return no more memory error
    DEFC DATA_BOTTOM_HEAP_MSB = 0xC0
    DEFC DATA_BOTTOM_HEAP = DATA_BOTTOM_HEAP_MSB << 8

    DEFC CELL_SIZE = 2
    DEFC PAD_SIZE = 128
    DEFC PAD_OFFSET = 256
    DEFC FALSE = 0
    DEFC TRUE = -1

    DEFC STATE_IMM = 0    ; immediate mode (execute now)
    DEFC STATE_COMP = 1   ; compile mode

    DEFC ERR_NUMERIC_OVERFLOW = -13

    EXTERN __TEXT_head
    EXTERN __TEXT_tail
    EXTERN __TEXT_size
    EXTERN __DATA_head
    EXTERN __DATA_tail
    EXTERN __DATA_size
    EXTERN __BSS_head
    EXTERN __BSS_tail
    EXTERN __BSS_size
    EXTERN __HERE_head
    EXTERN __HERE_tail
    EXTERN __HERE_size

    EXTERN _exit_code

    ; stacks
    EXTERN data_sp        ;; data stack pointer
    EXTERN data_stack     ;; data stack data
    EXTERN return_sp      ;; return stack pointer
    EXTERN return_stack   ;; return stack data

    ; HERE
    EXTERN here_sp        ;; here pointer

    ; string buffers
    EXTERN _state
    EXTERN _curr_word
    EXTERN _curr_len
    EXTERN _next_word
    EXTERN _input_buffer
    EXTERN _dword_num
    EXTERN _str_buffer


    ; common string consts
    EXTERN _str_project_name
    EXTERN _str_project_name_end
    EXTERN _str_newline
    EXTERN _str_newline_end
    EXTERN _str_ok
    EXTERN _str_ok_end
    EXTERN _str_error
    EXTERN _str_error_end
    EXTERN _str_error_numeric_overflow
    EXTERN _str_error_numeric_overflow_end
    EXTERN _str_prompt
    EXTERN _str_prompt_end
    EXTERN _str_unknown
    EXTERN _str_unknown_end

#endif