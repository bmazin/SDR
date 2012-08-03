;-------------------------------------------------------------
;+
; NAME:
;       STRIPSHIFT
; PURPOSE:
;       Shift strips of an image in x or y.
; CATEGORY:
; CALLING SEQUENCE:
;       out = stripshift(in, ss, sa, flag)
; INPUTS:
;       in = input image.                                 in
;       ss = size of strip to shift in pixels.            in
;       sa = shift array, 1 value for each strip.         in
;       flag = optional direction flag. 0=x (def), 1=y.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = resulting shifted image.                    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  19 Apr, 1988.
;       R. Sterner, 26 Feb, 1991 --- Renamed from strip_shift.pro
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION STRIPSHIFT, IN, SS, SA, FLG, help=hlp
 
	IF (N_PARAMS(0) LT 3) or keyword_set(hlp) THEN BEGIN
	  print,' Shift strips of an image in x or y.'
	  print,' out = stripshift(in, ss, sa, flag)'
	  print,'   in = input image.                                 in'
	  print,'   ss = size of strip to shift in pixels.            in'
	  print,'   sa = shift array, 1 value for each strip.         in'
	  print,'   flag = optional direction flag. 0=x (def), 1=y.   in'
	  print,'   out = resulting shifted image.                    out'
	  RETURN, -1
	ENDIF
 
	IF N_PARAMS(0) LT 4 THEN FLG = 0	; Set default direction = x.
 
	SZ = SIZE(IN)				; Size of input image.
	NX = SZ(1)				; X size of image.
	NY = SZ(2)				; Y size of image.
	LSA = N_ELEMENTS(SA) - 1		; Last element in shift array.
 
	NSX = CEIL(NX/FLOAT(SS))		; Number of strips in X.
	NSY = CEIL(NY/FLOAT(SS))		; Number of strips in Y.
	OUT = IN
 
	IF FLG EQ 1 THEN begin			; To shift in Y, transpose.
	  OUT = TRANSPOSE(OUT)
	  t = nsx				; Switch number of strips.
	  nsx = nsy
	  nsy = t
	  ny = nx
	endif
 
	;-------  Shift each strip in X direction  --------
	  FOR I = 0, NSY-1 DO BEGIN		; Loop through each strip.
	    IY1 = I*SS				;   Bottom Y of strip i.
	    IY2 = (IY1 + SS - 1)<(NY-1)		;   Top Y of strip i.
	    IF SS EQ 1 THEN BEGIN		;   How many rows to shift?
	      OUT(0, IY1) = SHIFT( OUT(*,IY1:IY2), SA(I<LSA))	 ; 1 row.
	    ENDIF ELSE BEGIN
	      OUT(0, IY1) = SHIFT( OUT(*,IY1:IY2), SA(I<LSA), 0) ; mult rows.
	    ENDELSE
	  ENDFOR
 
	IF FLG EQ 1 THEN OUT = TRANSPOSE(OUT)	; If Y shift, transpose back.
 
	RETURN, OUT
	END
