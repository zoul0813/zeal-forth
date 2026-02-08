    INCLUDE "constants_h.asm"

  SECTION DATA
_str_project_name:
    DEFB "Zeal Forth\n\nType `bye` to exit\n\n", 0
_str_project_name_end:

_str_newline:
    DEFB '\n', 0
_str_newline_end:

_str_ok:
    DEFB "ok\n", 0
_str_ok_end:

_str_prompt:
    DEFB "> ", 0
_str_prompt_end:

;*************
; ERRORS     *
;*************
_str_error:
    DEFB " error\n", 0
_str_error_end:

_str_unsupported:
    DEFB "unsupported", 0
_str_unsupported_end:

_str_compile_only:
    DEFB "compile-only", 0
_str_compile_only_end:

_str_unterminated_str:
    DEFB "unterminated string", 0
_str_unterminated_str_end:

_str_missing_name_str:
    DEFB "missing name", 0
_str_missing_name_str_end:

_str_error_numeric_overflow:
    DEFB "numeric overflow", 0
_str_error_numeric_overflow_end:

_str_err_stack_overflow:
    DEFB "stack overflow", 0
_str_err_stack_overflow_end:

_str_err_stack_underflow:
    DEFB "stack underflow", 0
_str_err_stack_underflow_end:

_str_err_too_long:
    DEFB "too long", 0
_str_err_too_long_end:

_str_error_not_found:
    DEFB "not found", 0
_str_error_not_found_end:

_err_string_table:
    ; index 0 => ERR_NUMERIC_OVERFLOW (-1)
    DEFW _str_error_numeric_overflow
    ; index 1 => ERR_UNTERMINATED_STR (-2)
    DEFW _str_unterminated_str
    ; index 2 => ERR_STACK_OVERFLOW (-3)
    DEFW _str_err_stack_overflow
    ; index 3 => ERR_STACK_UNDERFLOW (-4)
    DEFW _str_err_stack_underflow
    ; index 4 => ERR_MISSING_NAME (-5)
    DEFW _str_missing_name_str
    ; index 5 => ERR_COMPILE_ONLY (-6)
    DEFW _str_compile_only
    ; index 6 => ERR_UNSUPPORTED (-7)
    DEFW _str_unsupported
    ; index 7 => ERR_UNSUPPORTED (-8)
    DEFW _str_err_too_long



; data stack pointer
data_sp:
    DEFW DATA_STACK_head
; return stack pointer
return_sp:
    DEFW RETURN_STACK_head
; here stack pointer
HERE:
    DEFW __HERE_head
LATEST:
    DEFW 0
CURRENT_DEF_CFA:
    DEFW HERE
STATE:
    DEFW STATE_IMM
BASE:
    DEFW 0x10

  SECTION BSS
_curr_word:
    DEFW 0 ; current word
_curr_len:
    DEFW 0 ; current word length
_next_word:
    DEFW 0 ; location of next word
_curr_entry:
    DEFW 0 ; location of active dictionary entry
_input_buffer:
    DEFS BUFFER_SIZE
_input_buffer_null:
    DEFB 0 ; permanent null-terminator
_key_buffer:
    DEFB 0 ; single key buffer
_key_pending:
    DEFB 0 ; key in buffer

;; file parser
_file_fd: DEFB 0
_recovery_sp:
    DEFW 0

  ; a place to store dword numbers for conversion
_dword_num:
    DEFB 0, 0, 0, 0
_str_buffer:
    DEFS 32, 0


data_stack:
    DEFS DATA_STACK_size
_data_stack_end:
return_stack:
    DEFS RETURN_STACK_size
_return_stack_end:

  SECTION HERE
