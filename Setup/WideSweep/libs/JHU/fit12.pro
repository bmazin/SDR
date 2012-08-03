;-------------------------------------------------------------
;+
; NAME:
;       FIT12
; PURPOSE:
;       For internal use by FIT only.
; CATEGORY:
; CALLING SEQUENCE:
;       fit12,x,y,xoff,yoff,ftype,ptype,cur,err0
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 9 Oct, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro fit12, x, y, lo, hi, xoff, yoff, ftype, ptype, psym, cur, $
	   err0, help=hlp
 
	if (n_params(0) lt 10) or keyword_set(hlp) then begin
	  print,' For internal use by FIT only.'
	  print,' fit12,x,y,xoff,yoff,ftype,ptype,cur,err0
	  return
	endif
 
	  XP = MAKEN(MIN(X(LO:HI)), MAX(X(LO:HI)), 100)
	  YP = gen_fit(xp, cur)
	  psinit, /full
	  pos = [.1,.65,.95,.95]
	  if (ptype(0) eq 0) and (ptype(1) eq 0) then plot, $
	    x(lo:hi), y(lo:hi), psym=psym, pos=pos, symsize=.5
	  if (ptype(0) eq 1) and (ptype(1) eq 0) then plot_oi, $
	    x(lo:hi), y(lo:hi), psym=psym, pos=pos, symsize=.5
	  if (ptype(0) eq 0) and (ptype(1) eq 1) then plot_io, $
	    x(lo:hi), y(lo:hi), psym=psym, pos=pos, symsize=.5
	  if (ptype(0) eq 1) and (ptype(1) eq 1) then plot_oo, $
	    x(lo:hi), y(lo:hi), psym=psym, pos=pos, symsize=.5
	  OPLOT, XP, YP, line=1
 
	  xprint, /init, .1, .55, .7
 
 
	  xprint,'Data statistics:'
	  xPRINT,'Number of data points: ',N_ELEMENTS(X(LO:HI))
	  xPRINT,'Min X: ',MIN(X(LO:HI))
	  xPRINT,'Max X: ',MAX(X(LO:HI))
	  xPRINT,'Mean X: ',MEAN(X(LO:HI))
	  xPRINT,'Std Dev X: ',SDEV(X(LO:HI))
	  xPRINT,'Min Y: ',MIN(Y(LO:HI))
	  xPRINT,'Max Y: ',MAX(Y(LO:HI))
	  xPRINT,'Mean Y: ',MEAN(Y(LO:HI))
	  xPRINT,'Std Dev Y: ',SDEV(Y(LO:HI))
 
	  xprint,' '
	  xprint,'Curve fit:'
	  IF FTYPE EQ 0 THEN BEGIN
	    xprint,'   Polynomial fit'
	    xoff = cur(1)
	    yoff = cur(2)
	    NDEG = cur(3)
	    COEFF = cur(4:*)
	    xPRINT,'   Y = Yoff + a0 + a1*(X+Xoff) + a2*(X+Xoff)^2 +'+$
	      ' ... + an*(X+Xoff)^n'
	    xPRINT,'   Where'
	    FOR I = 0, N_ELEMENTS(COEFF)-1 DO BEGIN
	      xPRINT,'   a' + STRTRIM(I,2) + ': = ', COEFF(I)
	    ENDFOR
	    xPRINT,'   Xoff = ',XOFF
	    xPRINT,'   Yoff = ',YOFF
	    xPRINT,' '
	    GOTO, ERR
	  ENDIF
	  IF FTYPE EQ 1 THEN BEGIN
	    xprint,'   Exponential fit'
	    xoff = cur(1)
	    yoff = cur(2)
	    A = cur(3)
	    B = cur(4)
	    xPRINT,'   Y = A*Exp(B*(X+Xoff)) + Yoff'
	    xPRINT,'   Where'
	    xPRINT,'   A = ', A
	    xPRINT,'   B = ', B
	    xPRINT,'   Xoff = ',XOFF
	    xPRINT,'   Yoff = ',YOFF
	    xPRINT,' '
	    GOTO, ERR
	  ENDIF
	  IF FTYPE EQ 2 THEN BEGIN
	    xprint,'   Power Law fit'
	    xoff = cur(1)
	    yoff = cur(2)
	    A = cur(3)
	    B = cur(4)
	    xPRINT,'   Y = A*(X+Xoff)^B + Yoff'
	    xPRINT,'   Where'
	    xPRINT,'   A = ', A
	    xPRINT,'   B = ', B
	    xPRINT,'   Xoff = ',XOFF
	    xPRINT,'   Yoff = ',YOFF
	    xPRINT,' '
	    GOTO, ERR
	  ENDIF
ERR:	  XP = X(LO:HI)
	  yp = gen_fit(xp, cur)
	  ERR0 = YP - Y(LO:HI)
	  XP = X(LO:HI)
	  MERR = MAX(ABS(ERR0))
	  xPRINT,' Worst error of fit: ',strtrim(ERR0(!C),2),$
	    ' at X = ',strtrim(XP(!C),2)
	  xPRINT,' Mean magnitude of error of fit: ',$
	    strtrim(MEAN(ABS(ERR0)),2)
	  i = check_math(0,1)
	  ERR = 100*ERR0/max(abs(Y(LO:HI)))
	  i = check_math(0,1)
	  MERR = MAX(ABS(ERR))
	  xPRINT,' Worst % error of fit (% of max): ',strtrim(ERR(!C),2),$
	    ' at X = ',strtrim(XP(!C),2)
	  xPRINT,' Mean magnitude of % error of fit (% of max): ',$
	    strtrim(MEAN(ABS(ERR)),2)
	  xPRINT,' '
 
	  psterm
 
	  return
 
	END
