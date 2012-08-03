;-------------------------------------------------------------
;+
; NAME:
;       TVCIRC
; PURPOSE:
;       Draw a circle on the display.
; CATEGORY:
; CALLING SEQUENCE:
;       tvcirc, x, y, r
; INPUTS:
;       x,y = center of circle in device units.    in
;       r = Radius of circle in device units.      in
;           May be an array of radii.
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c  plot color (def=!p.color).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, Aug 1989
;       R. Sterner, 26 May, 1993 --- documented COLOR keyword and
;       allowed r to be an array.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro tvcirc, x, y, r, color=color, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Draw a circle on the display.'
	  print,' tvcirc, x, y, r'
	  print,'   x,y = center of circle in device units.    in'
	  print,'   r = Radius of circle in device units.      in'
	  print,'       May be an array of radii.'
	  print,' Keywords:'
	  print,'   COLOR=c  plot color (def=!p.color).'
	  return
	endif
 
	if n_elements(color) eq 0 then color = !p.color
 
	a = makex(0, 360, 2)/!radeg
 
	for i = 0, n_elements(r)-1 do begin
	  xx = x + r(i)*cos(a)
	  yy = y + r(i)*sin(a)
	  plots,xx,yy,/device,color=color
	endfor
 
	return
	end
	 
