function sfit2, z, degree, kx=kx
;+
; NAME:
;   SFIT
;
; PURPOSE:
;   This function determines a polynomial fit to a surface.
;
; CATEGORY:
;   Curve and surface fitting.
;
; CALLING SEQUENCE:
;   Result = SFIT(Data, Degree)
;
; INPUTS:
;   Data:     The two-dimensional array of data to fit. The sizes of
;        the dimensions may be unequal.
;
;   Degree:   The maximum degree of fit (in one dimension).
;
; OUTPUT:
;   This function returns a fitted array.
;
; OUTPUT KEYWORDS:
;   Kx:  The array of coefficients for a polynomial function
;        of x and y to fit data.
;        This parameter is returned as a (Degree+1) by (Degree+1)
;        element array.
;
; PROCEDURE:
;   Fit a 2D array Z as a polynomial function of x and y.
;   The function fitted is:
;       F(x,y) = Sum over i and j of kx(j,i) * x^i * y^j
;   where kx is returned as a keyword.
;
; MODIFICATION HISTORY:
;   July, 1993, DMS          Initial creation
;
;-

   on_error, 2

   s = size(z)
   nx = s(1)
   ny = s(2)
   m = nx * ny          ;# of points to fit
   n2=(degree+1)^2      ;# of coefficients to solve
   x = (findgen(nx)-fix(nx/2)) # replicate(1., ny)   ;X values at each point
   y = replicate(1.,nx) # (findgen(ny)-fix(ny/2))

   ut = dblarr(n2, m, /nozero)
   for i=0, degree do for j=0,degree do $
    ut(i*(degree+1) + j, 0) = reform(abs(x^i * y^j), 1, m)

   kk = invert(ut # transpose(ut)) # ut
   kx = fltarr(degree+1, degree+1) + float(kk # reform(z, m, 1))
   fit = reform(reform(kx,n2) # ut, nx, ny)
   return, fit
end


