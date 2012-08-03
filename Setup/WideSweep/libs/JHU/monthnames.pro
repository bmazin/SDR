;-------------------------------------------------------------
;+
; NAME:
;       MONTHNAMES
; PURPOSE:
;       Returns a string array of month names.
; CATEGORY:
; CALLING SEQUENCE:
;       mnam = monthnames([num])
; INPUTS:
;       num = optional month number (can be array).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /FULL return full month name (else 3 letters only).
;         /UPPER force all upper case (else mixed).
;         /LOWER force all lower case (else mixed).
; OUTPUTS:
;       mnam = returned month name(s).               out
;         if num not given returns string array of 13 items:
;         ['Error','January',...'December']
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 Sep, 1989
;       R. Sterner, 2001 May 24 --- Now returns name of given month.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function monthnames, num, upper=upper, lower=lower, full=full, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Returns a string array of month names.'
	  print,' mnam = monthnames([num])'
	  print,'   num = optional month number (can be array).  in'
	  print,'   mnam = returned month name(s).               out'
	  print,'     if num not given returns string array of 13 items:'
	  print,"     ['Error','January',...'December']"
	  print,' Keywords:'
	  print,'   /FULL return full month name (else 3 letters only).'
	  print,'   /UPPER force all upper case (else mixed).'
	  print,'   /LOWER force all lower case (else mixed).'
	  return, -1
	endif
 
	mn = ['Error','January','February','March','April','May',$
	      'June','July','August','September','October',$
	      'November','December']
 
	if n_elements(num) gt 0 then begin
	  nam = mn(num)
	  if not keyword_set(full) then nam=strmid(nam,0,3)
	  if keyword_set(upper) then nam=strupcase(nam)
	  if keyword_set(lower) then nam=strlowcase(nam)
	  return, nam
	endif else begin
	  return, mn
	endelse
 
	end
