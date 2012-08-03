;-------------------------------------------------------------
;+
; NAME:
;       AAPOINT
; PURPOSE:
;       Antialiased point routine.
; CATEGORY:
; CALLING SEQUENCE:
;       aaplotp,x,y,z
; INPUTS:
;       x,y = position of point.  May be arrays.   in
;       z = optional z coordinate (def=0).         in
;         If z is given /T3D must also be used.
; KEYWORD PARAMETERS:
;       Keywords:
;         Same as point.
;         /NOAA no antialiasing. Uses point.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: works like point but antialiased. Not as fast
;       as point.
;       See also aaplot, aaplotp, aatext.
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
	pro aapoint, x, y, z, _extra=extra, noaa=noaa, help=hlp
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Antialiased point routine.'
	  print,' aaplotp,x,y,z'
	  print,'   x,y = position of point.  May be arrays.   in'
	  print,'   z = optional z coordinate (def=0).         in'
	  print,'     If z is given /T3D must also be used.'
	  print,' Keywords:'
	  print,'   Same as point.'
	  print,'   /NOAA no antialiasing. Uses point.'
	  print,' Notes: works like point but antialiased. Not as fast'
	  print,' as point.'
	  print,' See also aaplot, aaplotp, aatext.'
	  return
	endif
 
	if keyword_set(noaa) then begin			; Not antialiased.
	  point,x,y,z,_extra=extra
	endif else begin				; Antialiased.
	  a = tvrd(tr=1)				; Read current screen.
	  b = img_point(a,x,y,z,_extra=extra,/anti)	; Do point.
	  tv, b, tr=1					; Display result.
	endelse
 
	end
