;-------------------------------------------------------------
;+
; NAME:
;       LINEPTS
; PURPOSE:
;       Gives pixel coordinates of points along a line segment.
; CATEGORY:
; CALLING SEQUENCE:
;       linepts, ix1, iy1, ix2, iy2, x, y
; INPUTS:
;       ix1, iy1 = Coordinates of point 1.         in
;       ix2, iy2 = Coordinates of point 2.         in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x, y = arrays of coordinates along line.   out
; COMMON BLOCKS:
; NOTES:
;       Note: points 1 and 2 are scalars.
; MODIFICATION HISTORY:
;       R. Sterner,  9 May, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro linepts, ix1, iy1, ix2, iy2, jx, jy, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Gives pixel coordinates of points along a line segment.'
	  print,' linepts, ix1, iy1, ix2, iy2, x, y
	  print,'   ix1, iy1 = Coordinates of point 1.         in'
	  print,'   ix2, iy2 = Coordinates of point 2.         in'
	  print,'   x, y = arrays of coordinates along line.   out'
	  print,' Note: points 1 and 2 are scalars.'
	  return
	endif
 
	;---------  Single point?  -----------
	if (ix1 eq ix2) and (iy1 eq iy2) then begin
	  jx = intarr(1) + ix1
	  jy = intarr(1) + iy1
	  return
	end
 
	;------  size of line segment components.  --------
	idx = abs(ix2-ix1)
	idy = abs(iy2-iy1)
 
	;-----  want to step along longest component.  ---------
	if idx gt idy then begin		; Step along x.
	  jx = makei( fix(.5+ix1), fix(.5+ix2), sign(ix2-ix1))
	  t = maken( iy1, iy2, n_elements(jx))
	  w = where( t lt 0.0, cnt)		; values < 0 truncate upward.
	  if cnt gt 0 then t(w) = t(w) - 1.0	; so correct for this.
	  jy = fix(.5+t)
	endif else begin			; Step along y.
	  jy = makei( fix(.5+iy1), fix(.5+iy2), sign(iy2-iy1))
	  t = maken( ix1, ix2, n_elements(jy))
	  w = where( t lt 0.0, cnt)
	  if cnt gt 0 then t(w) = t(w) - 1.0
	  jx = fix(.5+t)
	endelse
 
	return
 
	end
