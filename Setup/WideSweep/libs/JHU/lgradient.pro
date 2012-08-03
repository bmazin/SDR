;-------------------------------------------------------------
;+
; NAME:
;       LGRADIENT
; PURPOSE:
;       Create a floating array with a linear gradient.
; CATEGORY:
; CALLING SEQUENCE:
;       g = lgradient( nx, ny, ang, dst)
; INPUTS:
;       nx, ny = array size in pixels.                  in
;       ang = angle of gradient (deg CCW from x axis).  in
;       dst = distance where gradient equals +/-1.      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       g = Returned floating array with gradient.      out
; COMMON BLOCKS:
; NOTES:
;       Notes: returned array is 0 at center and increases
;       to 1 at distance dst in direction ang, -1 at same
;       distance in opposite direction.  Intended for detrending:
;       new = old*(1+g) or new = old*(1+g*weight)
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Nov 3
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function lgradient, nx, ny, ang, dst, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Create a floating array with a linear gradient.'
	  print,' g = lgradient( nx, ny, ang, dst)
	  print,'   nx, ny = array size in pixels.                  in'
	  print,'   ang = angle of gradient (deg CCW from x axis).  in'
	  print,'   dst = distance where gradient equals +/-1.      in'
	  print,'   g = Returned floating array with gradient.      out'
	  print,' Notes: returned array is 0 at center and increases'
	  print,' to 1 at distance dst in direction ang, -1 at same'
	  print,' distance in opposite direction.  Intended for detrending:'
	  print,' new = old*(1+g) or new = old*(1+g*weight)'
	  return, ''
	endif
 
	if dst eq 0 then begin
	  print,' Error in lgradient: gradient distance of 0 not allowed.'
	  bell
	  return,-1
	endif
 
	nx2 = nx/2.
	ny2 = ny/2.
	makenxy,-nx2,nx2,nx,-ny2,ny2,ny,x,y
 
	cx = cos(ang/!radeg)/dst
	cy = sin(ang/!radeg)/dst
	
	g = cx*x + cy*y
 
	return, g
 
	end
