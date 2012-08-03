;-------------------------------------------------------------
;+
; NAME:
;       AAPLOT
; PURPOSE:
;       Antialiased plot routine.
; CATEGORY:
; CALLING SEQUENCE:
;       aaplot,x,y
; INPUTS:
;       x,y = x,y arrays to plot.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         Same as plot.
;         /NOAA no antialiasing.  Uses plot.  Does not
;           erase screen first.  Also default window is
;           slightly different with and without /NOAA.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: works much like plot but antialiased. Not as fast
;       as plot.  Does not erase screen before plot. Also
;       default plot position is not exactly same as plot.
;       See also aaplotp, aapoint, aatext.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jul 16
;       R. Sterner, 2002 Jul 23 --- Added /NOAA, No antialiased mode.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro aaplot, x0, y0, _extra=extra, noaa=noaa, help=hlp
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Antialiased plot routine.'
	  print,' aaplot,x,y'
	  print,'   x,y = x,y arrays to plot.   in'
	  print,' Keywords:'
	  print,'   Same as plot.'
	  print,'   /NOAA no antialiasing.  Uses plot.  Does not'
	  print,'     erase screen first.  Also default window is'
	  print,'     slightly different with and without /NOAA.'
	  print,' Notes: works much like plot but antialiased. Not as fast'
	  print,' as plot.  Does not erase screen before plot. Also'
	  print,' default plot position is not exactly same as plot.'
	  print,' See also aaplotp, aapoint, aatext.'
	  return
	endif
 
	if n_elements(y0) eq 0 then begin
	  y = x0
	  x = findgen(n_elements(y))
	endif else begin
	  x = x0
	  y = y0
	endelse 
 
	if keyword_set(noaa) then begin			; Not antialiased.
	  plot, x, y, /noerase, _extra=extra
	endif else begin				; Antialiased.
	  a = tvrd(tr=1)				; Read current screen.
	  b = img_plot(a,x,y,_extra=extra,/anti)	; Do plot.
	  tv, b, tr=1					; Display result.
	endelse
 
	end
