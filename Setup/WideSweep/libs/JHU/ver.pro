;-------------------------------------------------------------
;+
; NAME:
;       VER
; PURPOSE:
;       Plot a vertical line on a graph at specified x value.
; CATEGORY:
; CALLING SEQUENCE:
;       ver, x
; INPUTS:
;       x = X value of vertical line. Scalar or array.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE means work in device coordinates.
;         /NORMALIZED means work in normalized coordinates.
;           Default is data coordinates.
;         YRANGE=yran Optional Y range to use (def=all).
;           Give yran=[ymin,ymax] in specified coordinate system.
;         SHRINK=f  Fraction to reduce vertical range (def=0).
;           Useful to keep a grid from covering tick marks.
;           Only for data coordinates and an array of single lines.
;         LINESTYLE=s.    Linestyle (def=!p.linestyle).
;         COLOR=c.        Line Color (def=!p.color).
;         THICKNESS=thk   Line thickness (def=!p.thick).
;         FILL=clr        Optional color to fill between line pairs.
;           Fills between lines 0 and 1, 2 and 3, and so on.
;         POINTER=pt      Draw arrowhead pointers at top and bottom
;           instead of lines.  Arrowhead dimensions may be given as
;           fraction of screen or plot window size, the value of
;           pt is height, or [height, width].  For /pointer the
;           default used is [.03,.03].
;         /BOTTOM  used with POINTER to plot bottom pointers only.
;         /TOP  used with POINTER to plot top pointers only.
;         /OUT   Keep pointers outside axes (Data coord only).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: see hor.
; MODIFICATION HISTORY:
;       R. Sterner, 2 Aug, 1989.
;       R. Sterner, 21 May, 1992 --- fixed for log Y axes.
;       R. Sterner,  3 Nov, 1992 --- Added /device.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       R. Sterner 20 Jun, 1993 --- added /norm.
;       R. Sterner 1994 Feb 2 --- Add THICK.
;       R. Sterner, 1994 Jun 3 --- Added FILL.
;       R. Sterner, 1994 Jun 16 --- Added POINTER.
;       R. Sterner, 1997 Jul 11 --- Added /OUT.
;       R. Sterner, 2005 Aug 19 --- Added YRANGE=yran.
;       R. Sterner, 2005 Oct 13 --- Made loop indices long.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro ver, x, help=hlp, device=device, linestyle=ls, color=clr, $
	  normalized=norm, thickness=thk, fill=fill, pointer=pt, $
	  top=top, bottom=bot, out=out, shrink=shrink, yrange=yran
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot a vertical line on a graph at specified x value.'
	  print,' ver, x'
	  print,'   x = X value of vertical line. Scalar or array.    in'
	  print,' Keywords:'
	  print,'   /DEVICE means work in device coordinates.'
	  print,'   /NORMALIZED means work in normalized coordinates.'
	  print,'     Default is data coordinates.'
	  print,'   YRANGE=yran Optional Y range to use (def=all).'
	  print,'     Give yran=[ymin,ymax] in specified coordinate system.'
	  print,'   SHRINK=f  Fraction to reduce vertical range (def=0).'
	  print,'     Useful to keep a grid from covering tick marks.'
	  print,'     Only for data coordinates and an array of single lines.'
	  print,'   LINESTYLE=s.    Linestyle (def=!p.linestyle).'
	  print,'   COLOR=c.        Line Color (def=!p.color).'
	  print,'   THICKNESS=thk   Line thickness (def=!p.thick).'
	  print,'   FILL=clr        Optional color to fill between line pairs.'
	  print,'     Fills between lines 0 and 1, 2 and 3, and so on.'
	  print,'   POINTER=pt      Draw arrowhead pointers at top and bottom'
	  print,'     instead of lines.  Arrowhead dimensions may be given as'
	  print,'     fraction of screen or plot window size, the value of'
	  print,'     pt is height, or [height, width].  For /pointer the'
	  print,'     default used is [.03,.03].'
          print,'   /BOTTOM  used with POINTER to plot bottom pointers only.'
          print,'   /TOP  used with POINTER to plot top pointers only.'
	  print,'   /OUT   Keep pointers outside axes (Data coord only).'
	  print,' Note: see hor.'
	  return
	end
 
	xx = x
	n = n_elements(xx)
	if n_elements(ls) eq 0 then ls = !p.linestyle
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(thk) eq 0 then thk = !p.thick
	;------  Handle pointers  -----------
	if n_elements(pt) eq 0 then pt = 0
	pflag = 0
	if pt(0) gt 0 then begin
	  if pt(0) eq 1 then pt=.03
	  ht = pt(0)
	  wd = pt(n_elements(pt)-1)
	  if n_elements(pt) eq 1 then wd = ht/2.
	  pflag = 1
	endif
        bflag=0
        tflag=0
        if keyword_set(bot) then bflag=1
        if keyword_set(top) then tflag=1
        if (bflag+tflag) eq 0 then begin
          bflag=1
          tflag=1
        endif
 
	;--------  Device  ------------
	if keyword_set(device) then begin
	  yy = [0,!d.y_size-1]
	  if n_elements(yran) eq 2 then yy=yran
	  for i = 0L, n-1 do begin
	    ;--------  Filled line pairs  -----------
	    if n_elements(fill) ne 0 then begin
	      if (i mod 2) eq 0 then begin
	        x1 = xx(i) & x2 = xx((i+1)<(n-1))
		y1 = yy(0) & y2 = yy(1)
		polyfill, /dev, [x1,x2,x2,x1],[y1,y1,y2,y2],color=fill
	      endif
	    ;---------  Single lines  ---------------
	    endif else if pflag eq 0 then begin
 	      plots,/device,[0,0]+xx(i),yy,linestyle=ls,color=clr,thick=thk
	    ;---------  Pointers  -------------------
	    endif else begin
	      dx = round((!d.x_size-1)*wd/2.)
	      dx = [-dx,0,dx]+xx(i)
	      dy = round((!d.y_size-1)*ht)
	      y1 = [0,dy,0]
	      y2 = !d.y_size-1 - [0,dy,0]
	      if bflag then polyfill,/dev,dx,y1,col=clr
	      if tflag then polyfill,/dev,dx,y2,col=clr
	    endelse
	  endfor
	;---------  Normalized  ----------
	endif else if keyword_set(norm) then begin
	  yy = [0,1]
	  if n_elements(yran) eq 2 then yy=yran
	  for i = 0L, n-1 do begin
	    ;--------  Filled line pairs  -----------
	    if n_elements(fill) ne 0 then begin
	      if (i mod 2) eq 0 then begin
	        x1 = xx(i) & x2 = xx((i+1)<(n-1))
		y1 = yy(0) & y2 = yy(1)
		polyfill, /norm, [x1,x2,x2,x1],[y1,y1,y2,y2],color=fill
	      endif
	    ;---------  Single lines  ---------------
	    endif else if pflag eq 0 then begin
 	      plots,/norm,[0,0]+xx(i),yy,linestyle=ls,color=clr,thick=thk
	    ;---------  Pointers  -------------------
	    endif else begin
	      dx = wd/2.
	      dx = [-dx,0,dx]+xx(i)
	      dy = ht
	      y1 = [0,dy,0]
	      y2 = [1,1-dy,1]
	      if bflag then polyfill,/norm,dx,y1,col=clr
	      if tflag then polyfill,/norm,dx,y2,col=clr
	    endelse
	  endfor
	;----------  Data  -------------
	endif else begin
	  if n_elements(shrink) eq 0 then shrink=0.
	  yy = [!y.range, !y.crange]
	  if n_elements(yran) eq 2 then yy=yran
	  yr = exrange(yy,-shrink)
	  for i = 0L, n-1 do begin
	    ;--------  Linear Y axis  ----------
	    if !y.type eq 0 then begin
	      ;--------  Filled line pairs  -----------
	      if n_elements(fill) ne 0 then begin
	        if (i mod 2) eq 0 then begin
	          x1 = xx(i) & x2 = xx((i+1)<(n-1))
	  	  y1 = min(yy)  &  y2 = max(yy)
  		  polyfill, [x1,x2,x2,x1],[y1,y1,y2,y2],color=fill,noclip=0
	        endif
	      ;---------  Single lines  ---------------
	      endif else if pflag eq 0 then begin
 	        oplot,[1.,1.]*xx(i),[min(yy),max(yy)]>yr(0)<yr(1), $
	          linestyle=ls, color=clr, thick=thk
	      ;---------  Pointers  -------------------
	      endif else begin
	        dx = (!x.crange(1)-!x.crange(0))*wd/2.
		if !x.type eq 0 then dx=[-dx,0,dx]+xx(i) else $
		  dx=10^([-dx,0,dx]+alog10(xx(i)))
	        dy = (!y.crange(1)-!y.crange(0))*ht
		y1 = [0,dy,0]+!y.crange(0)
		y2 = [0,-dy,0]+!y.crange(1)
		if keyword_set(out) then begin
		  y1 = y1-dy
		  y2 = y2+dy
		endif
	        if bflag then polyfill,dx,y1,col=clr
	        if tflag then polyfill,dx,y2,col=clr
	      endelse
	    ;--------  Log Y axis  ----------
	    endif else begin
	      ;--------  Filled line pairs  -----------
	      if n_elements(fill) ne 0 then begin
	        if (i mod 2) eq 0 then begin
	          x1 = xx(i) & x2 = xx((i+1)<(n-1))
	  	  y1 = min(yy)  &  y2 = max(yy)
  		  polyfill, [x1,x2,x2,x1],10^[y1,y1,y2,y2],color=fill,noclip=0
	        endif
	      ;---------  Single lines  ---------------
	      endif else if pflag eq 0 then begin
 	        oplot,[1.,1.]*xx(i),10^[min(yy),max(yy)],linestyle=ls,$
		  color=clr, thick=thk
	      ;---------  Pointers  -------------------
	      endif else begin
	        dx = (!x.crange(1)-!x.crange(0))*wd/2.
		if !x.type eq 0 then dx=[-dx,0,dx]+xx(i) else $
		  dx=10^([-dx,0,dx]+alog10(xx(i)))
	        dy = (!y.crange(1)-!y.crange(0))*ht
		y1 = 10^([0,dy,0]+!y.crange(0))
		y2 = 10^([0,-dy,0]+!y.crange(1))
		if keyword_set(out) then begin
		  y1 = 10^([0,dy,0]-dy+!y.crange(0))
		  y2 = 10^([0,-dy,0]+dy+!y.crange(1))
		endif
	        if bflag then polyfill,dx,y1,col=clr
	        if tflag then polyfill,dx,y2,col=clr
	      endelse
	    endelse  ; !y.type.
	  endfor
	endelse
 
	return
	end
