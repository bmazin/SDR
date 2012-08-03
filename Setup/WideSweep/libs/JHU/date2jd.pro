;-------------------------------------------------------------
;+
; NAME:
;       DATE2JD
; PURPOSE:
;       Convert a date string to Julian Day number.
; CATEGORY:
; CALLING SEQUENCE:
;       jd = date2jd(date)
; INPUTS:
;       date = date string.                in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       jd = Returned Julian Day number.   out
;         Returns 0 on error.
; COMMON BLOCKS:
; NOTES:
;       Note: date must contain month as a name of 3 or more letters.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Sep 15
;       R. Sterner, 1999 Aug 4 --- Improved 2 digit year case.
;       R. Sterner, 2003 Aug 27 --- Better error checking.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function date2jd, date, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a date string to Julian Day number.'
	  print,' jd = date2jd(date)'
	  print,'   date = date string.                in'
	  print,'   jd = Returned Julian Day number.   out'
	  print,'     Returns 0 on error.'
	  print,' Note: date must contain month as a name of 3 or more letters.'
	  return,''
	endif
 
	date2ymd,date,y,m,d
	if min(y) lt 0 then begin
	  print,' Error in date2jd: input date not understood.'
	  return, 0
	endif
 
	y = yy2yyyy(y)			; Deal with 2 digit years.
 
	return, ymd2jd(y,m,d)
	end
