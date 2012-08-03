;-------------------------------------------------------------
;+
; NAME:
;       RAOUT
; PURPOSE:
;       Write text along an arc in data coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       raout, r, a, text, [flag]
; INPUTS:
;       r = radius of bottom of text.    in
;       a = start angle of text.         in
;         Degrees CCW from X axis.
;       txt = text string to write.      in
;       flag = direction flag, 0 or 1.   in
;         0 = read CW (default), 1 = read CCW.
; KEYWORD PARAMETERS:
;       Keywords:
;         SIZE = sz.  Text size.
;         COLOR = clr.  Text color.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Data coordinates are used, so if the X and Y
;         scales differ the text will be written along an
;         ellipse, with the spacing varying.
; MODIFICATION HISTORY:
;       R. Sterner, 1 Jan, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro raout, r, a0, text, flag, size=sz, color=clr, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Write text along an arc in data coordinates.'
	  print,' raout, r, a, text, [flag]'
	  print,'   r = radius of bottom of text.    in'
	  print,'   a = start angle of text.         in'
	  print,'     Degrees CCW from X axis.
	  print,'   txt = text string to write.      in'
	  print,'   flag = direction flag, 0 or 1.   in'
	  print,'     0 = read CW (default), 1 = read CCW.'
	  print,' Keywords:'
	  print,'   SIZE = sz.  Text size.'
	  print,'   COLOR = clr.  Text color.'
	  print,' Notes: Data coordinates are used, so if the X and Y'
	  print,'   scales differ the text will be written along an'
	  print,'   ellipse, with the spacing varying.'
	  return
	endif
	 
	if n_params(0) lt 4 then flag = 0
	if n_elements(sz) eq 0 then sz = 1.
	if n_elements(clr) eq 0 then clr = 255 
 
	if flag eq 0 then begin
	  asign = 1.
	  aoff = 90.
	endif else begin
	  asign = -1.
	  aoff = 270.
	endelse
 
	b = byte(text)
 
	a = a0
 
	pfont = !p.font
	!p.font = -1
	xyouts,0,0,'!17',size=0
 
	for i = 1, n_elements(b) do begin
	  polrec, r, a/!radeg, x, y
	  xyouts, x, y, string(b(i-1)), orient=a+aoff, width=w, $
	    size=sz, color=clr
	  w = 1.2*w/!x.s(1)
	  da = asign*atan(w/r)*!radeg
	  a = a + da
	endfor
 
	!p.font = pfont
 
	return
 
	end
