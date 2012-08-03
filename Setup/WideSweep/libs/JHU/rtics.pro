;-------------------------------------------------------------
;+
; NAME:
;       RTICS
; PURPOSE:
;       Plot labeled or unlabeled tic marks around a circular arc.
; CATEGORY:
; CALLING SEQUENCE:
;       rtics, a1, a2, da, r1, r2, [rl, lb, sz, flg]
; INPUTS:
;       a1, a2, da = tic mark start angle, end angle, step     in
;          (deg CCW from X axis).
;       r1, r2 = start and end radii of tic marks.             in
;       rl = label radius.                                     in
;       lb = string array of labels.                           in
;       sz = Text size.                                        in
;       flg = label angle flag.                                in
;             0: read from outside circle (def),
;             1: read labels from inside circle.
; KEYWORD PARAMETERS:
;       Keywords:
;         X0=x, Y0=y.  Offsets for center of circle.
;         /DEVICE means use device coordinates .
;         /DATA means use data coordinates (default).
;         /NORM means use normalized coordinates.
;         COLOR=c  plot color (scalar or array).
;         LINESTYLE=l  linestyle (scalar or array).
;         THICKNESS=t  line thickness (scalar or array).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 12 July, 1988.
;       RES  18 July, 88 --- added reverse labels flag.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;       R. Sterner, 2006 Jun 26 --- Added color=c, linestyle=s, thickness=t,
;       /device, /data, /norm.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO RTICS, A1, A2, DA, R1, R2, RL, LB0, SZ, FLG, help=hlp, $
	  x0=x0, y0=y0, $
	  color=clr, linestyle=lstyl, thickness=thk, $
	  device=device, data=data, norm=norm
 
 	NP = N_PARAMS(0)
	IF (NP LT 5) or keyword_set(hlp) THEN BEGIN
	  print,' Plot labeled or unlabeled tic marks around a circular arc.'
	  PRINT,' rtics, a1, a2, da, r1, r2, [rl, lb, sz, flg]'
	  PRINT,'   a1, a2, da = tic mark start angle, end angle, step     in'
	  print,'      (deg CCW from X axis).'
	  PRINT,'   r1, r2 = start and end radii of tic marks.             in'
	  PRINT,'   rl = label radius.                                     in'
	  PRINT,'   lb = string array of labels.                           in'
	  PRINT,'   sz = Text size.                                        in'
	  PRINT,'   flg = label angle flag.                                in'
	  print,'         0: read from outside circle (def),'
	  PRINT,'         1: read labels from inside circle.'
	  print,' Keywords:'
	  print,'   X0=x, Y0=y.  Offsets for center of circle.'
	  print,'   /DEVICE means use device coordinates .'
          print,'   /DATA means use data coordinates (default).'
          print,'   /NORM means use normalized coordinates.'
	  print,'   COLOR=c  plot color (scalar or array).'
	  print,'   LINESTYLE=l  linestyle (scalar or array).'
	  print,'   THICKNESS=t  line thickness (scalar or array).'
	  RETURN
	ENDIF
 
	;------  Determine coordinate system  -----
        if n_elements(device) eq 0 then device = 0    ; Define flags.
        if n_elements(data)   eq 0 then data   = 0
        if n_elements(norm)   eq 0 then norm   = 0
        if device+data+norm eq 0 then data = 1        ; Default to data.
 
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(lstyl) eq 0 then lstyl = !p.linestyle
	if n_elements(thk) eq 0 then thk = !p.thick
	nclr = n_elements(clr)-1
	nlstyl = n_elements(lstyl)-1
	nthk = n_elements(thk)-1
 
	IF NP LT 6 THEN RL = 0.
	IF NP LT 7 THEN LB0 = ''
	IF NP LT 8 THEN SZ = 1.
	IF NP LT 9 THEN FLG = 0
 
	if n_elements(x0) eq 0 then x0 = 0.
	if n_elements(y0) eq 0 then y0 = 0.
 
	LB = [LB0,' ']		; Force to be array.
	
	NLB = N_ELEMENTS(LB)-1		; Array size.
 
	I = 0
 
	FOR A = A1, A2, DA DO BEGIN   			; loop thru radii.
	  POLREC, [R1, R2], A/!RADEG, X, Y
	  clri = clr(i<nclr)
	  lstyli = lstyl(i<nlstyl)
	  thki = thk(i<nthk)
	  PLOTS, X+x0, Y+y0, color=clri, linestyle=lstyli, thick=thki, $
	    data=data, device=device, norm=norm
	  IF RL GT 0.0 THEN BEGIN			; Text.
	    T = STRTRIM(LB(I<nlb),2)			; Pull text string.
	    IF FLG EQ 0 THEN BEGIN
	      TA = A + 90.				; Text angle.
	    ENDIF ELSE BEGIN
	      TA = A - 90.				; Text angle.
	    ENDELSE
	    polrec, rl, a/!radeg, x, y
	    XYOUTS, X+x0, Y+y0, T, align=.5, size=SZ, orient=TA, $
	      color=clri, data=data, device=device, norm=norm
	  ENDIF
	  i = i + 1
	ENDFOR
 
	RETURN
 
	END
