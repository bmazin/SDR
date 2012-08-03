;-------------------------------------------------------------
;+
; NAME:
;       SUN_SHADE
; PURPOSE:
;       Make a colored shaded relief view of a surface array.
; CATEGORY:
; CALLING SEQUENCE:
;       relief = sun_shade(surf, [alt, azi, smin, smax])
; INPUTS:
;       surf = Surface array.                          in
;       alt = Optional sun altitude (def = 60).        in
;       azi = Optional sun azimuth (def = 135).        in
;       smin = Optional min value to use for scaling.  in
;       smax = Optional max value to use for scaling.  in
;         If not specified the array min and max are used.
;         These are useful to insure that different data
;         arrays are scaled the same.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       relief = Shaded relief image.                  out
; COMMON BLOCKS:
; NOTES:
;       Note: Use shade_clt to get proper color table.
; MODIFICATION HISTORY:
;       J. Culbertson, 15 Feb, 1989.
;       Re-entered by RES.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 31 Aug, 1989 --- converted to SUN.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION SUN_SHADE, D, ALT, AZI, EMIN, EMAX, help=hlp
 
	NP = N_PARAMS(0)
	IF (NP lt 1) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Make a colored shaded relief view of a surface array.'
	  PRINT,' relief = sun_shade(surf, [alt, azi, smin, smax])
	  PRINT,'   surf = Surface array.                          in
	  PRINT,'   alt = Optional sun altitude (def = 60).        in
	  PRINT,'   azi = Optional sun azimuth (def = 135).        in
	  PRINT,'   smin = Optional min value to use for scaling.  in
	  PRINT,'   smax = Optional max value to use for scaling.  in
	  PRINT,'     If not specified the array min and max are used.
	  PRINT,'     These are useful to insure that different data
	  PRINT,'     arrays are scaled the same.
	  PRINT,'   relief = Shaded relief image.                  out
	  print,' Note: Use shade_clt to get proper color table.'
	  RETURN, -1
	ENDIF
 
	IF NP LT 2 THEN ALT = 60
	IF NP LT 3 THEN AZI = 135
	IF NP LT 4 THEN EMIN = MIN(D)
	IF NP LT 5 THEN EMAX = MAX(D)
 
	print,' Shading surface with alt='+strtrim(alt,2)+$
	  ' and azi='+strtrim(azi,2)+' . . .'
	II = (16.0/(EMAX-EMIN))*(D-EMIN)
	II = FIX(II)<15>0
 
	S = DOT(D, AZI, ALT)
	SMIN = MIN(S)
	SMAX = MAX(S)
 
	JJ = (16.0/(SMAX-SMIN))*(S-SMIN)
	JJ = FIX(JJ)<15>0
 
	R = BYTE(16*II + JJ)
	w = where(d eq 0)
	if w(0) ne -1 then R(W) = 1
 
	RETURN, R
	END
