;-------------------------------------------------------------
;+
; NAME:
;       MAKE_RULER
; PURPOSE:
;       Plot linear scales on the laser printer.
; CATEGORY:
; CALLING SEQUENCE:
;       make_ruler, file
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         PRINTER = postscript printer number (1=def or 2).
;         /LIST to list control file lines as processed.
;         /NOPLOT means just generate idl.ps but do not print it.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         Control file format:
;         * in column 1 for comment lines.
;         CF = conversion_factor cm per UNIT
;           Set a conv. fact. & unit name. Ex CF = 2.54 cm per inch.
;           Must be number of cm per unit. Used for LENGTH & TICS.
;           Default is cm.
;         LENGTH = len
;           Set ruler length in UNITS.
;         XY = x, y
;           Set ruler left side in cm from origin and draw line.
;           Must do LENGTH before XY.
;         LABELS = L1, L2, dL, y, s
;           Sets up labels to be used on next TICS command.
;           L1, L2, dL = label start, stop, step values.
;           y = label position in cm above ruler line.
;           s = label size.
;         The following coord. are relative to ruler's left side.
;         TICS = x1, x2, dx, dy
;           Draws tic marks.
;           x1, x2, and dx are tic x start, stop and step in UNITS.
;           dy is tic length in cm.  (Do labels first if labeled).
;         TEXT = x, y, j, s, text string
;           x,y = text position in cm relative to XY position.
;           J = justification: L = left, C = centered, R = right.
;           text string = text to print.
;         TYPE = text string
;           text string = message to display on terminal screen.
; MODIFICATION HISTORY:
;       R. Sterner. 12 Sep, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
 
	PRO MAKE_RULER, F, help=hlp, list=lst, printer=prntr, noplot=noplot
 
	IF (N_PARAMS(0) LT 1) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Plot linear scales on the laser printer.'
	  PRINT,' make_ruler, file'
	  PRINT,'   file = Control file name.'
	  print,' Keywords:'
	  print,'   PRINTER = postscript printer number (1=def or 2).'
	  print,'   /LIST to list control file lines as processed.'
	  print,'   /NOPLOT means just generate idl.ps but do not print it.'
	  print,' Notes:'
	  PRINT,'   Control file format:'
	  PRINT,'   * in column 1 for comment lines.'
	  PRINT,'   CF = conversion_factor cm per UNIT'
	  PRINT,'     Set a conv. fact. & unit name. Ex CF = 2.54 cm per inch.'
	  PRINT,'     Must be number of cm per unit. Used for LENGTH & TICS.'
	  PRINT,'     Default is cm.'
	  PRINT,'   LENGTH = len'
	  PRINT,'     Set ruler length in UNITS.'
	  PRINT,'   XY = x, y'
	  PRINT,'     Set ruler left side in cm from origin and draw line.'
	  PRINT,'     Must do LENGTH before XY.'
	  PRINT,'   LABELS = L1, L2, dL, y, s'
	  PRINT,'     Sets up labels to be used on next TICS command.'
	  PRINT,'     L1, L2, dL = label start, stop, step values.'
	  PRINT,'     y = label position in cm above ruler line.'
	  print,'     s = label size.'
	  PRINT,"   The following coord. are relative to ruler's left side."
	  PRINT,'   TICS = x1, x2, dx, dy'
	  PRINT,'     Draws tic marks.'
	  PRINT,'     x1, x2, and dx are tic x start, stop and step in UNITS.'
	  PRINT,'     dy is tic length in cm.  (Do labels first if labeled).'
	  PRINT,'   TEXT = x, y, j, s, text string'
	  PRINT,'     x,y = text position in cm relative to XY position.'
	  PRINT,'     J = justification: L = left, C = centered, R = right.'
	  PRINT,'     text string = text to print.'
	  PRINT,'   TYPE = text string'
	  PRINT,'     text string = message to display on terminal screen.'
	  RETURN
	ENDIF
 
	ON_IOERROR, ERR
	GET_LUN, LUN
	OPENR, LUN, F
	ON_IOERROR, NULL
 
 
	num = 0
	if keyword_set(prntr) then num = prntr
	psinit, num, /land
	xsize = 24.06 		; Full page x size.
	ysize = 17.80 		; Full page y size.
	set_window, 0., xsize, 0., ysize
	CF = 1.0		; Conversion factor.
	UNITS = 'cm'
 
	;-------  Initial values  --------
	LEN = -1.	; Must define these values.
	X = -1.
	Y = -1.
	LFLG = 0	; No labels defined.
 
	OPLOT, [0,0], [0,0], psym=1
 
;=========  Loop through control file  ============
LOOP:	ITEM = NEXTITEM(LUN, TXT)	; Get next command from control file.
	if keyword_set(lst) then begin
	  print,' Control file line: ',txt
	endif
	IF ITEM EQ '' THEN GOTO, DONE0	; At end of file?
	TXT = REPCHR(TXT,'=')		; delete =.
	CASE STRUPCASE(ITEM) OF
'LENGTH': BEGIN
	  IF NWRDS(TXT) LT 2 THEN BEGIN
	    PRINT,' Error in LENGTH command.  Must give a value.'
	    PRINT,' LENGTH = len'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  LEN0 = GETWRD(TXT, 1)		; Ruler length in UNITS.
	  PRINT,'   Setting ruler length to '+STRTRIM(LEN0,2)+ ' '+UNITS+'s.'
	  LEN = LEN0*CF
	END
'XY':	BEGIN
	  IF LEN EQ -1. THEN BEGIN
	    PRINT,' Must set LENGTH before doing XY.'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  IF NWRDS(TXT) LT 3 THEN BEGIN
	    PRINT,' Error in XY command. Must give 2 values.'
	    PRINT,' XY = x, y'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  X = GETWRD(TXT, 1) + 0.0	; Ruler position in cm.
	  Y = GETWRD(TXT, 2) + 0.0
	  PRINT,'   Setting ruler X,Y to '+STRTRIM(X,2)+$
	    ', '+STRTRIM(Y,2)+' cms and plotting '+$
	    STRTRIM(LEN0,2)+' '+UNITS+' line.'
;	  OPLOT, [X, LEN+X], [Y, Y]
	  PLOTS, [X, LEN+X], [Y, Y]
	END
'LABELS': BEGIN
	  IF NWRDS(TXT) LT 5 THEN BEGIN
	    PRINT,' Error in LABELS command.  Must give at least 4 values.'
	    PRINT,' LABELS = l1, l2, dl, yl, sz'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  L1 = FIX(GETWRD(TXT,1))	; First label value.
	  L2 = FIX(GETWRD(TXT,2))	; Last label value.
	  DL = FIX(GETWRD(TXT,3))	; Label step size.'
	  PRINT,'   Setting up labels: '+STRTRIM(L1,2)+$
	    ' to '+STRTRIM(L2,2)+' by '+STRTRIM(DL,2)+' '+UNITS+'s.'
	  YL = GETWRD(TXT,4) + 0.	; Label position Y in cm.
	  SZ = 1.			; Default size.
	  T = GETWRD(TXT,5)		; Try to get size.
	  IF T NE '' THEN SZ = T+0.	; Got size.
	  T = MAKEI(L1, L2, DL)		; Labels must be integers.
	  NT = N_ELEMENTS(T)		; Number of labels
	  LB = STRARR(20,NT)		; Setup array for labels.
	  FOR I = 0, NT-1 DO LB(I)=STRTRIM(T(I),2)	; Make labels.
	  LFLG = 1			; Set label flag.
	END
'TICS':	BEGIN
	  IF LEN EQ -1. THEN BEGIN
	    PRINT,' Must set LENGTH before doing TICS.'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  IF (X EQ -1.) OR (Y EQ -1.) THEN BEGIN
	    PRINT,' Must set XY before doing TICS.'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  IF NWRDS(TXT) LT 5 THEN BEGIN
	    PRINT,' Error in TICS command.  Must give 4 values.'
	    PRINT,' TICS = x1, x2, dx, dy'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  TX1 = GETWRD(TXT,1)*CF	; Tics start X in UNITS.
	  TX2 = GETWRD(TXT,2)*CF	; Tics stop X in UNITS.
	  DTX = GETWRD(TXT,3)*CF	; Tics X step in UNITS.
	  TDY = GETWRD(TXT,4) + 0.	; Tics length in cm.
	  IF LFLG EQ 1 THEN BEGIN
	    PRINT,'   Plotting ' + STRTRIM(TDY,2) + ' cm labeled tic marks.'
	    XTICS, X+TX1, X+TX2, DTX, Y, Y+TDY, Y+YL, LB, SZ
	    LFLG = 0
	  ENDIF ELSE BEGIN
	    PRINT,'   Plotting ' + STRTRIM(TDY,2) + ' cm tic marks.'
	    XTICS, X+TX1, X+TX2, DTX, Y, Y+TDY
	  ENDELSE
	END
'TEXT':	BEGIN
	  IF LEN EQ -1. THEN BEGIN
	    PRINT,' Must set LENGTH before doing TEXT.'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  IF (X EQ -1.) OR (Y EQ -1.) THEN BEGIN
	    PRINT,' Must set XY before doing TEXT.'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  IF NWRDS(TXT) LT 6 THEN BEGIN
	    PRINT,' Error in TEXT command.  Must give at least 5 values.'
	    PRINT,' TEXT = x, y, just, size, text_string'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  TXTX = GETWRD(TXT,1) + 0.		; Text X.
	  TXTY = GETWRD(TXT,2) + 0.		; Text Y.
	  JUST = STRUPCASE(GETWRD(TXT,3))	; Justification (L,C,R).
	  SIZE = GETWRD(TXT,4) + 0.		; Tics start Y.
	  TXT = GETWRD(TXT,-5)			; Tics stop Y.
	  CASE JUST OF
	'L':	XOFF = 0.0
	'C':	XOFF = 0.5
	'R':	XOFF = 1.0
	  ENDCASE
	PRINT,'   Listing text: ' + TXT
	XYOUTS, X+TXTX, Y+TXTY, TXT, size=SIZE, align=xoff 
	END
'TYPE':	BEGIN
	  PRINT,GETWRD(TXT,-1)
	END
'CF':	BEGIN
	  IF NWRDS(TXT) LT 2 THEN BEGIN
	    PRINT,' Error in CF command.  Must give at least 1 value.'
	    PRINT,' CF = cf, [cm per UNIT]'
	    PRINT,' Processing aborted.'
	    GOTO, ABRT
	  ENDIF
	  CF = GETWRD(TXT, 1) + 0.0		; Conversion factor.
	  UNITS = GETWRD(TXT, NWRDS(TXT)-1)	; Units = last word on line.
	  PRINT,'   Conversion factor set to '+STRTRIM(CF,2)+$
	    ' cm per '+UNITS+'.'
	END
ELSE:	BEGIN
	  PRINT,' Unknown command in control file: ' + ITEM
	END
	ENDCASE
 
	GOTO, LOOP
 
DONE0:	PRINT,'   Processing complete.'
ABRT:	psterm, noplot=noplot
 
DONE:	CLOSE, LUN
	FREE_LUN, LUN
	RETURN
 
ERR:	PRINT,' Could not open file ' + F
	GOTO, DONE
 
	END
