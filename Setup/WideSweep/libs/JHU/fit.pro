;-------------------------------------------------------------
;+
; NAME:
;       FIT
; PURPOSE:
;       Curve fit program. Polynomial, exponential, power law.
; CATEGORY:
; CALLING SEQUENCE:
;       fit, x, y, [cur]
; INPUTS:
;       x,y = input curve data arrays.                      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       cur = optional description of the last fit done.    out
;          cur has following format:
;          cur = [FTYPE, XOFF, YOFF, NDEG, C0, C1, ..., Cn]
;                for polynomial,
;          cur = [FTYPE, XOFF, YOFF, A, B]
;                for exponential and power law.
;          Useful for generating data using the fitted curve
;          by calling y = gen_fit( x, cur)
;          where x and cur are inputs, y is generated output.
;       
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  13 Oct, 1986.
;       RES 9 Oct, 1989 --- converted to SUN.
;       R. Sterner, 2003 Oct 07 --- Set YOFF to float. Minor plot upgrade.
;       R. Sterner, 2003 Oct 22 --- Added /YNOZ to linear Y plots.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO FIT, X0, Y0, CUR, help=hlp
 
	IF (N_PARAMS(0) LT 2) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Curve fit program. Polynomial, exponential, power law.'
	  PRINT,' fit, x, y, [cur]'
	  PRINT,'   x,y = input curve data arrays.                      in'
	  PRINT,'   cur = optional description of the last fit done.    out'
	  PRINT,'      cur has following format:'
	  PRINT,'      cur = [FTYPE, XOFF, YOFF, NDEG, C0, C1, ..., Cn]'
	  print,'            for polynomial,'
	  PRINT,'      cur = [FTYPE, XOFF, YOFF, A, B]'
	  print,'            for exponential and power law.'
	  PRINT,'      Useful for generating data using the fitted curve'
	  print,'      by calling y = gen_fit( x, cur)'
	  print,'      where x and cur are inputs, y is generated output.'
	  PRINT,' '
	  RETURN
	ENDIF
 
;-------------  initialize  -------------
	ON_IOERROR, MENU	; avoid conversion error problems.
 
	TXT = ''		; scratch text string.
	X = X0			; save data arrays.
	Y = Y0
	FITFLAG = 0		; no fit yet.
 
	PTYPE = [0,0]		; plot type.
	PTYPETXT = '(X = '
	IF PTYPE(0) EQ 0 THEN BEGIN
	  PTYPETXT = PTYPETXT + 'Linear, '
	ENDIF ELSE BEGIN
	  PTYPETXT = PTYPETXT + 'Log, '
	ENDELSE
	IF PTYPE(1) EQ 0 THEN BEGIN
	  PTYPETXT = PTYPETXT + 'Y = Linear).'
	ENDIF ELSE BEGIN
	  PTYPETXT = PTYPETXT + 'Y = Log).'
	ENDELSE
 
	FTYPE = 0		; curve fit type.
	CASE FTYPE OF
0:	FTYPETXT = '(Polynomial).'
1:	FTYPETXT = '(Exponential).'
2:	FTYPETXT = '(Power Law).'
ELSE:	FTYPETXT = '(Unkown, ERROR).'
	ENDCASE
 
	XOFF = 0.		; offsets.
	YOFF = 0.
	XOFFTXT = '(X offset = '+STRTRIM(XOFF,2)+').'
	YOFFTXT = '(Y offset = '+STRTRIM(YOFF,2)+').'
 
	LO= 0			; subset.
	HI = N_ELEMENTS(Y) - 1
	SUBTXT = '('+STRTRIM(LO,2)+' to '+STRTRIM(HI,2)+').'
 
	PSYM = 2
	if hi gt 50 then psym = 1
	CASE PSYM OF
0:	SYMTXT = '(none).'
1:	SYMTXT = '( + ).'
2:	SYMTXT = '( * ).'
ELSE:	SYMTXT = '( unknown, ERROR ).'
	ENDCASE
;----------------------------------------------------------
 
 
;-------------  Menu  ---------------------
	PRINT,' '
	PRINT,'---==< Fit function to 1-d data  >==---'
MENU:	PRINT,' '
	PRINT,'1 --- Plot data.'
	PRINT,'2 --- Plot data and fitted curve.'
	PRINT,'3 --- Plot residual errors for last fit.'
	PRINT,'4 --- Change plot type ' + PTYPETXT
	PRINT,'5  -- Set symbol for data overplot ' + SYMTXT
	PRINT,' '
	PRINT,'6 --- Do curve fit.'
	PRINT,'7 --- Change fit type ' + FTYPETXT
	PRINT,'8 --- Change data subset ' + SUBTXT
	PRINT,'9 --- Change X offset ' + XOFFTXT
	PRINT,'10 -- Change Y offset ' + YOFFTXT
	PRINT,' '
	PRINT,'11 -- Gives statistics for data.'
	PRINT,'12 -- Hardcopy plot of data and fitted curve.' 
menu2:	PRINT,' '
	OPT = ENTER('BYTE','Enter option (? for help): ',99,EXFLAG)
	IF EXFLAG EQ 1 THEN GOTO, DONE
;-------------------------------------------------------
 
 
;-------------  process options  -----------------------
PRC:	IF OPT EQ 1 THEN BEGIN
	  wshow
	  if (ptype(0) eq 0) and (ptype(1) eq 0) then plot, $
	    x(lo:hi), y(lo:hi), psym=psym, /ynoz
	  if (ptype(0) eq 1) and (ptype(1) eq 0) then plot_oi, $
	    x(lo:hi), y(lo:hi), psym=psym, /ynoz
	  if (ptype(0) eq 0) and (ptype(1) eq 1) then plot_io, $
	    x(lo:hi), y(lo:hi), psym=psym
	  if (ptype(0) eq 1) and (ptype(1) eq 1) then plot_oo, $
	    x(lo:hi), y(lo:hi), psym=psym
	  TXT = ENTER('STRING','Press RETURN to continue. ','',EXFLAG)
	  IF EXFLAG EQ 1 THEN GOTO, DONE
	  IF TXT NE '' THEN BEGIN
	    OPT = TXT + 0
	    GOTO, PRC
	  ENDIF
	  GOTO, MENU
	ENDIF
 
	IF OPT EQ 2 THEN BEGIN
	  IF FITFLAG EQ 0 THEN BEGIN
	    PRINT,'No fit to plot.'
	    GOTO, MENU2
	  ENDIF
	  XP = MAKEN(MIN(X(LO:HI)), MAX(X(LO:HI)), 100)
	  YP = gen_fit(xp, cur)
	  if (ptype(0) eq 0) and (ptype(1) eq 0) then plot, $
	    x(lo:hi), y(lo:hi), psym=psym, /ynoz
	  if (ptype(0) eq 1) and (ptype(1) eq 0) then plot_oi, $
	    x(lo:hi), y(lo:hi), psym=psym, /ynoz
	  if (ptype(0) eq 0) and (ptype(1) eq 1) then plot_io, $
	    x(lo:hi), y(lo:hi), psym=psym
	  if (ptype(0) eq 1) and (ptype(1) eq 1) then plot_oo, $
	    x(lo:hi), y(lo:hi), psym=psym
	  wshow
	  OPLOT, XP, YP, line=0, col=255, thick=2
	  TXT = ENTER('STRING','Press RETURN to continue. ','',EXFLAG)
	  IF EXFLAG EQ 1 THEN GOTO, DONE
	  IF TXT NE '' THEN BEGIN
	    OPT = TXT + 0
	    GOTO, PRC
	  ENDIF
	  GOTO, MENU
	ENDIF
 
	IF OPT EQ 3 THEN BEGIN
	  IF FITFLAG EQ 0 THEN BEGIN
	    PRINT,'No fit done yet, so no errors to plot.'
	    GOTO, MENU2
	  ENDIF
	  PLOT, X(LO:HI), ERR0, $
	    title='Residual errors of fit on selected subset'
	  TXT = ENTER('STRING','Press RETURN to continue. ','',EXFLAG)
	  IF EXFLAG EQ 1 THEN GOTO, DONE
	  IF TXT NE '' THEN BEGIN
	    OPT = TXT + 0
	    GOTO, PRC
	  ENDIF
	  GOTO, MENU
	ENDIF
 
	IF OPT EQ 4 THEN BEGIN
	  PRINT,' '
	  PRINT,'Plot types:'
	  PRINT,'  For X = Linear and Y = Linear enter 0 0.'
	  PRINT,'  For X = Linear and Y = Log    enter 0 1.'
	  PRINT,'  For X = Log and Y = Linear    enter 1 0.'
	  PRINT,'  For X = Log and Y = Log       enter 1 1.'
	  PRINT,' '
	  PRINT,'Select type of plot: ', format='($,a)'
	  txt = ''
	  read, '', txt
	  if txt eq '' then goto, menu
	  txt = repchr(txt,',')
	  ptype(0) = getwrd(txt,0) + 0
	  ptype(1) = getwrd(txt,1) + 0
	  PTYPETXT = '(X = '
	  IF PTYPE(0) EQ 0 THEN BEGIN
	    PTYPETXT = PTYPETXT + 'Linear, '
	  ENDIF ELSE BEGIN
	    PTYPETXT = PTYPETXT + 'Log, '
	  ENDELSE
	  IF PTYPE(1) EQ 0 THEN BEGIN
	    PTYPETXT = PTYPETXT + 'Y = Linear).'
	  ENDIF ELSE BEGIN
	    PTYPETXT = PTYPETXT + 'Y = Log).'
	  ENDELSE
	  GOTO, MENU
	ENDIF
 
	IF OPT EQ 5 THEN BEGIN
	  PRINT,' '
	  PRINT,'Overplot symbol may be + or *.'
	  TXT=ENTER('STRING','Select overplot symbol (def = none): ','',EXFLAG)
	  CASE TXT OF
'+':	  PSYM = 1
'*':	  PSYM = 2
ELSE:	  PSYM = 0
	  ENDCASE
	  CASE PSYM OF
0:	  SYMTXT = '(none).'
1:	  SYMTXT = '( + ).'
2:	  SYMTXT = '( * ).'
ELSE:	  SYMTXT = '( unknown, ERROR ).'
	  ENDCASE
	  GOTO, MENU
	ENDIF
 
	;------  process option 6  --------
	if opt eq 6 then begin
	  fit6,x,y,lo,hi,xoff,yoff,ftype,cur,err0,go,fitflag,opt
	  if go eq 1 then goto, done
	  if go eq 2 then goto, menu
	  if go eq 3 then goto, prc
	endif
 
	IF OPT EQ 7 THEN BEGIN
	  PRINT,' '
	  PRINT,'1 --- Polynomial'
	  PRINT,'  Y = a0 + a1*X + a2*X^2 + ... + an*X^n'
	  PRINT,' '
	  PRINT,'2 --- Exponential'
	  PRINT,'  Y = A*Exp(B*X)'
	  PRINT,' '
	  PRINT,'3 --- Power Law'
	  PRINT,'  Y = A*X^B'
	  PRINT,' '
	  PRINT,'Both X and Y may have a specified offset.'
	  TXT = ENTER('STRING','Select type of fit: ','',EXFLAG)
	  IF EXFLAG EQ 1 THEN GOTO, DONE
	  IF TXT EQ '' THEN GOTO, MENU
	  FTYPE = TXT - 1		; curve fit type.
	  CASE FTYPE OF
0:	    FTYPETXT = '(Polynomial).'
1:	    FTYPETXT = '(Exponential).'
2:	    FTYPETXT = '(Power Law).'
ELSE:	    FTYPETXT = '(Unkown, ERROR).'
	  ENDCASE
	  IF FTYPE EQ 0 THEN BEGIN
	    PRINT,'Note: Changing Yoff for a polynomial only causes'
	    PRINT,'  a0 to change.  It does not change the goodness of fit.'
	  ENDIF
	  IF FTYPE EQ 1 THEN BEGIN
	    PRINT,'Note: Changing Xoff for an exponential only causes'
	    PRINT,'  A to change.  It does not change the goodness of fit.'
	  ENDIF
	  GOTO, MENU
	ENDIF
 
	IF OPT EQ 8 THEN BEGIN
	  PRINT,'Select data subset'
	  PRINT,'Current: LO = '+STRTRIM(LO,2)
	  PRINT,'       LO X = '+STRTRIM(X(LO),2)
	  PRINT,'Current: HI = '+STRTRIM(HI,2)
	  PRINT,'       HI X = '+STRTRIM(X(HI),2)
	  LO = enter('long','Enter new LO (def = current): ',LO)
	  HI = enter('long','Enter new HI (def = current): ',HI)
	  PRINT,'       LO X = '+STRTRIM(X(LO),2)
	  PRINT,'       HI X = '+STRTRIM(X(HI),2)
	  SUBTXT = '('+STRTRIM(LO,2)+' to '+STRTRIM(HI,2)+').'
	  GOTO, MENU
	ENDIF
 
	IF OPT EQ 9 THEN BEGIN
	  XOFF = enter('float','Enter X offset (def = 0): ',0)
	  XOFFTXT = '(X offset = '+STRTRIM(XOFF,2)+').'
	  GOTO, MENU
	ENDIF
 
	IF OPT EQ 10 THEN BEGIN
	  YOFF = enter('float','Enter Y offset (def = 0): ',0)
	  YOFFTXT = '(Y offset = '+STRTRIM(YOFF,2)+').'
	  GOTO, MENU
	ENDIF
 
	IF OPT EQ 11 THEN BEGIN
	  PRINT,' '
	  PRINT,'Data statistics for selected subset:'
	  PRINT,'Number of data points: ',N_ELEMENTS(X(LO:HI))
	  PRINT,'Min X: ',MIN(X(LO:HI))
	  PRINT,'Max X: ',MAX(X(LO:HI))
	  PRINT,'Mean X: ',MEAN(X(LO:HI))
	  PRINT,'Std Dev X: ',SDEV(X(LO:HI))
	  PRINT,'Min Y: ',MIN(Y(LO:HI))
	  PRINT,'Max Y: ',MAX(Y(LO:HI))
	  PRINT,'Mean Y: ',MEAN(Y(LO:HI))
	  PRINT,'Std Dev Y: ',SDEV(Y(LO:HI))
	  TXT = ENTER('STRING','Press RETURN to continue. ','',EXFLAG)
	  IF EXFLAG EQ 1 THEN GOTO, DONE
	  IF TXT NE '' THEN BEGIN
	    OPT = TXT + 0
	    GOTO, PRC
	  ENDIF
	  GOTO, MENU
	ENDIF
 
	if opt eq 12 then begin
	  if fitflag eq 0 then begin
	    print,' No fit to plot.'
	    goto, menu2
	  endif
	  print,' Plotting fit . . .'
	  fit12,x,y,lo,hi,xoff,yoff,ftype,ptype,psym,cur,err0
	  print,' Fit plotted.'
	  goto, menu2
	endif
 
	GOTO, MENU
 
DONE:   RETURN
	END
