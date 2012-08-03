;-------------------------------------------------------------
;+
; NAME:
;       AATEXT
; PURPOSE:
;       Antialiased text routine.
; CATEGORY:
; CALLING SEQUENCE:
;       aatext,x,y,txt
; INPUTS:
;       x,y = text position.   in
;       txt = text.            in
; KEYWORD PARAMETERS:
;       Keywords:
;         Same as xyouts.
;         /NOAA no antialiasing.  Uses xyouts.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: works like xyouts but antialiased. Not as fast
;       as xyouts.  Internally uses img_text,
;       do help,img_text(/help) for more details.
;       May give x,y,txt,charsize, orientation and
;         alignment as arrays.
;       See also aaplot, aapoint, aaplotp.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jul 16
;       R. Sterner, 2002 Jul 23 --- Added /NOAA, No antialiased mode.
;       R. Sterner, 2002 Jul 25 --- Allowed align to be an array.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro aatext, x, y, txt, charsize=csz, orientation=ang, $
	  align=align, _extra=extra, noaa=noaa, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Antialiased text routine.'
	  print,' aatext,x,y,txt'
	  print,'   x,y = text position.   in'
	  print,'   txt = text.            in'
	  print,' Keywords:'
	  print,'   Same as xyouts.'
	  print,'   /NOAA no antialiasing.  Uses xyouts.'
	  print,' Notes: works like xyouts but antialiased. Not as fast'
	  print,' as xyouts.  Internally uses img_text,'
	  print,' do help,img_text(/help) for more details.'
	  print,' May give x,y,txt,charsize, orientation and'
	  print,'   alignment as arrays.'
	  print,' See also aaplot, aapoint, aaplotp.'
	  return
	endif
 
	;------  Defaults  --------------
	if n_elements(csz) eq 0 then csz=!p.charsize
	if n_elements(ang) eq 0 then ang=0.
	if n_elements(align) eq 0 then align=0.
 
	if keyword_set(noaa) then begin			; Not antialiased.
	  ;-------------------------------------------------
	  for i=0,n_elements(txt)-1 do begin
	    x2 = (x([i]))(0)
	    y2 = (y([i]))(0)
	    txt2 = (txt([i]))(0)
	    csz2 = (csz([i]))(0)
	    ang2 = (ang([i]))(0)
	    align2 = (align([i]))(0)
	    xyouts,x2,y2,txt2,charsize=csz2,orient=ang2,align=align2, $
	      _extra=extra
	  endfor
	  ;-------------------------------------------------
	endif else begin				; Antialiased.
	  a = tvrd(tr=1)				; Read current screen.
	  b = img_text(a,x,y,txt,charsize=csz,orient=ang, $
	    align=align, _extra=extra,/anti)
	  tv, b, tr=1					; Display result.
	endelse
 
	end
