;-------------------------------------------------------------
;+
; NAME:
;       STK_LINREG
; PURPOSE:
;       Fit line by linear regression to columns in a stack of images.
; CATEGORY:
; CALLING SEQUENCE:
;       stk_linreg, xx, yy, m, b, r2
; INPUTS:
;       xx = x values for each pixel in stack (3-D).          in
;       yy = stack of images (3-D).                           in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       m = Slope of fit for each column in stk (2-D).        out
;       b = y-intercept of fit for each column in stk (2-D).  out
;       r2 = Correlation coeficient for each column (2-D).    out
; COMMON BLOCKS:
; NOTES:
;       Notes: yy is a stack of images.  So it is a 3-D array.
;       xx is the corresponding 3-D array that gives the x value
;       for each image pixel.  Let each image have size nx by ny,
;       and let there be nz images.  Then to generate an xx array
;       that is the index of each image do the following:
;         t = reform(findgen(nz),1,1,nz) ; Make a single column of indices.
;         xx = rebin(t,nx,ny,nz,/samp)   ; Now make full 3-D indices.
;       
;       Reference: http://mathworld.wolfram.com/LeastSquaresFitting.html
;       
;       Example:
;          nx=5 & ny=8 & nz=10                         ; Dimensions of stack.
;          t = reform(findgen(nz),1,1,nz)              ; Column of indices.
;          xx = rebin(t,nx,ny,nz,/samp)                ; Full index array.
;          yy = xx*27 + 73 + randomu(k,nx,ny,nz)*30    ; Make a noisy line.
;          stk_linreg,xx,yy,m,b,r2                     ; Do fits.
;          hlp,m,b,r2                                  ; Check.
;          ; 1   Float array (5, 8).   Min = 25.2887,  Max = 28.7566
;          ; 2   Float array (5, 8).   Min = 76.2687,  Max = 98.0477
;          ; 3   Float array (5, 8).   Min = 0.982812,  Max = 0.995149
;          plot,xx(2,3,*),yy(2,3,*),psym=-2
;          x = findgen(10)
;          oplot,x,x*m(2,3)+b(2,3),col=255
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jan 27
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro stk_linreg, xx, yy, m, b, r2, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Fit line by linear regression to columns in a stack of images.'
	  print,' stk_linreg, xx, yy, m, b, r2'
	  print,'   xx = x values for each pixel in stack (3-D).          in'
	  print,'   yy = stack of images (3-D).                           in'
	  print,'   m = Slope of fit for each column in stk (2-D).        out'
	  print,'   b = y-intercept of fit for each column in stk (2-D).  out'
	  print,'   r2 = Correlation coeficient for each column (2-D).    out'
	  print,' Notes: yy is a stack of images.  So it is a 3-D array.'
	  print,' xx is the corresponding 3-D array that gives the x value'
	  print,' for each image pixel.  Let each image have size nx by ny,'
	  print,' and let there be nz images.  Then to generate an xx array'
	  print,' that is the index of each image do the following:'
	  print,'   t = reform(findgen(nz),1,1,nz) ; Make a single column of indices.'
	  print,'   xx = rebin(t,nx,ny,nz,/samp)   ; Now make full 3-D indices.'
	  print,' '
	  print,' Reference: http://mathworld.wolfram.com/LeastSquaresFitting.html'
	  print,' '
	  print,' Example:'
	  print,'    nx=5 & ny=8 & nz=10                         ; Dimensions of stack.'
	  print,'    t = reform(findgen(nz),1,1,nz)              ; Column of indices.'
	  print,'    xx = rebin(t,nx,ny,nz,/samp)                ; Full index array.'
	  print,'    yy = xx*27 + 73 + randomu(k,nx,ny,nz)*30    ; Make a noisy line.'
	  print,'    stk_linreg,xx,yy,m,b,r2                     ; Do fits.'
	  print,'    hlp,m,b,r2                                  ; Check.'
	  print,'    ; 1   Float array (5, 8).   Min = 25.2887,  Max = 28.7566'
	  print,'    ; 2   Float array (5, 8).   Min = 76.2687,  Max = 98.0477'
	  print,'    ; 3   Float array (5, 8).   Min = 0.982812,  Max = 0.995149'
	  print,'    plot,xx(2,3,*),yy(2,3,*),psym=-2'
	  print,'    x = findgen(10)'
	  print,'    oplot,x,x*m(2,3)+b(2,3),col=255'
	  return
	endif
 
	sz = size(xx)
	nx = sz(1)
	ny = sz(2)
	nz = sz(3)
 
	xave = rebin(total(xx,3)/nz,nx,ny,nz,/samp)	; Mean xx.
	yave = rebin(total(yy,3)/nz,nx,ny,nz,/samp)	; Mean yy.
 
	sxy = total((xx-xave)*(yy-yave),3)
	sxx = total((xx-xave)^2,3)
	syy = total((yy-yave)^2,3)
 
	m = sxy/sxx			; Slope.
 
	b = yave - m*xave		; Y-intercept.
 
	r2 = sxy^2/(sxx*syy)		; Corellation coeficient.
 
	end
