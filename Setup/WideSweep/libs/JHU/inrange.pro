;-------------------------------------------------------------
;+
; NAME:
;       INRANGE
; PURPOSE:
;       Find multiples of given step just inside given range.
; CATEGORY:
; CALLING SEQUENCE:
;       inrange,stp, x1, x2, t1, t2, [tics]
; INPUTS:
;       stp = Step size.					in.
;       x1, x2 = Range limits.				in.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       t1, t2 = Multiples of STP just inside range.	out.
;       tics = optional array of tic values.		out.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 10 Nov, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro inrange, stp, x1, x2, t1, t2, ta,help=hlp
 
	if (n_params(0) lt 5) or (keyword_set(hlp)) then begin
	  print,' Find multiples of given step just inside given range.'
	  print,' inrange,stp, x1, x2, t1, t2, [tics]
	  print,'   stp = Step size.					in.
	  print,'   x1, x2 = Range limits.				in.
	  print,'   t1, t2 = Multiples of STP just inside range.	out.
	  print,'   tics = optional array of tic values.		out.
	  return
	endif
 
	dx = x2 - x1
	if dx eq 0.0 then begin
	  print,'Error in inrange: Range must be non-zero.'
	  return
	endif
	s = abs(stp)
 
	xmn = x1<x2
	xmx = x1>x2
 
	t1 = nearest(s, xmn) & if t1 lt xmn then t1 = t1 + s
	if t1 gt xmx then begin
	  print,'Error in inrange: No tics in range.'
	  return
	endif
	t2 = nearest(s, xmx) & if t2 gt xmx then t2 = t2 - s
	if t2 lt xmn then begin
	  print,'Error n inrange: No tics in range.'
	  return
	endif
	ta = makex(t1, t2, s)
 
	if dx lt 0 then begin
	  t = t1
	  t1 = t2
	  t2 = t
	  ta = reverse(ta)
	endif
 
	return
	end
