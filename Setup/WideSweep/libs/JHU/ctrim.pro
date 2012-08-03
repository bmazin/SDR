;-------------------------------------------------------------
;+
; NAME:
;       CTRIM
; PURPOSE:
;       Do a circular trim on an array.
; CATEGORY:
; CALLING SEQUENCE:
;       b = ctrim(a)
; INPUTS:
;       a = input array.           in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = output trimmed array.  out
; COMMON BLOCKS:
; NOTES:
;       Note: if input array is not square then
;         trimmed array is elliptical.
; MODIFICATION HISTORY:
;       R. Sterner.  24 May, 1987.
;       Johns Hopkins University Applied Physics Laboratory.
;       R. Sterner, 25 Jan 1990 --- converted to SUN.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION CTRIM, A, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Do a circular trim on an array.'
	  print,' b = ctrim(a)'
	  print,'   a = input array.           in'
	  print,'   b = output trimmed array.  out'
	  print,' Note: if input array is not square then'
	  print,'   trimmed array is elliptical.'
	  return, -1
	endif
 
	SZ = SIZE(A)			; want shape and size of A.
 
	SXY = SZ(1:2)			; array size in X and Y.
	S = MAX(SXY)			; Use max.
	S2 = S/2			; Initial mask radius.
 
	D = SHIFT( DIST(S), S2, S2)	; distance array.
 
	IF SXY(0) NE SXY(1) THEN BEGIN
	  D = CONGRID(D, SXY(0), SXY(1)) ; shape distance array to input array.
	ENDIF
 
	M = D LE S2			; mask.
 
	RETURN, A*M
	END
