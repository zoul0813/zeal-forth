    INCLUDE "constants_h.asm"

  SECTION DATA
_str_project_name:
    DEFB "Zeal Forth\n", 0
_str_project_name_end:

_str_newline:
    DEFB '\n', 0
_str_newline_end:

_str_ok:
    DEFB "  ok\n", 0
_str_ok_end:

_str_error:
    DEFB "  error\n", 0
_str_error_end:

_str_error_numeric_overflow:
    DEFB "  numeric overflow"
_str_error_numeric_overflow_end:

_str_prompt:
    DEFB "> ", 0
_str_prompt_end:

_str_unknown:
    DEFB "UNKNOWN: ", 0
_str_unknown_end:


data_sp:
    DEFW data_stack + DATA_STACK_SIZE
return_sp:
    DEFW return_stack + RETURN_STACK_SIZE
here_sp:
    DEFW here

  SECTION BSS
_curr_word:
    DEFW 0 ; current word
_curr_len:
    DEFW 0 ; current word length
_next_word:
    DEFW 0 ; location of next word
_input_buffer:
    DEFS BUFFER_SIZE

  ; a place to store dword numbers for conversion
_dword_num:
    DEFB 0, 0, 0, 0
_str_buffer:
    DEFS 32, 0


data_stack:
    DEFS DATA_STACK_SIZE
_data_stack_end:
return_stack:
    DEFS RETURN_STACK_SIZE
_return_stack_end:
here:
