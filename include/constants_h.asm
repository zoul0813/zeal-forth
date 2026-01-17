    DEFC BUFFER_SIZE = 256
    DEFC DATA_STACK_SIZE = 2048
    DEFC RETURN_STACK_SIZE = 2048
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

    DEFC ERR_NUMERIC_OVERFLOW = -13

    EXTERN __BSS_head
    EXTERN __BSS_tail
    EXTERN __BSS_size

    EXTERN _exit_code

    ; stacks
    EXTERN data_sp
    EXTERN data_stack
    EXTERN return_sp
    EXTERN return_stack

    ; HERE
    EXTERN here_sp
    EXTERN here

    ; string buffers
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
