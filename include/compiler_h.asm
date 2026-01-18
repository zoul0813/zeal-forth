#ifndef _COMPILER_H_ASM
#define _COMPILER_H_ASM

    DEFC TP_PATCH_8  = 0x00
    DEFC TP_PATCH_16 = 0x80

    DEFC TP_BASE = 0
    DEFC TP_SIZE = 2
    DEFC TP_END  = 4
    DEFC TP_USER = 6

    DEFC TEMPLATE_END = TP_PATCH_16 | TP_END

    EXTERN apply_template
    EXTERN load_pad_ix

  ; Prepare to apply a template
  MACRO TEMPLATE_INIT _
    call load_pad_ix
  ENDM

  ; Apply the template
  ;
  ; Parameters
  ; tpl = start address of template
  ; tpl_end = end address of template
  ;
  ; Example:
  ; template_create:
  ; @ldde:
  ;     ld de, 0x0000
  ;     call pushdata
  ;     ret
  ; @end:
  ; @patches:
  ;     db @ldde + 1 - template_create, TEMPLATE_END
  ;     db 0
  MACRO TEMPLATE_APPLY tpl, tpl_end
    ld hl, tpl
    ld bc, tpl_end - tpl
    ld (ix + TP_SIZE), c
    ld (ix + TP_SIZE + 1), b
    ld de, tpl_end
    call apply_template
  ENDM

  ; Load hb and lb into PAD for template replace
  ; Use with TEMPLATE_VAR16(offset)
  ; Parameters:
  ;  offset - the user variable offset
  ;  hb - the high byte
  ;  lb - the low byte
  MACRO TEMPLATE_USER16 offset, hb, lb
    ld (ix + TP_USER + (offset * 2)), lb
    ld (ix + TP_USER + (offset * 2) + 1), hb
  ENDM

  ; Load lb into PAD for template replace
  ; Use with TEMPLATE_VAR8(offset)
  ; Parameters:
  ;  offset - the user variable offset
  ;  lb - the value
  MACRO TEMPLATE_USER8 offset, lb
    ld (ix + TP_USER + (offset * 2)), lb
    ld (ix + TP_USER + (offset * 2) + 1), 0
  ENDM

  ; Reference the user var indexed by offset
  ; Used in conjunction with TEMPLATE_USER16(offset, hb, lb)
  MACRO TEMPLATE_VAR16 offset
    TP_PATCH_16 | (TP_USER + (offset * 2))
  ENDM

  ; Reference the user var indexed by offset
  ; Used in conjunction with TEMPLATE_USER8(offset, hb, lb)
  MACRO TEMPLATE_VAR8 offset
    TP_PATCH_8 | (TP_USER + (offset * 2))
  ENDM

#endif
