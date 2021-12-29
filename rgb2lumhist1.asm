;   ============================  RGB2LUMHIST1  ===============================
;
;   Author:         Craig Opie
;   Date:           2021-10-21
;   Version:        1.0.0
;   UH Username:    opieca
;   Description:    Assembly Program that takes a string of binary values that
;                   that represent pixel RGB values and creates a histogram
;                   table based on luminance.
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
        lum_string      db              "luminance ", 0

;******************************************************************************
;   Global and Static Variable Declaration
;
;******************************************************************************
segment .bss
        height_         resd            1
        width_          resd            1
        pixels_         resd            1
        bin_            resd            1
        bins_           resd            75
        i               resd            1
        k               resd            1


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
        call            read_int                                                ; read in width
        mov             [ebx], eax                                              ; save width
        call            read_int                                                ; read in height
        mov             [ecx], eax                                              ; save height
        mov             edx, 0                                                  ; clear my edx register for the mul action
        mul             word[ebx]                                               ; find total number of pixels width x height
        shl             edx, 16                                                 ; shift the high register over to make room
        mov             dx, ax                                                  ; and put the lower value in the register
        mov             eax, edx                                                ; move the final multiplication value to eax
        mov             edx, pixels_
        mov             [edx], eax                                              ; save the number of pixels
        jmp             pixel_loop

pixel_loop:
        ;**********************************************************************
        ;   Loop Through The Number Of Pixels In The Image
        ;
        ;**********************************************************************
        mov             ebx, pixels_
        mov             eax, [ebx]
        cmp             eax, 0                                                  ; check if all pixels have been traversed
        je              print_bins_setup                                        ; exit if they have
        dec             eax                                                     ; else decrement the pixel count
        mov             [ebx], eax                                              ; store the new pixel count to memory
        jmp             get_values                                              ; and get the pixel values

get_values:
        ;**********************************************************************
        ;   Get The Values Of Each Pixel
        ;
        ;**********************************************************************
        call            read_int                                                ; read the Red luminocity
        mov             ebx, eax                                                ; store the value in ebx
        call            read_int                                                ; read the Green luminocity
        add             ebx, eax                                                ; add the value to ebx
        call            read_int                                                ; read the Blue luminocity
        add             ebx, eax                                                ; add the value to ebx
        mov             ecx, ebx
        cmp             ecx, 740                                                ; check if the luminocity is the Max Bin
        jge             last_bin                                                ; and increase the last bin if it is
        mov             eax, ecx                                                ; else put the luminocity in eax for division
        mov             ebx, 10                                                 ; prepare to divide the luminocity by 10
        mov             edx, 0                                                  ; clear out the edx and prepare for division
        div             ebx                                                     ; divide by 10 to find the appropriate bin
        mov             ebx, bin_
        mov             [ebx], eax                                              ; store the int result in the bin_ variable
        jmp             update_bin

update_bin:
        ;**********************************************************************
        ;   Update The Bin
        ;
        ;**********************************************************************
        mov             ebx, bin_
        mov             eax, [ebx]                                              ; move the bin number to the eax for multiplication
        mov             edx, 0                                                  ; prepare the edx register for multiplation
        mov             ecx, 16                                                 ; prepare to multiply by 16 to get the correct address
        mul             ecx                                                     ; multiply by 16 to find the address location
        mov             ecx, bins_
        mov             edx, eax
        add             ecx, edx                                                ; move my bins_ pointer to the correct index
        add             [ecx], dword 1                                          ; increament the correct bin
        jmp             pixel_loop

last_bin:
        ;**********************************************************************
        ;   If The Value Is In The Max Bin Then Update the Bin Count
        ;
        ;**********************************************************************
        mov             ebx, bins_
        add             ebx, dword 1184                                         ; move my bins_ pointer to the correct address
        add             [ebx], dword 1                                          ; increament the bin
        jmp             pixel_loop

print_bins_setup:
        ;**********************************************************************
        ;   Setup The Variables Required To Iterrate Through The Bins
        ;
        ;**********************************************************************
        mov             ecx, i
        mov             edx, k
        mov             [ebx], dword 0                                          ; initialize my bin counter
        mov             [ecx], dword 0                                          ; initialize my first text int ie. 0-9 to 740-750
        mov             [edx], dword 9                                          ; initialize my second text int as above
        jmp             print_bins

print_bins:
        ;**********************************************************************
        ;   Iterrate Through The Bins And Print The Values
        ;
        ;**********************************************************************
        cmp             dword[ecx], 750                                         ; if complete iterrating through all bin groups
        jge             exit                                                    ; then exit the program
        mov             eax, lum_string                                         ; else load the text string to print to the user
        call            print_string
        mov             eax, [ecx]
        call            print_int
        mov             eax, 0x2d                                               ; print the '-' character
        call            print_char
        mov             eax, [edx]
        call            print_int
        mov             eax, 0x3a                                               ; print the ':' character
        call            print_char
        mov             eax, 0x20                                               ; print a space character
        call            print_char
        mov             edx, 0                                                  ; prepare the edx register for multiplication
        mov             eax, 16                                                 ; prepare to multiply by 16
        mul             byte[ebx]                                               ; ebx iterrates through each bin and multiplies the
        mov             ecx, bins_                                              ; bin number by 16 to get the bin address location
        add             ecx, eax                                                ; move the pin pointer to the correct address
        mov             eax, dword [ecx]                                        ; print the value in the bin
        call            print_int
        call            print_nl
        mov             ecx, i
        mov             edx, k
        add             [ecx], dword 10                                         ; increament the first text int by 10
        add             [edx], dword 10                                         ; increament the second text int by 10
        add             [ebx], dword 1                                          ; increament the bin counter
        jmp             print_bins
        
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
        