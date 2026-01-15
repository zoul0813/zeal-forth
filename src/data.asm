
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
