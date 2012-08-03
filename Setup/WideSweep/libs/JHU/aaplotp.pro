;-------------------------------------------------------------
;+
; NAME:
;       AAPLOTP
; PURPOSE:
;       Antialiased plotp routine.
; CATEGORY:
; CALLING SEQUENCE:
;       aaplotp,x,y,p
; INPUTS:
;       x,y = x,y arrays to plot.   in
;       p = optional pencode array. in
;         0: move to point, 1: draw to point.
; KEYWORD PARAMETERS:
;       Keywords:
;         Same as plotp.
;         /NOAA no antialiasing.  Uses plotp.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: works like plotp but antialiased. Not as fast
;       as plotp.
;       See also aaplot, aapoint, aatext.
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
	pro aaplotp, x, y, p, _extra=extra, noaa=noaa, help=hlp
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Antialiased plotp routine.'
	  print,' aaplotp,x,y,p'
	  print,'   x,y = x,y arrays to plot.   in'
	  print,'   p = optional pencode array. in'
	  print,'     0: move to point, 1: draw to point.'
	  print,' Keywords:'
	  print,'   Same as plotp.'
	  print,'   /NOAA no antialiasing.  Uses plotp.'
	  print,' Notes: works like plotp but antialiased. Not as fast'
	  print,' as plotp.'
	  print,' See also aaplot, aapoint, aatext.'
	  return
	endif
 
	if keyword_set(noaa) then begin			; Not antialiased.
	  plotp,x,y,p,_extra=extra
	endif else begin				; Antialiased.
	  a = tvrd(tr=1)				; Read current screen.
	  b = img_plotp(a,x,y,p,_extra=extra,/anti)	; Do plotp.
	  tv, b, tr=1					; Display result.
	endelse
 
	end
