;-------------------------------------------------------------
;+
; NAME:
;       REFRACT
; PURPOSE:
;       Correct true altitudes to refracted altitudes.
; CATEGORY:
; CALLING SEQUENCE:
;       altr = refract(alt)
; INPUTS:
;       alt = true altitude(s).        in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       altr = refracted altitude(s).  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Sep 16
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function refract, alt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Correct true altitudes to refracted altitudes.'
	  print,' altr = refract(alt)'
	  print,'   alt = true altitude(s).        in'
	  print,'   altr = refracted altitude(s).  out'
	  return,''
	endif
 
	r = fltarr(n_elements(alt))		; Set up correction array.
 
        ;************************************************
        ;*  For each of 5 altitude ranges compute       *
        ;*  refraction in arc minutes.                  *
        ;************************************************
 
	w = where(alt lt -0.575, c)
	if c gt 0 then r(w) = 34.5		; Correction in arc min.
 
	w = where((alt ge -0.575) and (alt lt 2.05334), c)
	if c gt 0 then r(w) = 402.5804*(alt(w)+5.55)^(-1.463659) - 3.9
 
	w = where((alt ge 2.05334) and (alt lt 8.39668), c)
        if c gt 0 then r(w) = 22.50426*exp(-0.2877606*alt(w)) + 4.26
 
	w = where((alt ge 8.39668) and (alt lt 88.525), c)
        if c gt 0 then r(w) = 36.17912*(alt(w)+0.2)^(-0.7421061) - 1.21
 
	w = where(alt ge 88.525, c)
	if c gt 0 then r(w) = 0.0
 
	;---------  Convert refraction from arc min to deg and add  -------
	altr = alt+r/60.
	if n_elements(altr) eq 1 then altr=altr(0)
	return, altr
 
	end
