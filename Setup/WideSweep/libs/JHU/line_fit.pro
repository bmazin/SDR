;-------------------------------------------------------------
;+
; NAME:
;       LINE_FIT
; PURPOSE:
;       Fit a line to weighted x,y points.
; CATEGORY:
; CALLING SEQUENCE:
;       line_fit, x, y
; INPUTS:
;       x, y = arrays of x, and y coordinates.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         WEIGHTS=wt Array of weights for points (def=1).
;         XM=xm      Returned weighted mean x.
;         YM=ym      Returned weighted mean y.
;         SLOPE=b0   Returned slope of fitted line.
;         XREG=b1    Regression coefficient of Y on X.
;         YREG=b2    Regression coefficient of X on Y.
;                    (use 1/b2 for slope to plot line)
;         /PLOT      Plot b0 line.
;         /XPLOT     Plot b1 line.  Normal linear regression.
;         /YPLOT     Plot b2 line.
;                    May give plot keywords (plot 1 line at a time).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: By default line is fitted to minimize the sum of
;       the mean square distances from the line using an
;       algorithm by Robert Jensen.  May also specify a regression
;       of Y on X or X on Y.  The fitted line passes through the
;       mean point.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 10
;       R. Sterner, 2007 Apr 24 --- Made sure b1 and b2 defined if used.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro line_fit, x, y, weights=wt, xm=xm, ym=ym, slope=b0, $
	  xreg=b1, yreg=b2, help=hlp, plot=plt, xplot=xplt, yplot=yplt, $
	  _extra=extra
 
	if (n_params() lt 2) or keyword_set(hlp) then begin
	  print,' Fit a line to weighted x,y points.'
	  print,' line_fit, x, y'
	  print,'   x, y = arrays of x, and y coordinates.   in'
	  print,' Keywords:'
	  print,'   WEIGHTS=wt Array of weights for points (def=1).'
	  print,'   XM=xm      Returned weighted mean x.'
	  print,'   YM=ym      Returned weighted mean y.'
	  print,'   SLOPE=b0   Returned slope of fitted line.'
	  print,'   XREG=b1    Regression coefficient of Y on X.'
	  print,'   YREG=b2    Regression coefficient of X on Y.'
	  print,'              (use 1/b2 for slope to plot line)'
	  print,'   /PLOT      Plot b0 line.'
	  print,'   /XPLOT     Plot b1 line.  Normal linear regression.'
	  print,'   /YPLOT     Plot b2 line.'
	  print,'              May give plot keywords (plot 1 line at a time).'
	  print,' Notes: By default line is fitted to minimize the sum of'
	  print,' the mean square distances from the line using an'
	  print,' algorithm by Robert Jensen.  May also specify a regression'
	  print,' of Y on X or X on Y.  The fitted line passes through the'
	  print,' mean point.'
	  return
	endif
 
	n = n_elements(x)
	if n_elements(wt) eq 0 then wt=dblarr(n)+1D0	; Default wts.
 
	xm = total(wt*x)/total(wt)	; Weighted means.
	ym = total(wt*y)/total(wt)
	xx = x-xm			; Deviations from the mean.
	yy = y-ym
 
	wxy = total(wt*xx*yy)
	wxx = total(wt*xx*xx)
	wyy = total(wt*yy*yy)
	b0 = tan(.5*atan(2*wxy,(wxx-wyy)))	; Slope of line.
 
	;-----  Optional regression coefficients  --------------
	if arg_present(b1) then begin
	  b1 = total(wt*xx*yy)/total(wt*xx*xx)	; Regression coeff of Y on X.
	endif
	if arg_present(b2) then begin
	  b2 = total(wt*xx*yy)/total(wt*yy*yy)	; Regression coeff of X on Y.
	endif
 
	;------  Plot line  ----------------
	if keyword_set(plt) then begin
	  x1=min(x,max=x2) & xa=[x1,x2]
	  plots,xa,(xa-xm)*b0+ym, _extra=extra
	endif
	if keyword_set(xplt) then begin
	  if n_elements(b1) eq 0 then $
	    b1 = total(wt*xx*yy)/total(wt*xx*xx)
	  x1=min(x,max=x2) & xa=[x1,x2]
	  plots,xa,(xa-xm)*b1+ym, _extra=extra
	endif
	if keyword_set(yplt) then begin
	  if n_elements(b2) eq 0 then $
	    b2 = total(wt*xx*yy)/total(wt*yy*yy)
	  x1=min(x,max=x2) & xa=[x1,x2]
	  plots,xa,(xa-xm)*(1/b2)+ym, _extra=extra
	endif
 
	end
