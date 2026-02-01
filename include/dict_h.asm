#ifndef _DICT_H_ASM
#define _DICT_H_ASM

    DEFC IMMEDIATE = 1 << 7
    DEFC HIDDEN = 1 << 6
    DEFC RESERVED = 1 << 5

    DEFVARS 0 {
      dict_prev DS.W 1
      dict_flags DS.B 1
      dict_name DS.B 0
      dict_cfa DS.W 1
      dict_body DS.B 0
    }

    EXTERN dict_init
    EXTERN dict_search

    EXTERN DICT_C
    EXTERN DICT_W
    EXTERN CREATE_HEADER

#endif