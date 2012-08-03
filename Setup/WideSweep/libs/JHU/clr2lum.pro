;-------------------------------------------------------------
;+
; NAME:
;       CLR2LUM
; PURPOSE:
;       Compute luminance from a 24-bit color value.
; CATEGORY:
; CALLING SEQUENCE:
;       lum = clr2lum(lum)
; INPUTS:
;       clr = 24-bit color value.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /BW  Return the color white if lum < 128 else black.
;              The gives a contrasting color for things like text.
; OUTPUTS:
;       lum = returned luminance.   out
;         Range is Min=0., Max=255.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Mar 12
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function clr2lum, clr, bw=bw, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Compute luminance from a 24-bit color value.'
	  print,' lum = clr2lum(lum)'
	  print,'   clr = 24-bit color value.   in'
	  print,'   lum = returned luminance.   out'
	  print,'     Range is Min=0., Max=255.'
	  print,' Keywords:'
	  print,'   /BW  Return the color white if lum < 128 else black.'
	  print,'        The gives a contrasting color for things like text.'
	  return,''
	endif
 
	c2rgb, clr, r, g, b		; Break color value into r,g,b.
 
	lum = 0.3*r + 0.59*g + 0.11*b	; Compute luminance.
 
	if keyword_set(bw) then begin
	  out = long(clr)
	  wd = where(lum lt 128, cd, comp=wb, ncomp=cb)
	  if cb gt 0 then out(wb)=0
	  if cd gt 0 then out(wd)=tarclr(255,255,255)
	  return, out
	endif else begin
	  return, lum
	endelse
 
	end
