;-------------------------------------------------------------
;+
; NAME:
;       STEXT_XYP
; PURPOSE:
;       Return stroke text plot arrays.
; CATEGORY:
; CALLING SEQUENCE:
;       XYP = STEXT_XYP(TXT)
; INPUTS:
;       TXT = text string to plot.         in
; KEYWORD PARAMETERS:
;       Keywords:
;         X = Text X location in data coorinates (def=0).
;         Y = Text Y location in data coorinates (def=0).
;         SIZE = Text size (def = 1).
;           Size 1 gives text 7 units high.
;         ANG = Text angle (deg CCW, def=0).
;         JUST = justification code (1-9, def=7).
;           The justification code specifies the text
;           reference point as follows:
;           1     2     3
;           4     5     6
;           7     8     9
;           So if JUST = 1 then X,Y is upper left corner of text,
;           if JUST = 7 then X,Y is the lower left corner of text.
;           This applies only to line 1 of a multiline text string.
;         XFACT = size factor in X (def=1). Use to change shape.
; OUTPUTS:
;       XYP = plot array:                  out
;           X=XYP(*,0), Y=XYP(*,1), P=XYP(*,2)
;           Then PLOTP, X, Y, P
; COMMON BLOCKS:
;       STEXT_COMMON
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Oct, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION STEXT_XYP, TXT, SIZE=size, ANG=ang, JUST=just, $
	  xfact=xfact, xtxt=x0, ytxt=y0, help=hlp
	  
	COMMON STEXT_COMMON, INIT_FLAG, INDX, LNGTH, CHRX, CHRY, CHRPEN
 
	IF (n_params(0) LT 1) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Return stroke text plot arrays.
	  PRINT,' XYP = STEXT_XYP(TXT)
	  PRINT,'   TXT = text string to plot.         in'
	  PRINT,'   XYP = plot array:                  out'
	  print,'       X=XYP(*,0), Y=XYP(*,1), P=XYP(*,2)
	  PRINT,'       Then PLOTP, X, Y, P
	  print,' Keywords:'
	  PRINT,'   X = Text X location in data coorinates (def=0).
	  PRINT,'   Y = Text Y location in data coorinates (def=0).
	  PRINT,'   SIZE = Text size (def = 1).
          print,'     Size 1 gives text 7 units high.'
	  PRINT,'   ANG = Text angle (deg CCW, def=0).
	  PRINT,'   JUST = justification code (1-9, def=7).
	  PRINT,'     The justification code specifies the text'
	  print,'     reference point as follows:
	  PRINT,'     1     2     3
	  PRINT,'     4     5     6
	  PRINT,'     7     8     9
	  PRINT,'     So if JUST = 1 then X,Y is upper left corner of text,
	  PRINT,'     if JUST = 7 then X,Y is the lower left corner of text.'
	  PRINT,'     This applies only to line 1 of a multiline text string.
	  PRINT,'   XFACT = size factor in X (def=1). Use to change shape.
	  RETURN, -1
	ENDIF
 
	IF N_ELEMENTS(INIT_FLAG) EQ 0 THEN INIT_FLAG = 0
 
	IF INIT_FLAG EQ 0 THEN BEGIN
	INDX=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$
	      0,0,0,0,0,0,0,0,1,5,13,21,32,44,55,59,65,71,77,81,87,$
	      89,94,96,107,112,122,135,140,149,159,165,182,192,202,$
	      213,216,220,223,233,249,257,269,277,284,290,295,305,311,$
	      317,323,329,332,337,341,350,357,368,378,390,394,400,403]
	      INDX=[INDX,408,412,417,421,425,427,431,434,436,468,477,487,$
	      495,505,515,522,534,541,545,552,558,560,570,577,586,596,606,$
	      612,622,626,633,636,646,650,654,446,0,457,440]
	LNGTH=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$
	       1,1,1,1,4,8,8,11,12,11,4,6,6,6,4,6,2,5,2,11,5,10,13,5,9,10,$
	       6,17,10,10,11,3,4,3,10,16,8,12,8,7,6,5,10,6,6,6,6,3,5,4,9]
	       LNGTH=[LNGTH,7,11,10,12,4,6,3,5,4,5,4,4,2,4,3,2,4,9,10,8,$
	       10,10,7,12,7,4,7,6,2,10,7,9,10,10,6,10,4,7,3,10,4,4,4,11,1,11,6]
	CHRX=[0,2,2,2,2,1,0,1,1,3,3,4,3,0,2,2,4,0,4,0,4,0,3,4,4,3,1,0,1,4,$
	      2,2,0,4,1,2,1,0,1,3,4,3,2,3,4,2,1,0,0,3,3,2,1,1,4,2,2,3,2,3,$
	      2,1,1,2,3,1,2,3,3,2,1,0,4,2,2,4,0,0,4,2,2,1,2,2,1,1,2,0,4,1]
	      CHRX=[CHRX,2,2,1,1,0,4,0,4,1,0,0,1,3,4,4,3,1,1,2,2,1,3,4,0,0,1,$
	      3,4,4,3,1,0,0,1,3,4,4,3,4,4,3,1,0,1,3,2,0,4,3,3,0,1,3,4,4,3,0,0,$
	      4,1,3,4,4,3,1,0,0,1,3,1,2,4,4,0,0,1,0,0,1,3,4,4,3,1,1]
	      CHRX=[CHRX,0,0,1,3,4,4,3,1,3,4,4,3,1,0,0,1,3,1,2,2,1,1,1,2,2,1,$
	      1,1,2,2,1]
	      CHRX=[CHRX,$
	      1,2,1,2,2,1,1,4,0,4,0,4,0,4,0,4,0,2,2,2,2,4,4,3,1,0,0,4,3,1,$
	      0,0,1,3,4,4,3,2,1,1,2,3,4,0,0,1,3,4,4,0,4,0,0,3,4,4,3,4,4,3]
	      CHRX=[CHRX,0,0,3,4,3,1,0,0,1,3,4,0,0,3,4,4,3,0,4,0,0,$
	      4,3,0,0,0,4,0,3,2]
	      CHRX=[CHRX,4,4,3,1,0,0,1,3,4,0,0,0,4,4,4,1,3,2,2,1,3,0,0,1,3,$
	      4,4,0,0,0,4,1,4,0,0,4,0,0,2,4,4,0,0,4,4,4,4,3,1,0,0,1,3,4,0,0,$
	      3,4,4,3,0,4,4,3,1,0,0,1,3,4,2,4,0,0,3,4,4,3,0,3,4,4,0,1,3,4,4]
	      CHRX=[CHRX,3,1,0,0,1,3,4,2,2,0,4,0,0,1,3,4,4,0,2,4,0,0,2,4,4,$
	      0,4,0,4,2,2,$
	      0,2,4,4,0,4,0,4,1,1,4,4,0,0,3,3,0,0,2,4,0,4,2,1,2,2,-1,0,1,3]
	      CHRX=[CHRX,4,5,4,3,2,2,1,0,1,2,2,3,4,0,1,2,2,3,4,3,2,2,1,0,4,4,$
	      3,1,0,0,1,3,4,0,0,0,1,3,4,4,3,1,0,4,3,1,0,0,1,3,4,4,4,4,3,1,0,$
	      0,1,3,4,0,4,4,3,1,0,0,1,3,4,1,1,2,3,4,0,2,0,1,3,4,4,3,1,0,0,1]
	      CHRX=[CHRX,$
	      3,4,0,0,0,1,3,4,4,2,2,2,2,0,1,2,3,3,3,3,0,0,0,4,2,4,2,2,0,0,0,$
	      1,2,2,2,3,4,4,0,0,0,1,3,4,4,0,0,1,3,4,4,3,1,0,0,0,0,1,3,4,4,3]
	      CHRX=[CHRX,1,0,4,3,1,0,0,1,3,4,4,5,0,0,0,1,3,4,0,1,3,4,3,1,0,1,$
	      3,4,2,2,0,4,0,0,1,3,4,4,4,0,2,4,0,0,1,2,2,2,3,4,4,4,0,4,0,4,0,$
	      2,1,4,0,4,0,4]
	CHRY=[0,0,1,2,7,5,7,7,5,5,7,7,5,0,6,0,6,2,2,4,4,1,1,2,3,4,4,5,6,6,$
	      0,7,0,7,7,6,5,6,7,0,1,2,1,0,2,0,0,1,2,5,6,7,6,5,0,5,7,7,5,0,$
	      1,3,4,6,7,0,1,3,4,6,7,2,4,1,5,2,4,3,3,1,5,-1,0,1,1,0,0,3,3,0]
	      CHRY=[CHRY,$
	      0,1,1,0,0,7,0,7,0,2,5,7,7,5,2,0,0,5,7,0,0,0,0,0,1,3,4,5,6,7]
	      CHRY=[CHRY,$
	      7,6,1,0,0,1,3,4,5,6,7,7,6,4,4,7,2,2,0,5,1,0,0,1,3,4,4,7,7,4,$
	      4,3,1,0,0,1,3,5,7,0,3,6,7,7,6,0]
	      chry=[chry,1,3,4,4,3,1,0,0,4,5,6,7,7,6,$
	      5,4,0,2,4,6,7,7,6,4,3,3,0,0,1,1,0,3,3,4,4,3,-1,0,1,1,0,0,3,3]
	      CHRY=[CHRY,$
	      4,4,3,1,3,5,2,2,4,4,1,3,5,0,1,2,3,5,6,7,7,6,5,2,1,1,2,5,6,6,$
	      5,3,2,2,3,4,5,5,4,0,6,7,7]
	      chry=[chry,6,0,3,3,0,7,7,6,5,4,3,1,0,0,4,4,1,$
	      0,0,1,6,7,7,6,0,7,7,6,1,0,0,0,0,7,7,4,4,0,7,7,4,4,3,3,1,0,0]
	      CHRY=[CHRY,$
	      1,6,7,7,6,0,7,3,3,0,7,0,0,0,7,7,7,2,1,0,0,1,7,0,7,3,7,4,0,7,$
	      0,0,0,7,3,7,0,0,7,0,7,6,1,0]
	      chry=[chry,0,1,6,7,7,6,0,7,7,6,4,3,3,6,1,0,$
	      0,1,6,7,7,6,2,0,0,7,7,6,4,3,3,3,2,0,1,0,0,1,3,4,4,5,6,7,7,6]
	      CHRY=[CHRY,$
	      0,7,7,7,7,1,0,0,1,7,7,0,7,7,0,4,0,7,0,7,7,0,0,3,7,3,7,0,0,7,$
	      7,0,0,7,7,0,7,0,0,7,7,5,7,5]
	      chry=[chry,0,0,5,7,7,5,3,4,4,2,2,3,0,0,1,3,$
	      4,4,4,5,6,7,7,0,0,1,3,4,4,4,5,6,7,7,0,3,4,4,3,1,0,0,1,7,0,1]
	      CHRY=[CHRY,$
	      0,0,1,3,4,4,3,1,0,0,1,3,4,4,3,0,7,1,0,0,1,3,4,4,3,2,2,3,4,4,$
	      3,1,0,0,1,0,6,7,7,6,3,3,-1]
	      chry=[chry,-2,-2,-1,3,4,4,3,1,0,0,1,0,7,3,4,$
	      4,3,0,0,3,5,6,-1,-2,-2,-1,3,5,6,0,7,2,4,3,0,0,7,0,4,3,4,3,1]
	      CHRY=[CHRY,$
	      3,4,3,0,0,4,3,4,4,3,0,1,3,4,4,3,1,0,0,1,-2,4,3,4,4,3,1,0,0,1,$
	      1,0,0,1,3,4,4,3,-2,-2,0,4,3,4,4,3,1,0,0,1,2,2,3,4,4,3,0,6,4]
	      CHRY=[CHRY,$
	      4,4,1,0,0,1,0,4,4,0,4,4,1,0,1,3,1,0,1,0,4,0,4,4,0,4,0,-2,4,4,$
	      4,0,0]
	CHRPEN=[0,0,1,0,1,0,1,1,1,0,1,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1,$
	        1,0,1,0,1,1,1,1,1,1,0,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1,$
	        1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1]
		CHRPEN=[CHRPEN,$
	        0,1,0,1,1,1,1,0,1,0,1,0,1,1,1,1,1,1,1,1,0,1,1,0,1,0,1,1,1,$
	        1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,0,1,1,0,1,0,1,1,1,1,$
	        1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,1]
		CHRPEN=[CHRPEN,$
	        0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,$
	        1,1,1,1,1,0,1,1,1,1,0,1,1,0,1,0,1,0,1,1,0,1,0,1,1,1,1,1,1,$
	        1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,0,1,1,1]
		CHRPEN=[CHRPEN,$
	        1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,0,1,$
	        0,1,1,0,1,0,1,1,1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,$
	        1,1,1,1,0,1,0,1,0,1,0,1,1,0,1,1,1,1,0,1,1,1,0,1,1,1,1,1,1]
		CHRPEN=[CHRPEN,$
	        1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,0,1,$
	        1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,0,1,1,1,1,1,0,1,1,0,1,1,$
	        1,1,0,1,0,1,0,1,1,0,1,0,1,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,0]
		CHRPEN=[CHRPEN,$
	        1,0,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,$
	        1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,$
	        1,1,0,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,1]
		CHRPEN=[CHRPEN,$
	        0,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1,0,1,0,1,0,1,1,1,1,0,$
	        1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,0,1,1,1,0,1,0,1,1,1,1,0,1,1,$
	        1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,0]
		CHRPEN=[CHRPEN,$
	        1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,0,1,0,1,1,1,1,0,1,0,1,1,0,1,$
	        1,1,1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1]
	ENDIF
 
 
	NP = N_PARAMS(0)
	IF n_elements(x0) eq 0 THEN x0 = 0.
	IF n_elements(y0) eq 0 THEN y0 = 0.
	IF n_elements(xfact) eq 0 THEN xfact = 1.
	IF n_elements(just) eq 0 THEN JUST = 7
	IF n_elements(ang) eq 0 THEN ANG = 0.
	IF n_elements(size) eq 0 then SIZE = 1.
 
	LINE = 0
	RX = X0
	RY = Y0
 
;------------------------------------------------------------------------
	IF TXT EQ '' THEN RETURN, -1
	B = BYTE(TXT)			; convert text to ascii code, B.
	LASTB = N_ELEMENTS(B) - 1	; number of last char in TXT.
	JFY = [1., 1., 1., .5, .5, .5, 0., 0., 0.]	; justification frac.
	JFX = [0., .5, 1., 0., .5, 1., 0., .5, 1.]
	FX = JFX(JUST-1)		; select correct fractions.
	FY = JFY(JUST-1)
	IB = -1		; index into B.
	NC = 0		; line length so far.
	VX = FLTARR(1)	; set up x,y, pen arrays.
	VY = FLTARR(1)
	VP = INTARR(1)
 
	VVX = FLTARR(1)	; Overall output arrays.
	VVY = FLTARR(1)
	VVP = FLTARR(1)
 
LOOP:	IB = IB + 1			; get ready for next char.
	IF IB GT LASTB THEN GOTO, OUT	; no more text.
	C = B(IB)			; pick next char.
;----------  process a <CR>  ------------------------
	IF C EQ 13B THEN BEGIN		; handle <CR>
OUT:
	  ;--------------------------------------------------
	  IF NC GT 0 THEN BEGIN		; output text.
	    VX = VX(1:*)		; trim off dummy first value.
	    VY = VY(1:*)
	    VP = VP(1:*)
	    PROTO_NX = 7*NC		; next char X is at end of text,
	    PROTO_NY = 7*FY		; and up by FY.
	    DX = PROTO_NX*FX		; ref pt rel. coords.
	    DY = PROTO_NY
	    VX = VX - DX		; shift justification pt to origin.
	    VY = VY - DY
	    PROTO_NX = PROTO_NX - DX
	    PROTO_NY = PROTO_NY - DY
	    VX = VX * SIZE * XFACT	; scale, then rotate.
	    VY = VY * SIZE
	    PROTO_NX = PROTO_NX * SIZE * XFACT
	    PROTO_NY = PROTO_NY * SIZE
	    ROTATE_XY, VX, VY, ANG/!RADEG, 0., 0., VX2, VY2
	    ROTATE_XY, PROTO_NX, PROTO_NY, ANG/!RADEG, 0., 0., $
		PROTO_NX2, PROTO_NY2
	    VX2 = VX2 + X0
	    VY2 = VY2 + Y0
	    X0 = PROTO_NX2 + X0
	    Y0 = PROTO_NY2 + Y0
	    VVX = [VVX,VX2]		; Add new line of text.
	    VVY = [VVY,VY2]
	    VVP = [VVP,VP]
	  ENDIF				; end output text.
	  ;--------------------------------------------------
	  IF IB GT LASTB THEN GOTO, DONE	; no more text.
	  LINE = LINE + 1			; count new line.
	  H = 11.*SIZE*LINE			; move down one more line.
	  X0 = RX + H*SIN(ANG/!RADEG)
	  Y0 = RY - H*COS(ANG/!RADEG)
	  NC = 0				; clear line length.
	  VX = FLTARR(1)			; set up new x,y, pen arrays.
	  VY = FLTARR(1)
	  VP = INTARR(1)
	  GOTO, LOOP
	ENDIF
 
;---------  collect more vectors  ---------
	IF C LT 32 THEN GOTO, LOOP		; ignore other control chars.
	I = INDX(C)				; first vector table position.
	L = LNGTH(C)-1				; last vector table position.
	X = CHRX(I:(I+L))			; pull out X.
	VX = [VX, X + NC*7]
	Y = CHRY(I:(I+L))			; pull out Y.
	VY = [VY, Y]
	P = CHRPEN(I:(I+L))			; pull out pen code.
	VP = [VP, P]
	NC = NC + 1				; count character.
	GOTO, LOOP
	
DONE:	RETURN, [[VVX(1:*)], [VVY(1:*)], [VVP(1:*)]]
	END
