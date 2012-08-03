;-------------------------------------------------------------
;+
; NAME:
;       DMS_FORM
; PURPOSE:
;       Convert degrees to a deg, min, sec vector font string.
; CATEGORY:
; CALLING SEQUENCE:
;       dms = dms_form(deg)
; INPUTS:
;       deg = degrees and decimal fraction.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NOSEC     Means suppress seconds.
;         DEGREES=n  Force n digits in degrees, fill with 0s.
;         FONT=fnt   Specify font string (def=!17).
; OUTPUTS:
;       dms = string to be printed by xyouts   out
;         using vector font.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 22 Sep, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function dms_form, deg0, nosec=nosec, font=fnt, degrees=deg, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert degrees to a deg, min, sec vector font string.'
	  print,' dms = dms_form(deg)'
	  print,'   deg = degrees and decimal fraction.    in'
	  print,'   dms = string to be printed by xyouts   out'
	  print,'     using vector font.'
	  print,' Keywords:'
	  print,'   /NOSEC     Means suppress seconds.'
	  print,'   DEGREES=n  Force n digits in degrees, fill with 0s.'
	  print,'   FONT=fnt   Specify font string (def=!17).'
	  return, -1
	endif
 
	if n_elements(fnt) eq 0 then fnt = '!17'
 
	sn = fix(deg0 gt 0.) - fix(deg0 lt 0.)	; Sign (-1: <0, 0: =0, 1: >0)
	d0 = abs(deg0)				; Force > 0.
 
	d = fix(d0)				; Just degrees.
	fmt = '(I)'				; Def. deg format.
	if n_elements(deg) ne 0 then begin	; Add leading 0s.
	  if deg eq 2 then fmt = '(I2.2)'	; 2 place deg.
	  if deg eq 3 then fmt = '(I3.3)'	; 3 place deg.
	endif
	dms = strtrim(string(d,form=fmt),2)	; Deg string.
	if sn lt 0 then dms = '-' + dms		; Handle sign.
	dms = fnt+dms+'!Eo!N'+fnt		; Add font and deg symbol.
 
	m0 = 60.*(d0- d) + .001			; Minutes + fraction.
	add = 0.				; Assume no ronuding.
	if keyword_set(nosec) then add = .5	; No sec, so round.
	m = fix(m0+add)				; Just minutes.
	dms = dms+' '+string(m,form='(I2.2)')+"'"	; Add min string.
 
	if keyword_set(nosec) then return, dms
 
	s0 = 60.*(m0 - m)			; Seconds + fraction.
	s = fix(s0)				; Just seconds.
	dms = dms+' '+string(s,form='(I2.2)')+'"'	; Add sec string.
 
	return, dms
 
	end
