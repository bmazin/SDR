;-------------------------------------------------------------
;+
; NAME:
;       SETCOLOR
; PURPOSE:
;       Set a single color table entry.
; CATEGORY:
; CALLING SEQUENCE:
;       setclr, clr, indx
; INPUTS:
;       clr = color specification.  May be in hex.     in
;       indx = color index to set (def=last).          in
; KEYWORD PARAMETERS:
;       Keywords:
;         BRIGHTNESS=fact  Brightness factor, 0 to 1 (def=1).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: colors are specified by giving R,G,B in that
;         order.  Decimal numbers must be 3 3-digit values
;         like 255255255 or 255255000 and may be a string.
;         Colors given in hex must start with # like
;         #ffffff or #ffff00 (case ignored).
;         Spaces, tabs, and commas are allowed:
;         # ff ff 00 or 255 255 000 or 100,050,000
;         but all digits must be given.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Feb 13
;       R. Sterner, 1998 Jan 23 --- Added BRIGHTNESS keyword.
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro setcolor, clr, indx, brightness=bright, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Set a single color table entry.'
	  print,' setclr, clr, indx'
	  print,'   clr = color specification.  May be in hex.     in
	  print,'   indx = color index to set (def=last).          in'
	  print,' Keywords:'
	  print,'   BRIGHTNESS=fact  Brightness factor, 0 to 1 (def=1).'
	  print,' Notes: colors are specified by giving R,G,B in that'
	  print,'   order.  Decimal numbers must be 3 3-digit values'
	  print,'   like 255255255 or 255255000 and may be a string.'
	  print,'   Colors given in hex must start with # like'
	  print,'   #ffffff or #ffff00 (case ignored).'
	  print,'   Spaces, tabs, and commas are allowed:'
	  print,'   # ff ff 00 or 255 255 000 or 100,050,000'
	  print,'   but all digits must be given.'
	  return
	endif
 
	if n_elements(indx) eq 0 then indx=!d.table_size-1  ; Def index=last.
 
	if n_elements(bright) eq 0 then bright=1.
 
	if indx ge !d.table_size then begin
	  print,' Error in setcolor: given color index out of range.'
	  print,'   Max index is '+strtrim(!d.table_size-1,2)
	  return
	endif
 
	;-------  Preprocess to allow flexible input  --------
	t = repchr(clr,',',' ')		; Allow commas.
	t = strcompress(t,/rem)		; Drop spaces/tabs.
 
	;-------  Pick off R,G,B values  ----------
	if strmid(t,0,1) eq '#' then begin
	  r=0 & g=0 & b=0
	  reads,strmid(t,1,6),r,g,b,form='(3Z2)'	; In HEX.
	endif else begin
	  reads,t,r,g,b,form='(3I3)'			; In DECIMAL.
	endelse
 
	;-------  Set brightness  -------------
	fact = bright>0.<1.
	if bright ne 1 then begin
	  r = round(r*fact)
	  g = round(g*fact)
	  b = round(b*fact)
	endif
 
	;-------  Modify color table  --------------
	tvlct,r,g,b,indx
 
	return
	end
