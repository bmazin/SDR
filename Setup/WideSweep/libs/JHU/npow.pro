;-------------------------------------------------------------
;+
; NAME:
;       NPOW
; PURPOSE:
;       Plot a diagram showing a number to a power.
; CATEGORY:
; CALLING SEQUENCE:
;       npow, n, pow
; INPUTS:
;       n = Number to raise to a power.  in
;       pow = power.                     in
; KEYWORD PARAMETERS:
;       Keywords:
;         R=r Size of diagram (def=100).
;         FRAC=frac Radius of circles as fraction of radius
;           that makes circles tangent (def=1).
;         /NOFRAME do not plot radial lines.
;         /NOCIRC do not plot circles.
;         CCOL=ccol Color of circles.
;         /FILL fill circles.
;         OCOL=ocol Circle outline color.
;         FCOL=fcol Color of radial lines.
;         CEN=[ix,iy] Center of pattern (dev coord).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: As an example try:
;         erase
;         npow,5,2
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Feb 10
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro npow_plot, t, n, pow, r=r, frac=frac, noframe=nofr, nocirc=noc, $
	  ccol=ccol, ocol=ocol, fill=fill, fcol=fcol
 
	da = 360./n			; Angular step.
 
	t->get, curr_x=xc, curr_y=yc	; Grab current position.
 
	for i=0, n-1 do begin		; Loop through angles.
	  t->movetoxy,xc,yc		; Jump to start point.
	  t->set,ang=90			; Starting direction (up).
	  if keyword_set(nofr) then begin
	    t->move,r,i*da,/noclip		; Move to end of i'th arm.
	  endif else begin
	    t->draw,r,i*da,col=fcol,/noclip	; Draw to end of i'th arm.
	  endelse
	  if pow eq 1 then begin	; Last level.
	    if not keyword_set(noc) then begin
	      rc = r*sin((0.5*da)/!radeg) ; Radius of tangent circles.
	      rc = frac*rc		; Adjust radius.
	      t->circle, rc,col=ccol, $	; Draw circle.
	        fill=fill, ocol=ocol,/outline,/noclip
	    endif
	  endif else begin
	    npow_plot, t, n, pow-1, r=r/3, $	; Recurse inward.
	      frac=frac, noframe=nofr, nocirc=noc, $
		ccol=ccol, ocol=ocol, fill=fill, fcol=fcol
	  endelse
	endfor
 
	end
 
	;--------------------------------------------------------
	;  npow.pro = Main routine.
	;
	;  n = Number.
	;  pow = Power.  (for n^pow)
	;  R=r Size of pattern.
	;  FRAC=frac Radius of circles as fraction of radius
	;    that makes circles tangent.
	;  /NOFRAME do not plot radial lines.
	;  /NOCIRC do not plot circles.
	;  CCOL=ccol Color of circles.
	;  /FILL fill circles.
	;  OCOL=ocol Circle outline color.
	;  FCOL=fcol Color of radial lines.
	;  CEN=[ix,iy] Center of pattern (dev coord).
	;--------------------------------------------------------
 
	pro npow, n, pow, r=r, frac=frac, noframe=nofr, nocirc=noc, $
	  ccol=ccol, ocol=ocol, fill=fill, fcol=fcol, center=cen, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Plot a diagram showing a number to a power.'
	  print,' npow, n, pow'
	  print,'   n = Number to raise to a power.  in'
	  print,'   pow = power.                     in'
	  print,' Keywords:'
	  print,'   R=r Size of diagram (def=100).'
	  print,'   FRAC=frac Radius of circles as fraction of radius'
	  print,'     that makes circles tangent (def=1).'
	  print,'   /NOFRAME do not plot radial lines.'
	  print,'   /NOCIRC do not plot circles.'
	  print,'   CCOL=ccol Color of circles.'
	  print,'   /FILL fill circles.'
	  print,'   OCOL=ocol Circle outline color.'
	  print,'   FCOL=fcol Color of radial lines.'
	  print,'   CEN=[ix,iy] Center of pattern (dev coord).'
	  print,' Notes: As an example try:'
	  print,'   erase'
	  print,'   npow,5,2'
	  return
	endif
 
	if n_params(0) lt 2 then begin
	  print,' npow_demo, n, pow, r=r'
	  return
	endif
 
	if n_elements(r) eq 0 then r=100
	if n_elements(frac) eq 0 then frac=1.
	if n_elements(ccol) eq 0 then ccol=!p.color
	if n_elements(ocol) eq 0 then ocol=ccol
	if n_elements(fcol) eq 0 then fcol=!p.color
 
	if n_elements(cen) gt 0 then begin
	  t = obj_new('rturtle',ref=cen)
	endif else begin
	  t = obj_new('rturtle',ref=[.5,.5],/norm)
	endelse
 
	npow_plot, t, n, pow, r=r, frac=frac, noframe=nofr, nocirc=noc, $
	  ccol=ccol, ocol=ocol, fill=fill, fcol=fcol
	obj_destroy, t
 
	end
