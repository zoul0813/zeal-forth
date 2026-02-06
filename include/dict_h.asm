#ifndef _DICT_H_ASM
#define _DICT_H_ASM

    DEFC BIT_IMM = 7
    DEFC BIT_HIDDEN = 6
    DEFC BIT_RESERVED = 5

    DEFC IMMEDIATE = 1 << BIT_IMM
    DEFC HIDDEN = 1 << BIT_HIDDEN
    DEFC RESERVED = 1 << BIT_RESERVED

    DEFVARS 0 {
      dict_prev DS.W 1
      dict_flags DS.B 1
      dict_name DS.B 0
      dict_cfa DS.W 1
      dict_body DS.B 0
    }

    EXTERN dict_init
    EXTERN dict_search

    EXTERN DICT_CFA
    EXTERN DICT_BODY
    EXTERN DICT_C
    EXTERN DICT_W
    EXTERN CREATE_HEADER

#endif