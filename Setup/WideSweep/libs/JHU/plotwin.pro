;-------------------------------------------------------------
;+
; NAME:
;       PLOTWIN
; PURPOSE:
;       Gives plot window (area enclosed by axes) in pixels.
; CATEGORY:
; CALLING SEQUENCE:
;       plotwin, px0, py0, dpx, dpy
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  Error flag: 0=ok, 1=no plot yet.
; OUTPUTS:
;       px0, py0 = window lower-left corner coord. (pixels).   out
;       dpx, dpy = window size in pixels.                      out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 13 Dec, 1989
;       R. Sterner, 2007 Jul 05 --- Removed CHARSIZE=csz, Added ERROR=err.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro plotwin, px0, py0, dpx, dpy, error=err, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Gives plot window (area enclosed by axes) in pixels.'
	  print,' plotwin, px0, py0, dpx, dpy'
	  print,'   px0, py0 = window lower-left corner coord. (pixels).   out'
	  print,'   dpx, dpy = window size in pixels.                      out'
	  print,' Keywords:'
	  print,'   ERROR=err  Error flag: 0=ok, 1=no plot yet.'
	  return
	endif
 
	if max (!x.window) eq 0 then begin
	  err = 1
	  px0 = 0
	  py0 = 0
	  dpx = 0
	  dpy = 0
	  return
	endif
 
	err = 0
 
	px0 = !x.window(0)*!d.x_size
	py0 = !y.window(0)*!d.y_size
	dpx = !x.window(1)*!d.x_size - px0
	dpy = !y.window(1)*!d.y_size - py0
 
	return
	end
