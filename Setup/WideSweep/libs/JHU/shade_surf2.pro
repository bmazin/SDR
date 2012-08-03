;-------------------------------------------------------------
;+
; NAME:
;       SHADE_SURF2
; PURPOSE:
;       Allow image overlay with surface shading.
; CATEGORY:
; CALLING SEQUENCE:
;       shade_surf2, z, [x,y]
; INPUTS:
;       z = Surface array.                in
;       x,y = optional x and y arrays.    in
;         (like shade_surf).
; KEYWORD PARAMETERS:
;       Keywords:
;         SHADES=img  Byte scaled image to map onto surface.
;           Same size as z.  Default is byte scaled z.
;         GAMMA=g  Brightness gamma exponent (def=0.3).
;           Let s be the normal surface shading which ranges
;           from 0 to 1.  s^g is the shading actually used.
;           GAMMA = .3 seems to work well. Higher for more contrast.
;         Other SHADE_SURF keywords are allowed.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Apr 27
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro shade_surf2, z, x, y, gamma=gam, shades=shades, $
	  help=hlp, _extra=extra
 
	if (n_params(0) lt 0) or keyword_set(hlp) then begin
 	  print,' Allow image overlay with surface shading.'
	  print,' shade_surf2, z, [x,y]'
	  print,'   z = Surface array.                in'
	  print,'   x,y = optional x and y arrays.    in'
	  print,'     (like shade_surf).'
	  print,' Keywords:'
	  print,'   SHADES=img  Byte scaled image to map onto surface.'
	  print,'     Same size as z.  Default is byte scaled z.'
	  print,'   GAMMA=g  Brightness gamma exponent (def=0.3).'
	  print,'     Let s be the normal surface shading which ranges'
	  print,'     from 0 to 1.  s^g is the shading actually used.'
	  print,'     GAMMA = .3 seems to work well. Higher for more contrast.'
	  print,'   Other SHADE_SURF keywords are allowed.'
	  return
	endif
 
;### z: large arrays 
	sz = size(z)
	nx = sz(1)
	ny = sz(2)
 
	if n_elements(x) eq 0 then x = findgen(nx)
	if n_elements(y) eq 0 then y = findgen(ny)
;### shades:
	if n_elements(shades) eq 0 then shades = bytscl(z,top=topc())
	if n_elements(gam) eq 0 then gam = .3
 
	;------  Get brightness  -------------
	shade_surf, z, x, y, xstyle=4, ystyle=4,zstyle=4, _extra=extra
;### s:
	s = tvrd()
	s = ls(s,1,1)
	s = float(s)/max(s)
 
	;------  Get colored surface  ----------
	shade_surf, z,x,y,shades=shades,xstyle=4,ystyle=4,zstyle=4,_extra=extra
;### c:  Could now drop shades.
	shades = 0
	c = tvrd()
 
	;------  Get color table  -------------
	tvlct, rr, gg, bb, /get
	i = !p.color	; Axes color.
	rax = rr(i)
	gax = gg(i)
	bax = bb(i)
 
	;-------  Split image into R,G,B components  ----------
;###  r,g,b:
	r = rr(c)
	g = gg(c)
	b = bb(c)
;###  Could now drops c:
	c = 0
 
	;------  Apply gamma  ----------
	r = r*(s^gam)
	g = g*(s^gam)
	b = b*(s^gam)
 
	;------  Recombine into color image  ----------
;### cc:
	cc = color_quan(r,g,b,rr,gg,bb)
;### could now drop r,g,b:
	r = 0
	g = 0
	b = 0
 
	;-------  Display  -----------------
	tvlct,rr,gg,bb
	tv,cc
 
	;--------  Axes  -----------------
	d = (long(rr)-rax)^2 + (long(gg)-gax)^2 + (long(bb)-bax)^2
	w = where(d eq min(d))
	shade_surf, z, x, y,/nodata, /noerase, _extra=extra, color=w(0)
 
	return
	end
