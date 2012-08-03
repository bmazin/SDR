;-------------------------------------------------------------
;+
; NAME:
;       ERASEWIN
; PURPOSE:
;       Erase plot window to a given color.
; CATEGORY:
; CALLING SEQUENCE:
;       erasewin, clr
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Must have a plot window.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Sep 08
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro erasewin, clr, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Erase plot window to a given color.'
	  print,' erasewin, clr'
	  print,'    clr = color to erase to (def=0).'
	  print,' Notes: Must have a plot window.'
	  return
	endif
 
	if n_elements(clr) eq 0 then clr=0
 
	ix1 = !x.window(0)*!d.x_size
	iy1 = !y.window(0)*!d.y_size
	ix2 = !x.window(1)*!d.x_size
	iy2 = !y.window(1)*!d.y_size
 
	polyfill,/device,[ix1,ix2,ix2,ix1],[iy1,iy1,iy2,iy2],col=clr
 
	end
