;-------------------------------------------------------------
;+
; NAME:
;       ENDIAN
; PURPOSE:
;       Function indicating which endian the current machine uses.
; CATEGORY:
; CALLING SEQUENCE:
;       f = endian()
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /LIST means list result to screen.
;         /TEXT means return /LIST text.
; OUTPUTS:
;       f = 0 if little, 1 if big.     out
; COMMON BLOCKS:
; NOTES:
;       Note: this is the order the bytes are for multibyte
;         numeric values.  Use the IDL procedure BYTEORDER
;        to switch endian (use /LSWAP for 4 byte integers,
;        /L64SWAP for 8 byte integers).
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Dec 13
;       R. Sterner, 2000 Apr 11 --- Added /TEXT
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function endian, list=list, text=text, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Function indicating which endian the current machine uses.'
	  print,' f = endian()'
	  print,'   No args.'
	  print,'   f = 0 if little, 1 if big.     out'
	  print,' Keywords:'
	  print,'   /LIST means list result to screen.'
	  print,'   /TEXT means return /LIST text.'
	  print,' Note: this is the order the bytes are for multibyte'
	  print,'   numeric values.  Use the IDL procedure BYTEORDER'
	  print,'  to switch endian (use /LSWAP for 4 byte integers,'
	  print,'  /L64SWAP for 8 byte integers).'
	  return,''
	endif
 
	if fix([0B,1B],0) eq 1 then f=1 else f=0
	if (not keyword_set(list)) and (not keyword_set(text)) then return, f
 
	h = getenv('HOST')
	txt = h+' is '+(['little','big'])(f)+' endian'
	if keyword_set(list) then begin
	  print,' '
	  print,' '+txt+'.'
	endif
	if keyword_set(text) then f=txt
	return,f
 
	end
