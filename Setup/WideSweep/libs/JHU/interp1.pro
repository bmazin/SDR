;-------------------------------------------------------------
;+
; NAME:
;       INTERP1
; PURPOSE:
;       Linear interpolation.
; CATEGORY:
; CALLING SEQUENCE:
;       y2 = interp1(x,y,x2)
; INPUTS:
;       x,y = x and y arrays for a function.       in
;       x2 = array of desired x values.            in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       y2 = array of interpolated y values.       out
; COMMON BLOCKS:
; NOTES:
;       Notes: y2 has the same number of elements as x2.
;         Out of range values in x2 are clipped to the range
;         of x.  Arrays x and y need not be monotonic or
;         single valued.  The output array, y2, has the same
;         data type as x2 (not y).
; MODIFICATION HISTORY:
;       R. Sterner, 28 Feb, 1985.
;       B. L. Gotwols 22-feb-1990 modified to handle out of range.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function interp1,x,y,t, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Linear interpolation.'
	  print,' y2 = interp1(x,y,x2)
	  print,'   x,y = x and y arrays for a function.       in'
	  print,'   x2 = array of desired x values.            in'
	  print,'   y2 = array of interpolated y values.       out'
	  print,' Notes: y2 has the same number of elements as x2.'
  	  print,'   Out of range values in x2 are clipped to the range'
	  print,'   of x.  Arrays x and y need not be monotonic or'
	  print,'   single valued.  The output array, y2, has the same'
	  print,'   data type as x2 (not y).'
	  return, 0
	endif
 
	;--------  Error checking  -----------
	if n_elements(x) ne n_elements(y) then begin   ; size check.
	  print,' Error in interp1: x and y arrays must be same size.'
	  return,0
	endif
 
	ntmax = n_elements(t) - 1
	nxmax = n_elements(x) - 1
 
	if nxmax le 0 then begin
	  print,' Error in interp1: The input arrays must have > 1 element.'
	  return, 0
	endif
 
	sizet = size(t)
	if sizet(0) ne 1 then begin
	  print,' Error in interp1: Interpolation X array must be a 1-d array'
	  return, 0
	endif
 
	;--------  Sort input curve  ---------
	jj=sort(x)
	xs = x(jj)	; xx will be monotonically increasing
	ys = y(jj)	; The y values sorted according to xx
 
	;--------  Loop through requested points interpolating  -----
	yt = t		; The output array has same type as the input t array
	for i = 0L, ntmax do begin
	    j = where(xs ge t(i))
	    j=j(0)				; Want just the first index
	    case 1 of
	        j eq -1:  yt(i) = ys(nxmax)	; t(i) is off the top end
	        j eq  0:  yt(i) = ys(0)		; t(i) is off or at low end
		else: begin			; Within the x array
		    m = (ys(j) - ys(j-1))/(xs(j) - xs(j-1))
		    yt(i) = m*(t(i) - xs(j-1)) + ys(j-1)  ; Linear interpolation
		    end
	    endcase
	endfor
 
	return,yt
	END
 
