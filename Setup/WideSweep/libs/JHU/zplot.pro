;-------------------------------------------------------------
;+
; NAME:
;       ZPLOT
; PURPOSE:
;       Plot symbols in various colors.
; CATEGORY:
; CALLING SEQUENCE:
;       zplot, x, y, [z]
; INPUTS:
;       x, y = arrays of coordinates of symbols to plot.   in
;       z = array of symbol colors (def =!p.color).        in
; KEYWORD PARAMETERS:
;       Keywords:
;         PSYM=p  symbol number to plot.  Must have 0 < p < 8.
;         /DATA to work in data coordinates (default).
;         /DEVICE to work in device coordinates.
;         /NORMAL to work in normalized coordinates.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: z values should be from 0 to 255.
;         Z should have the same number of values as x and y.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 2 Feb, 1987 from ZPLOT.
;       Johns Hopkins University Applied Physics Laboratory.
;       R. Sterner, 18 Apr, 1990 --- converted to SUN.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO ZPLOT,X,Y,Z, help=hlp, psym=psym, device=dev, $
	  data=data, normal=norm
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot symbols in various colors.'
	  print,' zplot, x, y, [z]'
	  print,'   x, y = arrays of coordinates of symbols to plot.   in'
	  print,'   z = array of symbol colors (def =!p.color).        in'
	  print,' Keywords:'
	  print,'   PSYM=p  symbol number to plot.  Must have 0 < p < 8.'
	  print,'   /DATA to work in data coordinates (default).'
	  print,'   /DEVICE to work in device coordinates.'
	  print,'   /NORMAL to work in normalized coordinates.'
	  print,' Note: z values should be from 0 to 255.'
	  print,'   Z should have the same number of values as x and y.'
	  return
	end
 
	if n_elements(psym) eq 0 then psym = 3
 
	IF (PSYM LT 1) OR (PSYM GT 7) THEN BEGIN
	  PRINT,'Error in zplot: Must have 0 < PSYM < 8 (unconnected points).'
	  RETURN
	ENDIF
 
	N = N_PARAMS(0)
 
	IF N EQ 2 THEN BEGIN
	  PLOTs,X,Y, psym=psym
	  RETURN
	ENDIF
 
	Z2 = FIX(Z+.5)
	ZLO = MIN(Z2) > 0
	ZHI = MAX(Z2) < 255
 
	FOR IZ = ZLO, ZHI DO BEGIN
	  W = WHERE(Z2 EQ IZ, count)
	  if count gt 0 then begin
	    if keyword_set(norm) then begin
	      PLOTs,X(W),Y(W), color=iz, psym=psym, /norm
	      goto, skip
	    endif
	    if keyword_set(dev) then begin
	      PLOTs,X(W),Y(W), color=iz, psym=psym, /dev
	      goto, skip
	    endif
	    PLOTs,X(W),Y(W), color=iz, psym=psym
	  endif
skip:
	ENDFOR
 
	RETURN
 
	END
