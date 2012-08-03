;-------------------------------------------------------------
;+
; NAME:
;       SHOWBITS
; PURPOSE:
;       Shows bits of an integer data type.
; CATEGORY:
; CALLING SEQUENCE:
;       showbits, num
; INPUTS:
;       num = Integer data type (scalar or array).    in
; KEYWORD PARAMETERS:
;       Keywords:
;         GROUP=g  Group output into groups of g digits.
;         /N       List each array value on a new line.
;         /FULL    List number and data type with bit pattern.
;         /QUIET   Do not list bit pattern on screen.
;         OUT=out  Returned bit pattern.
;         /BINARY  List bits in binary (default).
;         /OCTAL   List bits in octal.
;         /HEX     List bits in hexidecimal.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Jun 7
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro showbits, v, group=g, help=hlp, out=out, n=new, $
	   quiet=quiet, full=full, binary=bin, octal=oct, hex=hex
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Shows bits of an integer data type.'
	  print,' showbits, num'
	  print,'   num = Integer data type (scalar or array).    in'
	  print,' Keywords:'
	  print,'   GROUP=g  Group output into groups of g digits.'
	  print,'   /N       List each array value on a new line.'
	  print,'   /FULL    List number and data type with bit pattern.'
	  print,'   /QUIET   Do not list bit pattern on screen.'
	  print,'   OUT=out  Returned bit pattern.'
	  print,'   /BINARY  List bits in binary (default).'
	  print,'   /OCTAL   List bits in octal.'
	  print,'   /HEX     List bits in hexidecimal.'
	  return
	endif
 
        ;------  Make sure arg is integer type  ---------
        typ = datatype(v,1,integer_bits=bits)
        if bits le 0 then begin
          print,' Error in showbits: Input must be an integer data type.'
          return
        endif
 
	;------  Deal with display base  ----------
	if keyword_set(oct) then begin		; Octal.
	  nbits = 3				; Use 3 bit slices.
	  dig = strtrim(sindgen(8),2)		; Digit lookup table.
	  base = 'octal'			; Base.
	  mask = 7				; Mask to isolate 3 bits.
	endif
	if keyword_set(hex) then begin		; Hex.
	  nbits = 4
	  dig = strtrim([sindgen(10),'A','B','C','D','E','F'],2)
	  base = 'hex'
	  mask = 15
	endif
	if n_elements(nbits) eq 0 then begin	; Binary.
	  nbits = 1
	  dig = strtrim(sindgen(2),2)
	  base = 'binary'
	  mask = 1
	endif
 
	;-----  Deal with digit group size  ---------
	if n_elements(g) eq 0 then g=bits+1	; No grouping by default.
	if g eq 0 then g=bits+1			; or if given 0.
	g = g>1					; Fix wild values.
 
	;-------  Convert number to bits  ---------
	out = ''				; Start with a blank.
	c = 0					; Digit counter.
	for i=0, bits-1, nbits do begin		; Loop through bit slices.
	  if (c mod g) eq 0 then out=' '+out	; Digit group spacer.
	  out = dig(mask AND ishft(v,-i)) + out	; Find next digit.
	  c = c + 1				; Count digit.
	endfor
 
	;-------  Add extra info  ---------------
	if keyword_set(full) then begin
	  v2 = v				; Copy in case byte type.
	  if bits eq 8 then begin		; Deal with byte type.
	    v2 = fix(v2)	; String treats bytes like chars, so fix.
	    fmt = '(I4)'	; But keep printout space down.
	  endif else fmt=''	; Other data types.
	  out = string(v2,form=fmt)+' ('+typ+') '+base+' bit pattern: '+out
	endif
 
	;------  Display bit pattern  ------------------
	if not keyword_set(quiet) then $
	  if keyword_set(new) then $
	    for i=0,n_elements(out)-1 do print,out(i) else print,out
 
	end
