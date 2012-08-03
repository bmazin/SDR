;-------------------------------------------------------------
;+
; NAME:
;       TRAPI
; PURPOSE:
;       Trapizoidal integration for irregularly spaced values.
; CATEGORY:
; CALLING SEQUENCE:
;       out = trapi(x, y)
; INPUTS:
;       x = Array of X values.                   in
;       y = Array of function values at each X.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /CUMULATIVE means return the cumulative integral,
;           else the total integral.
;         /DOUBLE work in double precision.
; OUTPUTS:
;       out = Output value.                      out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 21
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function trapi, x, y, cumulative=cum, double=dbl, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Trapizoidal integration for irregularly spaced values.'
	  print,' out = trapi(x, y)'
	  print,'   x = Array of X values.                   in'
	  print,'   y = Array of function values at each X.  in'
	  print,'   out = Output value.                      out'
	  print,' Keywords:'
	  print,'   /CUMULATIVE means return the cumulative integral,'
	  print,'     else the total integral.'
	  print,'   /DOUBLE work in double precision.'
	  return,''
	endif
 
	if keyword_set(dbl) then x1=double(x(1:*)) else x1=x(1:*)
	if keyword_set(dbl) then y1=double(y(1:*)) else y1=y(1:*)
	d = x1-x
	s = y1+y
 
	return, 0.5*total(s*d,double=dbl,cumulative=cum)
 
	end
