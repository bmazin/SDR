;-------------------------------------------------------------
;+
; NAME:
;       MONTH2NAME
; PURPOSE:
;       Convert a month number to a month name.
; CATEGORY:
; CALLING SEQUENCE:
;       nam = month2name(num)
; INPUTS:
;       num = Month number (1-12).   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /FULL return full month name (else 3 character name).
;         /UPPER Convert to all upper case.
;         /LOWER Convert to all lower case.
; OUTPUTS:
;       nam = Month name.            out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Oct 05
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function month2name, num, help=hlp, full=full, upper=up, lower=low
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a month number to a month name.'
	  print,' nam = month2name(num)'
	  print,'   num = Month number (1-12).   in'
	  print,'   nam = Month name.            out'
	  print,' Keywords:'
	  print,'   /FULL return full month name (else 3 character name).'
	  print,'   /UPPER Convert to all upper case.'
	  print,'   /LOWER Convert to all lower case.'
	  return, ''
	endif
 
	tab = [monthnames(),'Error']	; Lookup table.
	out = tab(num>(-1)<13)		; Convert number to name.
 
	if not keyword_set(full) then out=strmid(out,0,3)
	if keyword_set(up) then out=strupcase(out)
	if keyword_set(low) then out=strlowcase(out)
 
	return, out
 
	end
