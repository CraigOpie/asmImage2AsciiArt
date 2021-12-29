;   ==============================  RGB2ASCII  ================================
;
;   Author:         Craig Opie
;   Date:           2021-10-14
;   Version:        1.0.0
;   UH Username:    opieca
;   Description:    Assembly Program that takes a string of binary values that
;                   that represent pixel RGB values and creates ASCII art.
;   ===========================================================================

;   =========================  Initial Definitions  ===========================

;******************************************************************************
;   Include Statements
;
;******************************************************************************
%include "asm_io.inc"

;******************************************************************************
;   Static Variable Initialization
;
;******************************************************************************
segment .data
        char_string     db              ".`,:ilwXW", 0

;******************************************************************************
;   Global and Static Variable Declaration
;
;******************************************************************************
segment .bss
        height_         resd            1
        width_          resd            1
        wide_           resd            1
        char_           resd            1


;******************************************************************************
;   Define Instructions
;
;******************************************************************************
segment .text
        global          asm_main

        

;   ============================  Main   Function  ============================

asm_main:
        ;**********************************************************************
        ;   Perform Program Setup
        ;
        ;**********************************************************************
        enter           0,0
        pusha

find_dimensions:
        ;**********************************************************************
        ;   Find Dimensions Of The Image
        ;
        ;**********************************************************************
        mov             ecx, height_
        mov             ebx, width_
        mov             edx, wide_
        call            read_int                                                ; read in width
        mov             [ebx], eax                                              ; save width
        call            read_int                                                ; read in height
        mov             [ecx], eax                                              ; save height
        mov             [edx], eax                                              ; save width to wide
        jmp             height_loop

height_loop:
        ;**********************************************************************
        ;   Loop Through The Height Of The Image
        ;
        ;**********************************************************************
        mov             ebx, height_
        mov             eax, [ebx]
        cmp             eax, 0                                                  ; check if all lines have been printed
        je              exit                                                    ; exit if they have
        dec             eax                                                     ; else decrement the height
        mov             [ebx], eax

        mov             ebx, width_                                             ; return the wide to the width for the new line
        mov             eax, [ebx]
        mov             ecx, wide_
        mov             [ecx], eax
        jmp             width_loop

width_loop:
        ;**********************************************************************
        ;   Loop Through The Width Of The Image
        ;
        ;**********************************************************************
        mov             ebx, wide_
        mov             eax, [ebx]
        cmp             eax, 0                                                  ; If the image width is met
        je              print_new_line                                          ; Print a new line and return to the height loop
        dec             eax
        mov             [ebx], eax                                              ; Else decrement the wide variable
        jmp             get_values                                              ; And get the next values

get_values:
        ;**********************************************************************
        ;   Get The Values Of Each Pixel
        ;
        ;**********************************************************************
        call            read_int                                                ; Read the Red luminocity
        mov             ebx, eax                                                ; Store the value in ebx
        call            read_int                                                ; Read the Green luminocity
        add             ebx, eax                                                ; Add the value to ebx
        call            read_int                                                ; Read the Blue luminocity
        add             ebx, eax                                                ; Add the value to ebx
        mov             eax, ebx
        cmp             eax, 765                                                ; Check if the luminocity is the Max Value
        je              max_value                                               ; And return the last char in our array if it is
        mov             ebx, 85
        mov             edx, 0
        div             ebx                                                     ; Else divide by 85 to find the char place in our array
        mov             ebx, char_
        mov             [ebx], eax                                              ; Store the int result in the char_ variable
        jmp             print_value

print_value:
        ;**********************************************************************
        ;   Print The Value
        ;
        ;**********************************************************************
        mov             ecx, char_string
        mov             ebx, char_
        add             ecx, [ebx]                                              ; Move my char_string pointer to the correct index
        mov             eax, [ecx]                                              ; Save the correct char into eax for printing
        sub             ecx, ebx                                                ; Move my char_string pointer back to the start
        call            print_char
        call            print_char
        jmp             width_loop

print_new_line:
        ;**********************************************************************
        ;   Print A New Line After The Image Width Is Reached
        ;
        ;**********************************************************************
        call            print_nl
        jmp             height_loop

max_value:
        ;**********************************************************************
        ;   If The Value Is The Max Then Set The Pixel To The Last Character
        ;
        ;**********************************************************************
        mov             ebx, char_
        mov             eax, 8
        mov             [ebx], eax                                              ; Store the int result in the char_ variable
        jmp             print_value
        
exit:
        ;**********************************************************************
        ;   Perform Program Cleanup
        ;
        ;**********************************************************************
        popa
        mov             eax, 0
        mov             ebx, 0
        mov             ecx, 0
        mov             edx, 0
        leave
        ret
        