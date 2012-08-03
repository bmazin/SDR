;-------------------------------------------------------------
;+
; NAME:
;       IMAGESIZE
; PURPOSE:
;       Compute actual postscript image size given available space.
; CATEGORY:
; CALLING SEQUENCE:
;       imagesize, xmx, ymx, arr, xout, yout
; INPUTS:
;       xmx = max postscript X image size available in cm.    in
;       ymx = max postscript Y image size available in cm.    in
;       arr = image to display.                               in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xout = image X size in cm that fits in given space.   out
;       yout = image Y size in cm that fits in given space.   out
; COMMON BLOCKS:
; NOTES:
;       Note: use for postscript tv, arr, xsize=xout, ysize=yout.
; MODIFICATION HISTORY:
;       R. Sterner, 11 Mar, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro imagesize, xmx, ymx, arr, xout, yout, help=hlp
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' Compute actual postscript image size given available space.'
	  print,' imagesize, xmx, ymx, arr, xout, yout'
	  print,'   xmx = max postscript X image size available in cm.    in'
	  print,'   ymx = max postscript Y image size available in cm.    in'
	  print,'   arr = image to display.                               in'
	  print,'   xout = image X size in cm that fits in given space.   out'
	  print,'   yout = image Y size in cm that fits in given space.   out'
	  print,' Note: use for postscript tv, arr, xsize=xout, ysize=yout.'
	  return
	endif
 
	sz = size(arr)
	nx = float(sz(1))
	ny = float(sz(2))
 
	if (nx/ny) ge (xmx/ymx) then begin
	  xout = 16.
	  yout = (ny/nx)*xmx
	endif else begin
	  yout = ymx
	  xout = (nx/ny)*ymx
	endelse
 
	return
	end
