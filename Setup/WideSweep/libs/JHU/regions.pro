;-------------------------------------------------------------
;+
; NAME:
;       REGIONS
; PURPOSE:
;       Using specified breakpoints map image values into 0,1,2,...
; CATEGORY:
; CALLING SEQUENCE:
;       b = regions(a,v)
; INPUTS:
;       a = input image.                         in
;       v = array of image value breakpoints.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /LIST lists processing progress.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: b is 0 where a lt v(0),
;         b is 1 where v(0) le a lt v(1), . . .
; MODIFICATION HISTORY:
;       R. Sterner. 1 Feb, 1987.
;       R. Sterner, 6 Mar, 1990 --- converted to SUN.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION REGIONS, A, V0, list=list, help=hlp
 
	if (n_params() lt 2) or keyword_set(help) then begin
	  print,' Using specified breakpoints map image values into 0,1,2,...'
	  print,' b = regions(a,v)'
	  print,'   a = input image.                         in'
	  print,'   v = array of image value breakpoints.    in'
	  print,' Keywords:'
	  print,'   /LIST lists processing progress.'
	  print,' Notes: b is 0 where a lt v(0),'
	  print,'   b is 1 where v(0) le a lt v(1), . . .'
	  return, -1
	endif
 
	V = V0					; Force V to be an array.
	FLAG = 0				; No verification.
	if keyword_set(list) then flag = 1	; Verify.
 
	L = N_ELEMENTS(V)-1			; Last V.
	IF L GT 255 THEN BEGIN
	  PRINT, ' Error in regions: too many regions, limit = 255.'
	  RETURN, -1
	ENDIF
 
	B = BYTE(A)				; Output map is byte array.
	T = N_ELEMENTS(B)/100.
 
	IF FLAG EQ 1 THEN BEGIN
	  PRINT,'  Setting pixels less than '+STRTRIM(V(0),2) $
	    + '  to 0...'
	ENDIF
	W = WHERE(A LT V(0),count)			; First region.
	IF (FLAG EQ 1) and (count gt 0) THEN $
	  PRINT,'   '+STRTRIM(N_ELEMENTS(W)/T)+' %.'
	if count gt 0 then B(W) = 0			; Always 0.
 
	IF L GE 1 THEN BEGIN				; More than 2 regions?
	  FOR I = 0, L-1 DO BEGIN			; Yes, loop thru them.
	    IF FLAG EQ 1 THEN BEGIN
	      PRINT,'  Setting pixels between ' + STRTRIM(V(I),2) + ' and ' $
	        + STRTRIM(V(I+1),2) + '  to ' + STRTRIM(I+1,2)+'...'
	    ENDIF
	    W = WHERE( (A GE V(I)) AND (A LT V(I+1)), count)	; Region pixls.
	    IF (FLAG EQ 1) and (count gt 0) THEN $
	      PRINT,'   '+STRTRIM(N_ELEMENTS(W)/T)+' %.'
	    if count gt 0 then B(W) = I + 1			; Map them.
	  ENDFOR
	ENDIF
 
	IF FLAG EQ 1 THEN BEGIN
	  PRINT,'  Setting pixels greater than '+STRTRIM(V(L),2) $
	    + '  to ' + STRTRIM(I+1,2)+'...'
	ENDIF
	W = WHERE(A GE V(L), count)				; Last region.
	IF (FLAG EQ 1) and (count gt 0) THEN $
	  PRINT,'   '+STRTRIM(N_ELEMENTS(W)/T)+' %.'
	if count gt 0 then B(W) = L+1
 
	RETURN, B
	END
