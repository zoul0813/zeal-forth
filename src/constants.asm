    DEFC BUFFER_SIZE = 256
    DEFC DATA_STACK_SIZE = 2048
    DEFC RETURN_STACK_SIZE = 2048
    DEFC Z80_STACK = 0xFFFF
    DEFC Z80_STACK_SIZE = 2048
    DEFC __Z80_STACK_TAIL = Z80_STACK - Z80_STACK_SIZE

  SECTION DATA
_str_project_name:
    DEFB "Zeal Forth\n", 0
_str_project_name_end:

_str_newline:
    DEFB 0x0A, 0x00
_str_newline_end:

_str_ok:
    DEFB "OK.", 0
_str_ok_end:

_str_prompt:
    DEFB "> ", 0
_str_prompt_end:

_str_is_word:
    DEFB "WORD: ", 0
_str_is_word_end:

_str_is_number:
    DEFB "NUMBER: ", 0
_str_is_number_end:

data_sp:
    DEFW data_stack + DATA_STACK_SIZE
return_sp:
    DEFW return_stack + RETURN_STACK_SIZE

  SECTION BSS
_curr_word:
    DEFW 0 ; current word
_curr_len:
    DEFW 0 ; current word length
_next_word:
    DEFW 0 ; location of next word
_input_buffer:
    DEFS BUFFER_SIZE

data_stack:
    DEFS DATA_STACK_SIZE
_data_stack_end:
return_stack:
    DEFS RETURN_STACK_SIZE
_return_stack_end:
heap:
