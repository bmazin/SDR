;-------------------------------------------------------------
;+
; NAME:
;       RADII
; PURPOSE:
;       Plot specified radii on the current plot device.
; CATEGORY:
; CALLING SEQUENCE:
;       radii, r1, r2, a, [x0, y0]
; INPUTS:
;       r1 = start radius of radius to draw (data units).   in
;       r2 = end radius of radius to draw (data units).     in
;       a = Angle of arc (deg CCW from X axis).             in
;       [x0, y0] = optional arc center (def=0,0).           in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE means use device coordinates .
;         /DATA means use data coordinates (default).
;         /NORM means use normalized coordinates.
;         /CLIP means clip radii to last plot window (if any).
;         COLOR=c  plot color (scalar or array).
;         LINESTYLE=l  linestyle (scalar or array).
;         THICKNESS=t  line thickness (scalar or array).
;         XOUT=x, YOUT=y, PEN=p returned x,y, and pencode
;           of plotted radii.  Can replot using plotp,x,y,p
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: all parameters may be scalars or arrays.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 15 Sep, 1989.
;       Johns Hopkins University Applied Physics Laboratory.
;       R. Sterner, 17 Jun, 1992 --- added coordinate systems, cleaned up.
;       R. Sterner, 1998 May 12 --- Added /CLIP.
;       R. Sterner, 2005 Feb 15 --- Added XOUT, YOUT, PEN keywords.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro radii, r1, r2, a, xx, yy, help=hlp,$
	  color=clr, linestyle=lstyl, thickness=thk, $
          device=device, data=data, norm=norm, clip=clip, $
	  xout=xout, yout=yout, pen=pen
 
 
 	np = n_params(0)
	if (np lt 3) or keyword_set(hlp) then begin
	  print,' Plot specified radii on the current plot device.'
	  print,' radii, r1, r2, a, [x0, y0]'
	  print,'   r1 = start radius of radius to draw (data units).   in'
	  print,'   r2 = end radius of radius to draw (data units).     in'
	  print,'   a = Angle of arc (deg CCW from X axis).             in'
	  print,'   [x0, y0] = optional arc center (def=0,0).           in'
	  print,' Keywords:'
          print,'   /DEVICE means use device coordinates .'
          print,'   /DATA means use data coordinates (default).'
          print,'   /NORM means use normalized coordinates.'
	  print,'   /CLIP means clip radii to last plot window (if any).'
	  print,'   COLOR=c  plot color (scalar or array).'
	  print,'   LINESTYLE=l  linestyle (scalar or array).'
	  print,'   THICKNESS=t  line thickness (scalar or array).'
	  print,'   XOUT=x, YOUT=y, PEN=p returned x,y, and pencode'
	  print,'     of plotted radii.  Can replot using plotp,x,y,p'
	  print,' Note: all parameters may be scalars or arrays.'
	  return
	endif
 
        ;------  Determine coordinate system  -----
        if n_elements(device) eq 0 then device = 0    ; Define flags.
        if n_elements(data)   eq 0 then data   = 0
        if n_elements(norm)   eq 0 then norm   = 0
        if device+data+norm eq 0 then data = 1        ; Default to data.
 
        if keyword_set(clip) then noclip=0	; Clip to plot window.
 
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(lstyl) eq 0 then lstyl = !p.linestyle
	if n_elements(thk) eq 0 then thk = !p.thick
 
	if np lt 4 then xx = 0.
	if np lt 5 then yy = 0.
 
	nr1 = n_elements(r1)-1		; Array sizes.
	nr2 = n_elements(r2)-1
	na  = n_elements(a)-1
	nxx = n_elements(xx)-1
	nyy = n_elements(yy)-1
        nclr = n_elements(clr)-1
        nlstyl = n_elements(lstyl)-1
        nthk = n_elements(thk)-1
	n = nr1>nr2>na>nxx>nyy		; Overall max.
 
	if arg_present(xout) then begin
	  xout = [0.]			; Returned arrays.
	  yout = [0.]
	  pen = [0]
	endif
 
	for i = 0, n do begin   	; loop thru arcs.
	  r1i  = r1(i<nr1)		; Get R1, R2, A.
	  r2i  = r2(i<nr2)
	  ai = a(i<na)
	  xxi = xx(i<nxx)
	  yyi = yy(i<nyy)
          clri = clr(i<nclr)
          lstyli = lstyl(i<nlstyl)
          thki = thk(i<nthk)
	  polrec, [r1i, r2i], [ai, ai]/!radeg, x, y
	  xp = x + xxi
	  yp = y + yyi
;	  plots, x + xxi, y + yyi, color=clri, linestyle=lstyli, $
	  plots, xp, yp, color=clri, linestyle=lstyli, $
            thick=thki, data=data, device=device, norm=norm, noclip=noclip
	  if arg_present(xout) then begin
	    xout = [xout,xp] 
	    yout = [yout,yp] 
	    p = fix(xp*0) + 1
	    p(0) = 0
	    pen = [pen,p]
	  endif
	endfor
 
	if arg_present(xout) then begin
	  xout = xout(1:*)
	  yout = yout(1:*)
	  pen = pen(1:*)
	endif
 
	return
 
	end
