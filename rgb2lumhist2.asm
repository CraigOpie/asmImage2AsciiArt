;   ============================  RGB2LUMHIST2  ===============================
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
        max_bin_        resd            1
        hash_           resd            1
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
        call            read_int                                                ; read in height
        mov             [ebx], eax                                              ; save height
        call            read_int                                                ; read in width
        mov             [ecx], eax                                              ; save width
        mov             edx, 0
        mul             word[ebx]                                               ; find total number of pixels
        shl             edx, 16
        mov             dx, ax
        mov             eax, edx
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
        mov             [ebx], eax                                              ; store the new pixel count to RAM
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
        jge             last_bin                                                ; and return the last bin in our array if it is
        mov             eax, ecx
        mov             ebx, 10
        mov             edx, 0
        div             ebx                                                     ; else divide by 10 to find the appropriate bin
        mov             ebx, bin_
        mov             [ebx], eax                                              ; store the int result in the bin_ variable
        jmp             update_bin

update_bin:
        ;**********************************************************************
        ;   Update The Bin
        ;
        ;**********************************************************************
        mov             ebx, bin_
        mov             eax, [ebx]
        mov             ecx, 16
        mul             ecx
        mov             ecx, bins_
        mov             edx, eax
        add             ecx, edx                                                ; move my bins_ pointer to the correct index
        add             [ecx], dword 1                                          ; increament the bin
        jmp             pixel_loop

last_bin:
        ;**********************************************************************
        ;   If The Value Is In The Max Bin Then Update the Bin Count
        ;
        ;**********************************************************************
        mov             ebx, bins_
        add             ebx, dword 1184                                         ; move my bins_ pointer to the correct index
        add             [ebx], dword 1                                          ; increament the bin
        jmp             pixel_loop

print_bins_setup:
        mov             ecx, i
        mov             edx, k
        mov             eax, max_bin_
        mov             [eax], dword 0
        mov             [ebx], dword 0
        mov             [ecx], dword 0
        mov             [edx], dword 9

determine_max_bin:
        cmp             dword[ebx], 75
        jge             setup_graph_edge
        mov             edx, 0
        mov             eax, 16
        mul             word[ebx]
        add             [ebx], dword 1
        mov             ecx, bins_
        add             ecx, eax
        mov             edx, max_bin_
        mov             eax, [ecx]
        cmp             eax, dword[edx]
        jle             determine_max_bin
        mov             eax, [ecx]
        mov             [edx], eax
        jmp             determine_max_bin

setup_graph_edge:
        mov             eax, 0x2d
        mov             ebx, i
        mov             [ebx], dword 0
        jmp             print_graph_edge_top

print_graph_edge_top:
        cmp             dword[ebx], 75
        jge             setup_graph
        call            print_char
        add             [ebx], dword 1
        jmp             print_graph_edge_top

setup_graph:
        call            print_nl
        mov             ebx, max_bin_
        mov             edx, 0
        mov             eax, [ebx]
        mov             [ecx], dword 20
        div             word[ecx]
        mov             ebx, hash_
        mov             [ebx], eax
        mov             ebx, i
        mov             ecx, k
        mov             [ebx], dword 0
        mov             [ecx], dword 20
        jmp             print_graph_content

print_graph_content:
        cmp             dword[ebx], 75
        jge             print_new_line
        mov             edx, 0
        mov             eax, 16
        mul             word[ebx]
        mov             ebx, bins_
        add             ebx, eax
        mov             edx, 0
        mov             eax, [ecx]
        mov             ecx, k
        mul             word[ecx]
        shl             edx, 16
        mov             dx, ax
        mov             eax, edx
        cmp             dword[ebx], eax
        jge             print_hash
        mov             ebx, i
        add             [ebx], dword 1
        jmp             print_graph_content

print_hash:
        mov             eax, 0x23
        call            print_char
        mov             ebx, i
        add             [ebx], dword 1
        jmp             print_graph_content

print_new_line:
        call            print_nl
        mov             [ebx], dword 0
        mov             ecx, k
        sub             [ecx], dword 1
        cmp             [ecx], dword 0
        je              setup_graph_edge_bottom
        jmp             print_graph_content

setup_graph_edge_bottom:
        mov             eax, 0x2d
        mov             ebx, i
        mov             [ebx], dword 0
        jmp             print_graph_edge_bottom

print_graph_edge_bottom:
        cmp             dword[ebx], 75
        jge             exit
        call            print_char
        add             [ebx], dword 1
        jmp             print_graph_edge_bottom
        
exit:
        ;**********************************************************************
        ;   Perform Program Cleanup
        ;
        ;**********************************************************************
        call            print_nl
        popa
        mov             eax, 0
        mov             ebx, 0
        mov             ecx, 0
        mov             edx, 0
        leave
        ret
        