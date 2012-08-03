;-------------------------------------------------------------
;+
; NAME:
;       CM2NORM
; PURPOSE:
;       Convert from cm to normalized coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       cm2norm, xcm, ycm, xn, yn
; INPUTS:
;       xcm, ycm = coordinates of a point in cm.   in
;       poscm = plot page position in cm.          in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xn, yn = same point in normalized system.  out
;       or
;       cm2norm, poscm, posn
;         posn = page position in normalized system. out
;           the page position arrays have the format: [x1,y1,x2,y2]
;           where (x1,y1) = lower left corner,
;           and (x2,y2) = upper right corner of plot area.
; COMMON BLOCKS:
; NOTES:
;       Notes: Be sure plot device is set first.
;         For postscript plots call psinit first.
; MODIFICATION HISTORY:
;       R. Sterner 13 Nov, 1989
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro cm2norm, a1, a2, a3, a4, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert from cm to normalized coordinates.'
	  print,' cm2norm, xcm, ycm, xn, yn'
	  print,'   xcm, ycm = coordinates of a point in cm.   in'
	  print,'   xn, yn = same point in normalized system.  out'
	  print,' or'
	  print,' cm2norm, poscm, posn'
	  print,'   poscm = plot page position in cm.          in'
	  print,'   posn = page position in normalized system. out'
	  print,'     the page position arrays have the format: [x1,y1,x2,y2]'
	  print,'     where (x1,y1) = lower left corner,
	  print,'     and (x2,y2) = upper right corner of plot area.'
	  print,' Notes: Be sure plot device is set first.'
	  print,'   For postscript plots call psinit first.'
	  return
	endif
 
	fx = !d.x_px_cm/!d.x_size
	fy = !d.y_px_cm/!d.y_size
 
	;-----  position parameter  -------
	if n_params(0) eq 2 then begin
	  a2 = a1*[fx,fy,fx,fy]
	  return
	endif
 
	;----- x,y ----------
	if n_params(0) eq 4 then begin
	  a3 = a1*fx
	  a4 = a2*fy
	  return
	endif
 
	print,' Error in cm2norm: must call with 2 or 4 args.'
	return
	  
	end
