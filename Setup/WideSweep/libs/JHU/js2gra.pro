;-------------------------------------------------------------
;+
; NAME:
;       JS2GRA
; PURPOSE:
;       Greenwich RA (radians). Greenwich Mean Sidereal Time (GMST).
; CATEGORY:
; CALLING SEQUENCE:
;       ra = js2gra(js)
; INPUTS:
;       js = UT in Julian Seconds.                in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ra = RA of Greenwich meridian in radians. out
; COMMON BLOCKS:
; NOTES:
;       Note: RA is Right Ascension.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Jul 27
;       R. Sterner, 2000 Aug 08 --- Radians.
;       R. Sterner, 2003 Oct 29 --- Better help text.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function js2gra, js, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Greenwich RA (radians). Greenwich Mean Sidereal Time (GMST).'
	  print,' ra = js2gra(js)'
	  print,'   js = UT in Julian Seconds.                in'
	  print,'   ra = RA of Greenwich meridian in radians. out'
	  print,' Note: RA is Right Ascension.'
	  return,''
	endif
 
	return,(1.7447671941556D0 + js*7.292115854937D-05) mod 6.2831853071796D0
 
	end
