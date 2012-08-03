;-------------------------------------------------------------
;+
; NAME:
;       GENSHAPE
; PURPOSE:
;       Generate x,y coordinates to draw named shaped.
; CATEGORY:
; CALLING SEQUENCE:
;       genshape, name, x, y
; INPUTS:
;       name = name of shape:			in
;         triangle, square, diamond, pentagon, hexagon,
;         poly, polyN (N = # sides, 3-9),
;         star, starN (N = # points, 3-9),
;         tree, treeN (N = # points on side, 1-9),
;         flower, flowerN (N = # petals, 3-9),
;         circle, balloon,
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x, y = returned x,y for shape.		out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 2 Nov, 1986.
;       R. Sterner, 14 Mar, 1990 --- converted to SUN.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO GENSHAPE, NAME, X, Y, help=hlp
 
	IF (N_PARAMS(0) LT 3) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Generate x,y coordinates to draw named shaped.'
	  PRINT,' genshape, name, x, y'
	  PRINT,'  name = name of shape:			in'
	  PRINT,'    triangle, square, diamond, pentagon, hexagon,'
	  PRINT,'    poly, polyN (N = # sides, 3-9),'
	  PRINT,'    star, starN (N = # points, 3-9),'
	  PRINT,'    tree, treeN (N = # points on side, 1-9),'
	  PRINT,'    flower, flowerN (N = # petals, 3-9),'
	  PRINT,'    circle, balloon,'
	  PRINT,'  x, y = returned x,y for shape.		out'
	  RETURN
	ENDIF
 
	PI2 = 360./!RADEG
 
	NAM = STRUPCASE(NAME)
	CASE STRMID(NAM,0,4) OF
'TRIA':  BEGIN
	    A = MAKEX(0, PI2, PI2/3) + PI2/4.
	    R = FLTARR(3) + 1
	    POLREC, R, A, X, Y
	    RETURN
	  END
'SQUA':  BEGIN
	    A = MAKEX(0, PI2, PI2/4) + PI2/8.
	    R = FLTARR(4) + 1
	    POLREC, R, A, X, Y
	    RETURN
	  END
'DIAM':  BEGIN
	    A = MAKEX(0, PI2, PI2/4)
	    R = FLTARR(4) + 1
	    POLREC, R, A, X, Y
	    RETURN
	  END
'PENT':  BEGIN
	    A = MAKEX(0, PI2, PI2/5) + PI2/4.
	    R = FLTARR(5) + 1
	    POLREC, R, A, X, Y
	    RETURN
	  END
'HEXA':  BEGIN
	    A = MAKEX(0, PI2, PI2/6)
	    R = FLTARR(6) + 1
	    POLREC, R, A, X, Y
	    RETURN
	  END
'CIRC':  BEGIN
	    A = MAKEX(0, PI2, PI2/36) - PI2/4.
	    R = FLTARR(37) + 1
	    POLREC, R, A, X, Y
	    RETURN
	  END
'BALL':  BEGIN
	    A = MAKEX(0, PI2, PI2/36) - PI2/4.
	    R = FLTARR(37) + 1
	    POLREC, R, A, X, Y
	    X2 = [0,.2,-.2,0]
	    Y2 = [-1,-1.2,-1.2,-1]
	    X = [X2,X]
	    Y = [Y2,Y]
	    X2 = [0,-.1,0,.2,0]
	    Y2 = [-3,-2.5,-2,-1.5,-1]
	    X = [X2,X,REVERSE(X2)]
	    Y = [Y2,Y,REVERSE(Y2)]
	    RETURN
	  END
'TREE':	  BEGIN
	    DX = [-.5,.3]	; tree seed.
	    DY = [-1.,0.]
	    X2 = [0.,DX]		; 1 pt tree.
	    Y2 = [0.,DY]
	    N = STRMID(NAM, 4, 1)	; 9 pt max.
	    IF N EQ '' THEN N = '1'	; def = 1 pt.
	    IF N EQ '1' THEN GOTO, TR2
	    FOR I = 2, N DO BEGIN	; add points.
	      X2 = [X2, DX]
	      Y2 = [Y2, DY]
	    ENDFOR
TR2:	    X = CUMULATE(X2)
	    Y = CUMULATE(Y2)
	    LAST = N_ELEMENTS(X) - 1
	    X = X(0:LAST-1)
	    Y = Y(0:LAST-1)
	    X = [X,-.05,-.05,0.]
	    Y = [Y,Y(LAST-1),Y(LAST-1)-.3,Y(LAST-1)-.3]
	    X = [X,REVERSE(-X)]
	    Y = [Y,REVERSE(Y)]
	    Y = Y - MIN(Y)/2.
	    RETURN
	  END
'POLY':	  BEGIN
	    N = STRMID(NAM, 4, 1)	; 9 pt max.
	    IF N EQ '' THEN N = '7'	; def = 7 pt.
	    N = (N + 0)>3
	    A = MAKEX(0, PI2, PI2/N) + PI2/4.
	    IF (N MOD 2) EQ 0 THEN A = A + PI2/(2*N)
	    R = FLTARR(N) + 1
	    POLREC, R, A, X, Y
	    RETURN
	  END
'STAR':	  BEGIN
	    N = STRMID(NAM, 4, 1)	; 9 pt max.
	    IF N EQ '' THEN N = '5'	; def = 5 pt.
	    N = (N + 0)>3		; 3 pt min.
	    A1 = MAKEX(0, PI2, PI2/N) + PI2/4.
	    IF (N MOD 2) EQ 0 THEN A1 = A1 + PI2/(2*N)
	    A2 = A1 + PI2/(2*N)
	    R1 = FLTARR(N) + 1
	    R2 = .37*R1
	    A = [A1,A2]
	    R = [R1,R2]
	    I = SORT(A)
	    A = A(I)
	    R = R(I)
	    A = A(0:(2*N-1))
	    R = R(0:(2*N-1))
	    POLREC, R, A, X, Y
	    RETURN
	  END
'FLOW':	  BEGIN
	    N = STRMID(NAM, 6, 1)	; 9 pt max.
	    IF N EQ '' THEN N = '7'	; def = 7 pt.
	    N = (N + 0)>3		; 3 pt min.
	    A = MAKEN(0, PI2, 30*N)	; 30 points per petal.
	    OFF = 0.
	    IF ((N MOD 2) EQ 0) AND ((N/2 MOD 2) EQ 1) THEN OFF = PI2/(2*N)
	    IF (N MOD 2) EQ 1 THEN OFF = PI2/(2*N) + PI2/4.
	    R1 = MAKEN(.2, .2, 30*N)
	    R2 = .8*ABS(SIN(N*A/2.))
	    R3 = R1 + R2
	    POLREC, R3, A+OFF, X, Y
	    RETURN
	  END
ELSE:	  BEGIN
	    BELL
	  END
	ENDCASE
 
	RETURN
	END
