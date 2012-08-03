;-------------------------------------------------------------
;+
; NAME:
;       F2FI16
; PURPOSE:
;       Convert feet to feet, inches, and fractions to 1/16 inch.
; CATEGORY:
; CALLING SEQUENCE:
;       s = f2fi16(f)
; INPUTS:
;       f = distance in feet.            in
; KEYWORD PARAMETERS:
;       Keywords:
;         MIN_INCHES=d convert values < d to mm.
;         MAX_MILES=D convert values > D to miles.
; OUTPUTS:
;       s = distance as a text string.   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 4 Oct, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 13 Sep, 1989 --- converted to SUN.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION F2FI16, FEET, min_inches=mi, max_miles=mxm, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert feet to feet, inches, and fractions to 1/16 inch.'
	  print,' s = f2fi16(f)'
	  print,'   f = distance in feet.            in'
	  print,'   s = distance as a text string.   out'
	  print,' Keywords:'
	  print,'   MIN_INCHES=d convert values < d to mm.'
	  print,'   MAX_MILES=D convert values > D to miles.'
	  return, -1
	endif
 
	;-------  convert small values to mm  ------------
	inch = feet*12.
	if keyword_set(mi) then begin
	  if inch lt mi then begin
	    s = string(inch*25.4,'$(f6.2)')
	    s = strtrim(s,2)+ ' mm'
	    return, s
	  endif
	endif 
 
	;-------  convert large values to miles  ------------
	miles = feet/5280.
	if keyword_set(mxm) then begin
	  if miles gt mxm then begin
	    s = string(miles,'$(f10.2)')
	    s = strtrim(s,2)+ ' miles'
	    return, s
	  endif
	endif 
 
	FR = ['Error','1/16 ','1/8  ','3/16 ','1/4  ','5/16 ','3/8  ','7/16 ',$
	      '1/2  ','9/16 ','5/8  ','11/16','3/4  ','13/16','7/8  ','15/16']
 
	sn = ' '
	if feet lt 0. then sn = '-'
	feet = abs(feet)
 
	T = LONG(FEET)
	I = 12.0*(FEET-T)
	F = FIX(.5 + 16*(I-FIX(I)))
	IF F EQ 16 THEN BEGIN
	  I = I + 1
	  F = 0
	ENDIF
 
	S = sn + STRTRIM(T,2)+"'"
	IF ((F GT 0) OR (I GT 0)) THEN S = S+' '+STRTRIM(FIX(I),2)+'"'
	IF F GT 0 THEN S = S + FR(F)
 
	RETURN, S
	END
