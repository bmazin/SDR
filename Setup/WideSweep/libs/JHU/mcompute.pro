;-------------------------------------------------------------
;+
; NAME:
;       MCOMPUTE
; PURPOSE:
;       Compute mandelbrot set images.
; CATEGORY:
; CALLING SEQUENCE:
;       mcompute, region, out
; INPUTS:
;       region = region in the complex plane to process.       in
;         region = [x1,x2,nx,y1,y2,ny] where
;           x1,x2,nx = min,max, number in real direction,
;           y1,y2,ny = min,max, number in imaginary direction.
; KEYWORD PARAMETERS:
;       Keywords:
;         /SHOW  shows progress of computation on screen.
;         LAST=max.  Set upper limit to # of iterations (def = 100).
; OUTPUTS:
;       out = resulting mandelbrot set image.                  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 19 Nov, 1989
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro mcompute, region, out, help=hlp, show=shw, last=lst
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Compute mandelbrot set images.'
	  print,' mcompute, region, out'
	  print,'   region = region in the complex plane to process.       in'
	  print,'     region = [x1,x2,nx,y1,y2,ny] where'
	  print,'       x1,x2,nx = min,max, number in real direction,'
	  print,'       y1,y2,ny = min,max, number in imaginary direction.'
	  print,'   out = resulting mandelbrot set image.                  out'
	  print,' Keywords:'
	  print,'   /SHOW  shows progress of computation on screen.'
	  print,'   LAST=max.  Set upper limit to # of iterations (def = 100).'
	  return
	endif
 
	timer, /start
 
	print,' Press a to abort'
 
	x1 = region(0) & x2 = region(1) & nx = region(2)
	y1 = region(3) & y2 = region(4) & ny = region(5)
	dx = (x2-x1)/float(nx-1)
	dy = (y2-y1)/float(ny-1)
 
	makexy, x1, x2+dx/10., dx, y1, y2+dy/10., dy, xx, yy
	c = complex(xx,yy)
	z = complexarr(nx, ny)
	ind = lonarr(nx,ny) + lindgen(long(nx)*long(ny))
	out = intarr(nx, ny)
 
	tp = 100
	if keyword_set(lst) then tp = lst
 
	for i=0, tp do begin
	  if get_kbrd(0) eq 'a' then goto, done
	  if get_kbrd(0) eq 'b' then begin
	    print,' Debug stop.  .con to continue.'
	    stop
	  endif
	  z = z^2 + c
	  f = abs(z) gt 2.
	  w1 = where(f eq 1, count1)
	  if count1 gt 0 then begin
	    out(ind(w1)) = i
	    if keyword_set(shw) then begin
	      tvscl,out
	      wait,0
	    endif
	    w0 = where(f eq 0, count0)
	    if count0 lt 1 then goto, done
	    ind = ind(w0)
	    z = z(w0)
	    c = c(w0)
	  endif  ; count1
	endfor
 
done:	timer, /stop, /print
	print,' Number of iterations = ',i-1
	return
 
	end
