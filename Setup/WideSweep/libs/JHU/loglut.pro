;-------------------------------------------------------------
;+
; NAME:
;       LOGLUT
; PURPOSE:
;       Return a log lookup table useful for scaling images.
; CATEGORY:
; CALLING SEQUENCE:
;       lut = loglut(lo,hi)
; INPUTS:
;       lo = image value to map to 0.        in
;       hi = image value to map to 255.      in
;         where lo GE 0, hi GT lo.
; KEYWORD PARAMETERS:
;       Keywords:
;         EXPONENT=ex Controls curvature of transformation (def=1).
;           Use values in the range -15 to 15, 0 gives a straight
;           line, <0 negative curvature.
;         GLO=glo Min color to use: image value lo maps to glo.
;           Default is 0.
;         GHI=ghi Max color to use: image value hi maps to ghi.
;           Default is top available color.
;         /REVERSE means reverse color table.
;         /ROUND means round lookup table values to nearest integer.
; OUTPUTS:
;       lut = resulting lookup table.        out
; COMMON BLOCKS:
; NOTES:
;       Note: image values beyond given lo and hi get clipped.
;         Ex: let A be a 16 bit image with values ranging from
;         850 to 12000.  Assume the image values from 900 to
;         2000 are to be scaled to 0 to 255 using a log curve.
;         lut = loglut(900,2000,exp=1.5)  ; Set up table.
;         b = lut(a)                      ; Do scaling.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Nov 6
;       R. Sterner, 1998 Nov 10 --- Added /TOP.
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function loglut, lo, hi, exponent=ex0,glo=glo,ghi=ghi, $
	  round=round, reverse=rev, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return a log lookup table useful for scaling images.'
	  print,' lut = loglut(lo,hi)'
	  print,'   lo = image value to map to 0.        in'
	  print,'   hi = image value to map to 255.      in'
	  print,'     where lo GE 0, hi GT lo.'
	  print,'   lut = resulting lookup table.        out'
	  print,' Keywords:'
	  print,'   EXPONENT=ex Controls curvature of transformation (def=1).'
	  print,'     Use values in the range -15 to 15, 0 gives a straight'
	  print,'     line, <0 negative curvature.'
	  print,'   GLO=glo Min color to use: image value lo maps to glo.'
	  print,'     Default is 0.'
	  print,'   GHI=ghi Max color to use: image value hi maps to ghi.'
	  print,'     Default is top available color.'
	  print,'   /REVERSE means reverse color table.'
	  print,'   /ROUND means round lookup table values to nearest integer.'
	  print,' Note: image values beyond given lo and hi get clipped.'
	  print,'   Ex: let A be a 16 bit image with values ranging from'
	  print,'   850 to 12000.  Assume the image values from 900 to'
	  print,'   2000 are to be scaled to 0 to 255 using a log curve.'
	  print,'   lut = loglut(900,2000,exp=1.5)  ; Set up table.'
	  print,'   b = lut(a)                      ; Do scaling.'
	  return, ''
	endif
 
	if n_elements(ex0) eq 0 then ex0=1.
	ex = ex0
	if ex eq 0. then ex=1E-5
 
	if n_elements(glo) eq 0 then glo=0		; Def glo.
	if n_elements(ghi) eq 0 then ghi=topc()		; Def ghi.
	delta = ghi-glo
 
	logcrv = alog10(maken(1.,10D0^ex,hi-lo+1))	; Make log curve.
	logcrv = abs(logcrv)				; Keep > 0.
	logcrv = logcrv/max(logcrv)*delta		; Normalize.
	lut = fltarr(hi+1)+glo              		; Lookup table.
	lut(lo) = logcrv+glo				; Insert log curve.
	lut(hi) = ghi					; Avoid black top.	
 
	if keyword_set(round) then lut=round(lut)
	if keyword_set(rev) then lut=reverse(lut)
	return, lut
	end
