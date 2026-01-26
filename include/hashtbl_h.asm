#ifndef _HASHTBL_H_ASM
#define _HASHTBL_H_ASM

    ; Define the list entry format
    DEFVARS 0 {
    list_entry_content_t DS.B 0
    list_entry_key_t DS.B 16
    list_entry_value_t DS.B 2  ; resulted binary should not exceed 64KB
    list_entry_content_end_t DS.B 0
    list_entry_next_t DS.B 2
    list_entry_end_t DS.B 0
    }

    DEFC LIST_ENTRY_KEY_SIZE = list_entry_value_t - list_entry_key_t
    DEFC LIST_ENTRY_CONTENT_SIZE = list_entry_content_end_t - list_entry_content_t
    DEFC LIST_ENTRY_SIZE = list_entry_end_t

    EXTERN hshtbl_insert
    EXTERN hshtbl_get
    EXTERN hshtbl_list_get_next
    EXTERN hshtbl_hashmap

#endif
