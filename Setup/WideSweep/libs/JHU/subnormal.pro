;-------------------------------------------------------------
;+
; NAME:
;       SUBNORMAL
; PURPOSE:
;       Convert from subnormal coordinates to normalized coord.
; CATEGORY:
; CALLING SEQUENCE:
;       subnormal, xsn, ysn, xn, yn
; INPUTS:
;       xsn, ysn = a point in sub-normal coordinates.                 in
;       psn = position parameter in sub-normal coordinates.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         /CM means that (xsn,ysn) or psn is specified in cm instead
;             of sub-normal coordinates.
;         WINDOW=n  Sets the subwindow to use.  Over-rides !p.multi.
;             If n > # subwindows then subnormal automatically wraps n.
;         /LASTWINDOW uses last plot window.
; OUTPUTS:
;       xn, yn = point converted to normalized coordinates.           out
;       or
;       subnormal, psn, pn
;         pn = position parameter converted to normalized coordinates.  out
;           where the position parameter has the format: [x1,y1,x2,y2]
;           with (x1,y1) being the lower left corner of the plot,
;           and  (x2,y2) being the upper right corner of the plot.
;           If x2 or y2 is 0 (but not both) the plot is forced to be square.
; COMMON BLOCKS:
; NOTES:
;       Notes: Sub-normal coordinates range from 0 to 1 in the plot sub-area.
;         These coordinates arise for multiple plots per pages obtained by
;         using !p.multi.  The position keyword always works in normalized
;         coordinates which always range from 0 to 1 for the entire plot area.
;         Ex: subnormal,[.2,.2,.8,.8],p & plot,x,y,position=p
;         For multiple page plots subnormal must be called before each plot.
;         For single points: subnormal,.3,.7,xn,yn & xyouts,xn,yn,'test',/norm.
;           (Must use keyword /norm in xyouts to force normalized coordinates,
;            plot position keyword uses normalized coordinates by default).
; MODIFICATION HISTORY:
;       R. Sterner,  12 Nov, 1989
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro subnormal, a1, a2, a3, a4, help=hlp, cm=c, window=win, $
	  lastwindow=last
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert from subnormal coordinates to normalized coord.'
	  print,' subnormal, xsn, ysn, xn, yn'
	  print,'   xsn, ysn = a point in sub-normal coordinates.'+$
	    '                 in'
	  print,'   xn, yn = point converted to normalized coordinates.'+$
	    '           out'
	  print,' or'
	  print,' subnormal, psn, pn'
	  print,'   psn = position parameter in sub-normal coordinates.'+$
	    '           in'
	  print,'   pn = position parameter converted to normalized'+$
	    ' coordinates.  out'
	  print,'     where the position parameter has the format: '+$
	    '[x1,y1,x2,y2]'
	  print,'     with (x1,y1) being the lower left corner of the plot,'
	  print,'     and  (x2,y2) being the upper right corner of the plot.'
	  print,'     If x2 or y2 is 0 (but not both) the plot is forced '+$
	    'to be square.'
	  print,' Keywords:'
	  print,'   /CM means that (xsn,ysn) or psn is specified in cm instead'
	  print,'       of sub-normal coordinates.'
	  print,'   WINDOW=n  Sets the subwindow to use.  Over-rides !p.multi.'
	  print,'       If n > # subwindows then subnormal automatically '+$
	    'wraps n.'
	  print,'   /LASTWINDOW uses last plot window.'
	  print,' Notes: Sub-normal coordinates range from 0 to 1 in the '+$
	    'plot sub-area.'
	  print,'   These coordinates arise for multiple plots per pages '+$
	    'obtained by'
	  print,'   using !p.multi.  The position keyword always works in '+$
	    'normalized'
	  print,'   coordinates which always range from 0 to 1 for the '+$
	    'entire plot area.' 
	  print,'   Ex: subnormal,[.2,.2,.8,.8],p & plot,x,y,position=p'
	  print,'   For multiple page plots subnormal must be called before '+$
	    'each plot.'
	  print,"   For single points: subnormal,.3,.7,xn,yn & xyouts,xn,yn,"+$
	    "'test',/norm."
	  print,'     (Must use keyword /norm in xyouts to force normalized '+$
	    'coordinates,'
	  print,'      plot position keyword uses normalized coordinates by '+$
	    'default).'
	  return
	endif
 
	m = !p.multi		; Extract values from !p.multi.
	nw = m(0)
	nx = m(1) > 1		; Must have at least 1x1 plots in window.
	ny = m(2) > 1
	nn = nx*ny		; Total number of sub-areas.
	;---  window number given, over-rides value from !p.multi. -----
	if n_elements(win) ne 0 then nw = (((nn - win) mod nn) + nn) mod nn
	if keyword_set(last) then nw = (nw+1) mod nn	; Use last plot window.
	np = n_params(0)
 
	;----  error check 2 arg call (position parameter) -----
	if np eq 2 then begin
	  a2 = float(a1)
	endif  ; np eq 2
	;----  error check 4 arg call (x,y) -----
	if np eq 4 then begin
	  a3 = float(a1)
	  a4 = float(a2)
	  if not keyword_set(c) then begin	; Not cm, must be in 0 to 1.
	    w = where((a3 gt 1.) or (a3 lt 0.), count)
	    if count gt 0 then begin
;	      print,' Error in subnormal.  Coordinates must be from 0 to 1.'
	    endif
	    w = where((a4 gt 1.) or (a4 lt 0.), count)
	    if count gt 0 then begin
;	      print,' Error in subnormal.  Coordinates must be from 0 to 1.'
	    endif
	  endif  ; keyword.
	endif  ; np eq 4
 
	nw = (nn-nw) mod nn	; Convert to windows numbered 0,1,2,...
	iy = nw/nx		; Sub-window number in Y.
	ix = nw mod nx		; Sub-window number in X.
	dx = 1./nx		; Sub-window x size.
	dy = 1./ny		; Sub-window y size.
	x0 = ix*dx		; Sub-window corner.
	y0 = 1. - iy*dy - dy
 
	;------  convert single x,y  --------
	if np eq 4 then begin
	  x = float(a1)
	  y = float(a2)
	  if keyword_set(c) then cm2norm,x*nx,y*ny,x,y
	  a3 = x0 + x*dx
	  a4 = y0 + y*dy
	  return
	endif
 
	;-----  convert position keyword array  -------
	if np eq 2 then begin
	  xx = [0,2]
	  yy = [1,3]
	  psn = float(a1)
	  if keyword_set(c) then cm2norm, psn*[nx,ny,nx,ny], psn
	  if psn(2) le 0. then begin		; Make dx eq dy.
	    x_size = !d.x_size/float(nx)
	    y_size = !d.y_size/float(ny)
	    psn(2) = (psn(3)-psn(1))*y_size/x_size + psn(0)
	  endif
	  if psn(3) le 0. then begin		; Make dy eq dx.
	    x_size = !d.x_size/float(nx)
	    y_size = !d.y_size/float(ny)
	    psn(3) = (psn(2)-psn(0))*x_size/y_size + psn(1)
	  endif
	  a2(xx) = x0 + psn(xx)*dx
	  a2(yy) = y0 + psn(yy)*dy
	  if (a2(2)-a2(0)) le 0. then print,$
	    ' Error in subnormal: position window width <= 0'
	  if (a2(3)-a2(1)) le 0. then print,$
	    ' Error in subnormal: position window height <= 0'
	  if total(a2 gt 1.) gt 0 then begin	
	    return
	  endif
	  if total(a2 lt 0.) gt 0 then begin	
	    return
	  endif  ; total
	  return
	endif
 
	print,' Error in subnormal: must call with 2 or 4 args.'
 
	end
