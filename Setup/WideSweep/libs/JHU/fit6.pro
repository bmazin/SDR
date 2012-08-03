;-------------------------------------------------------------
;+
; NAME:
;       FIT6
; PURPOSE:
;       For internal use by FIT only.
; CATEGORY:
; CALLING SEQUENCE:
;       fit6,x,y,xoff,yoff,ftype,cur,err0,go,fitflag,opt
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 9 Oct, 1989.
;       R. Sterner, 2003 Oct 07 --- Changed sign of yoff in fit type 2.
;       R. Sterner, 2003 Oct 07 --- Also listed fit with numeric values.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro fit6, x, y, lo, hi, xoff, yoff, ftype, cur, err0, go, $
	  fitflag, opt, help=hlp
 
	if (n_params(0) lt 12) or keyword_set(hlp) then begin
	  print,' For internal use by FIT only.'
	  print,' fit6,x,y,xoff,yoff,ftype,cur,err0,go,fitflag,opt'
	  return
	endif
 
	  XF = DOUBLE(X(LO:HI)) + XOFF
	  YF = DOUBLE(Y(LO:HI)) + YOFF
	  IF FTYPE EQ 0 THEN BEGIN
	    TXT = ENTER('STRING','Degree of polynomial to use: ','',EXFLAG)
	    IF EXFLAG EQ 1 THEN begin
	      go = 1	; goto, done
	      return
	    end
	    IF TXT EQ '' THEN begin
	      go = 2	; goto, menu
	      return
	    end
	    NDEG = TXT + 0
	    COEFF = POLY_FIT(XF, YF, NDEG)
	    PRINT,'   Y = Yoff + a0 + a1*(X+Xoff) + a2*(X+Xoff)^2 +'+$
	      ' ... + an*(X+Xoff)^n'
	    PRINT,'   Where'
	    FOR I = 0, N_ELEMENTS(COEFF)-1 DO BEGIN
	      PRINT,'   a' + STRTRIM(I,2) + ': = ', COEFF(I)
	    ENDFOR
	    PRINT,'   Xoff = ',XOFF
	    PRINT,'   Yoff = ',YOFF
	    PRINT,' '
	    CUR = DBLARR(NDEG+5)
	    CUR(0) = [FTYPE,XOFF,YOFF,NDEG,TRANSPOSE(COEFF)]
	    ;----  List fit equation with numbers  ------
	    xoff2 = xoff
	    if xoff2 eq long(xoff2) then xoff2=long(xoff2)
	    yoff2 = yoff
	    if yoff2 eq long(yoff2) then yoff2=long(yoff2)
	    if xoff2 ne 0 then xtxt='(X+'+strtrim(xoff2,2)+')' else xtxt='X'
	    if yoff2 ne 0 then ytxt = strtrim(yoff2,2) else ytxt=''
	    txt = ' Yp = '+ytxt
	    last = n_elements(coeff)-1
	    for i=0, last do begin
	      a = coeff(i)
	      if a lt 0 then op='-' else op = '+'
	      txt = txt + op + strtrim(abs(a),2)
	      if i gt 0 then txt = txt+'*'+xtxt
	      if i gt 1 then txt = txt+'^'+strtrim(i,2)
	    endfor
	    print,txt
	    print,' '
	    
	    GOTO, ERR
	  ENDIF
	  IF FTYPE EQ 1 THEN BEGIN
	    IF MIN(YF) LE 0. THEN BEGIN
	      PRINT,'Error: Y - Yoff has points <= 0.'
	      fitflag = 0
	      go = 2	; goto, menu
	      return
	    ENDIF
	    YF = ALOG(YF)
	    COEFF = POLY_FIT(XF, YF, 1)
	    A = EXP(COEFF(0))
	    B = COEFF(1)
;	    PRINT,'   Y = A*Exp(B*(X+Xoff)) + Yoff'
	    PRINT,'   Y = A*Exp(B*(X+Xoff)) - Yoff'
	    PRINT,'   Where'
	    PRINT,'   A = ', A
	    PRINT,'   B = ', B
	    PRINT,'   Xoff = ',XOFF
	    PRINT,'   Yoff = ',YOFF
	    PRINT,' '
	    CUR = DBLARR(5)
	    CUR(0) = [FTYPE,XOFF,YOFF,A,B]
	    ;----  List fit equation with numbers  ------
	    if abs(a-1) lt 1e-8 then atxt = '' else $
	      if abs(a+1) lt 1e-8 then atzt = '-' else $
	        atxt = strtrim(a,2)+'*'
	    if abs(b-1) lt 1e-8 then btxt='' else $
	      if abs(b+1) lt 1e-8 then btxt='-' else $
	        btxt = strtrim(b,2)+'*'
	    xoff2 = xoff
	    if xoff2 eq long(xoff2) then xoff2=long(xoff2)
	    yoff2 = yoff
	    if yoff2 eq long(yoff2) then yoff2=long(yoff2)
	    if xoff2 ne 0 then xtxt='(X+'+strtrim(xoff2,2)+')' else xtxt='X'
	    if yoff2 ne 0 then begin
	      if yoff2 gt 0 then ytxt = ' - '+strtrim(yoff2,2)
	      if yoff2 lt 0 then ytxt = ' + '+strtrim(-yoff2,2)
	    endif
	    txt = ' Yp = '+atxt+'EXP('+btxt+xtxt+')'
	    if yoff2 ne 0 then txt = txt + ytxt
	    print,txt
	    print,' '
 
	    GOTO, ERR
	  ENDIF
	  IF FTYPE EQ 2 THEN BEGIN
	    IF MIN(XF) LE 0. THEN BEGIN
	      PRINT,'Error: X + Xoff has points <= 0.'
	      fitflag = 0
	      go = 2	; goto, menu
	      return
	    ENDIF
	    XF = ALOG(XF)
	    IF MIN(YF) LE 0. THEN BEGIN
	      PRINT,'Error: Y - Yoff has points <= 0.'
	      fitflag = 0
	      go = 2	; goto, menu
	      return
	    ENDIF
	    YF = ALOG(YF)
	    COEFF = POLY_FIT(XF, YF, 1)
	    A = EXP(COEFF(0))
	    B = COEFF(1)
	    PRINT,'   Y = A*(X+Xoff)^B + Yoff'
	    PRINT,'   Where'
	    PRINT,'   A = ', A
	    PRINT,'   B = ', B
	    PRINT,'   Xoff = ',XOFF
	    PRINT,'   Yoff = ',YOFF
	    PRINT,' '
	    CUR = DBLARR(5)
	    CUR(0) = [FTYPE,XOFF,YOFF,A,B]
	    ;----  List fit equation with numbers  ------
	    if abs(a-1) lt 1e-8 then atxt = '' else $
	      if abs(a+1) lt 1e-8 then atzt = '-' else $
	        atxt = strtrim(a,2)+'*'
	    if abs(b-1) lt 1e-8 then btxt='' else $
	      if abs(b+1) lt 1e-8 then btxt='^(-1)' else $
	        if b lt 0 then btxt = '^('+strtrim(b,2)+')' else $
	        btxt = '^'+strtrim(b,2)
	    xoff2 = xoff
	    if xoff2 eq long(xoff2) then xoff2=long(xoff2)
	    yoff2 = yoff
	    if yoff2 eq long(yoff2) then yoff2=long(yoff2)
	    if xoff2 ne 0 then xtxt='(X+'+strtrim(xoff2,2)+')' else xtxt='X'
	    if yoff2 ne 0 then begin
	      if yoff2 gt 0 then ytxt = ' + '+strtrim(yoff2,2)
	      if yoff2 lt 0 then ytxt = ' - '+strtrim(-yoff2,2)
	    endif
	    txt = ' Yp = '+atxt+xtxt+btxt
	    if yoff2 ne 0 then txt = txt + ytxt
	    print,txt
	    print,' '
	    GOTO, ERR
	  ENDIF
ERR:	  FITFLAG = 1
	  XP = X(LO:HI)
	  yp = gen_fit(xp, cur)
	  ERR0 = YP - Y(LO:HI)
	  PRINT,'For selected subset:'
	  XP = X(LO:HI)
	  MERR = MAX(ABS(ERR0))
	  PRINT,' Worst error of fit: ',strtrim(ERR0(!C),2),' at X = ',$
	    strtrim(XP(!C),2)
	  PRINT,' Mean magnitude of error of fit: ',strtrim(MEAN(ABS(ERR0)),2)
	  i = check_math(0,1)
	  ERR = 100*ERR0/max(abs(Y(LO:HI)))
	  i = check_math(0,0)
	  MERR = MAX(ABS(ERR))
	  PRINT,' Worst % error of fit (% of max): ',strtrim(ERR(!C),2),$
	    ' at X = ',strtrim(XP(!C),2)
	  PRINT,' Mean magnitude of % error of fit (% of max): ',$
	    strtrim(MEAN(ABS(ERR)),2)
	  PRINT,' '
	  TXT = ENTER('STRING','Press RETURN to continue.','',EXFLAG)
	  IF EXFLAG EQ 1 THEN begin
	    go = 1	; goto, done
	    return
	  end
	  IF TXT NE '' THEN BEGIN
	    OPT = TXT + 0
	    go = 3	; goto, prc
	    return
	  ENDIF
	  go = 2	; goto, menu
	  return
 
	END
