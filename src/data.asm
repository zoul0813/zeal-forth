    INCLUDE "constants_h.asm"

  SECTION DATA
_str_project_name:
    DEFB "Zeal Forth\n\nType `bye` to exit\n\n", 0
_str_project_name_end:

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

_str_error_not_found:
    DEFB "not found", 0
_str_error_not_found_end:

_err_error_numeric_overflow:
    DEFB "numovf", 0
_err_unterminated_str:
    DEFB "unclosed", 0 ; unterminated string
_err_err_stack_overflow:
    DEFB "stkovf", 0
_err_err_stack_underflow:
    DEFB "stkunf", 0
_err_missing_name:
    DEFB "noname", 0
_err_compile_only:
    DEFB "cmp", 0
_err_unsupported:
    DEFB "unsup", 0
_err_err_too_long:
    DEFB "lenovf", 0
_err_unbalanced_control:
    DEFB "imbal", 0 ; unbalanced
_err_div_by_zero:
    DEFB "div0", 0

_err_dict_overflow:
    DEFB "dictovf", 0

_err_string_table:
    ; index 0 => ERR_NUMERIC_OVERFLOW (-1)
    DEFW _err_error_numeric_overflow
    ; index 1 => ERR_UNTERMINATED_STR (-2)
    DEFW _err_unterminated_str
    ; index 2 => ERR_STACK_OVERFLOW (-3)
    DEFW _err_err_stack_overflow
    ; index 3 => ERR_STACK_UNDERFLOW (-4)
    DEFW _err_err_stack_underflow
    ; index 4 => ERR_MISSING_NAME (-5)
    DEFW _err_missing_name
    ; index 5 => ERR_COMPILE_ONLY (-6)
    DEFW _err_compile_only
    ; index 6 => ERR_UNSUPPORTED (-7)
    DEFW _err_unsupported
    ; index 7 => ERR_UNSUPPORTED (-8)
    DEFW _err_err_too_long
    ; index 8 => ERR_UNBALANCED_CONTROL (-9)
    DEFW _err_unbalanced_control
    ; index 9 => ERR_DIV_BY_ZERO (-10)
    DEFW _err_div_by_zero
    ; index 10 => ERR_DICT_OVERFLOW (-11)
    DEFW _err_dict_overflow



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
STATE:
    DEFW STATE_IMM
BASE:
    DEFW 10

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
_compile_return_sp:
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
