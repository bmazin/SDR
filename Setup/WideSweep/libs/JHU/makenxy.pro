;-------------------------------------------------------------
;+
; NAME:
;       MAKENXY
; PURPOSE:
;       Make 2-d x and y coordinate arrays of specified dimensions.
; CATEGORY:
; CALLING SEQUENCE:
;       makenxy, x1, x2, nx, y1, y2, ny, xarray, yarray
; INPUTS:
;       x1 = min x coordinate in output rectangular array.  in
;       x2 = max x coordinate in output rectangular array.  in
;       nx = Number of steps in x.                          in
;       y1 = min y coordinate in output rectangular array.  in
;       y2 = max y coordinate in output rectangular array.  in
;       ny = Number of steps in y.                          in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xarray, yarray = resulting rectangular arrays.      out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Jul 11
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro makenxy, x1, x2, nx, y1, y2, ny, xa, ya, help=hlp
 
	if (n_params(0) lt 8) or keyword_set(hlp) then begin
	  print,' Make 2-d x and y coordinate arrays of specified dimensions.'
	  print,' makenxy, x1, x2, nx, y1, y2, ny, xarray, yarray
	  print,'   x1 = min x coordinate in output rectangular array.  in'
	  print,'   x2 = max x coordinate in output rectangular array.  in'
	  print,'   nx = Number of steps in x.                          in'
	  print,'   y1 = min y coordinate in output rectangular array.  in'
	  print,'   y2 = max y coordinate in output rectangular array.  in'
	  prinT,'   ny = Number of steps in y.                          in'
	  prinT,'   xarray, yarray = resulting rectangular arrays.      out'
	  return
	endif
 
	x = maken(x1, x2, nx)			; generate X array.
	y = transpose(maken(y1, y2, ny))	; generate Y array.
	xa = rebin(x, nx, ny)
	ya = rebin(y, nx, ny)
 
	return
 
	end
