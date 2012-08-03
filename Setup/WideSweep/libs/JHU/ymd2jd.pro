;-------------------------------------------------------------
;+
; NAME:
;       YMD2JD
; PURPOSE:
;       From Year, Month, and Day compute Julian Day number.
; CATEGORY:
; CALLING SEQUENCE:
;       jd = ymd2jd(y,m,d)
; INPUTS:
;       y = Year (like 1987).                    in
;       m = month (like 7 for July).             in
;       d = month day (like 23).                 in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       jd = Julian Day number (like 2447000).   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  23 June, 1985 --- converted from FORTRAN.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function ymd2jd, iy, im, id, help=hlp
 
	if (n_params(0) LT 3) or keyword_set(hlp) then begin
	  print,' From Year, Month, and Day compute Julian Day number.'
	  print,' jd = ymd2jd(y,m,d)'
	  print,'   y = Year (like 1987).                    in'
	  print,'   m = month (like 7 for July).             in'
	  print,'   d = month day (like 23).                 in'
	  print,'   jd = Julian Day number (like 2447000).   out'
	  return, -1
	endif
 
	y = long(iy)
	m = long(im)
	d = long(id)
	jd = 367*y-7*(y+(m+9)/12)/4-3*((y+(m-9)/7)/100+1)/4 $
             +275*m/9+d+1721029
 
	return, jd
 
	end
