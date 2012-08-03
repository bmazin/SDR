;-------------------------------------------------------------
;+
; NAME:
;       SMOOTH2
; PURPOSE:
;       Do multiple smoothing. Gives near Gaussian smoothing.
; CATEGORY:
; CALLING SEQUENCE:
;       b = smooth2(a, w)
; INPUTS:
;       a = array to smooth (1,2, or 3-d).  in
;       w = smoothing window size.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         /FILL_ENDS fill end effects.
; OUTPUTS:
;       b = smoothed array.                 out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  8 Jan, 1987.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES  14 Jan, 1987 --- made both 2-d and 1-d.
;       RES 30 Aug, 1989 --- converted to SUN.
;       R. Sterner, 1994 Feb 22 --- cleaned up some.
;       R. Sterner, 2006 Aug 18 --- Added keyword /FILL_ENDS.
;       R. Sterner, 2006 Aug 20 --- Corrected to length to fill.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function smooth2, i, w, fill_ends=fill_ends, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp)  then begin
	  print,' Do multiple smoothing. Gives near Gaussian smoothing.'
	  print,' b = smooth2(a, w)'
	  print,'   a = array to smooth (1,2, or 3-d).  in'
	  print,'   w = smoothing window size.          in'
	  print,'   b = smoothed array.                 out'
	  print,' Keywords:'
	  print,'   /FILL_ENDS fill end effects.'
	  return, -1
	endif
 
	w1 = w > 2
	w2 = w/2 > 2
 
	i2 = smooth(i, w1)
	i2 = smooth(i2, w1)
	i2 = smooth(i2, w2)
	i2 = smooth(i2, w2)
 
	if keyword_set(fill_ends) then begin
	  lst = n_elements(i2)-1	; Last index.
	  e = (floor(w/4.)*2)>4		; Number of samples to fill.
	  i2(0:e-1) = i2(e)		; Fill start of array.
	  i2(lst-e+1:*) = i2(lst-e)	; Fill end of array.
	endif
		
	return, i2
	end
