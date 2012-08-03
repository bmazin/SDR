;-------------------------------------------------------------
;+
; NAME:
;       DIST_SCALE
; PURPOSE:
;       Display a distance scale on an image.
; CATEGORY:
; CALLING SEQUENCE:
;       dist_scale, x0, y0
; INPUTS:
;       x0, y0 = pixel coordinates of the center of scale.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         SCALE=sc    Number of units per pixels (like 12.5 m).
;         LENGTH=len  length of scale in units given in SCALE.
;         HEIGHT=ht   height of scale in units given in SCALE.
;         TITLE=txt   Scale title text (like 10 km).
;         SIZE=sz     Text size (def=1).
;         COLOR=clr   Color of scale (def=!p.color).
;         BACKGROUND=bclr   Background color (def=!p.background).
;         THICK=thk   Scale thickness.
; OUTPUTS:
; COMMON BLOCKS:
;       dist_scale_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 26 Jul, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro dist_scale, x0, y0, length=len, height=ht, scale=sc, $
	  title=ttl, size=sz, help=hlp, color=clr, background=bclr, $
	  thick=thk
 
	common dist_scale_com, len0, ht0, sc0, ttl0, sz0, thk0
 
	if keyword_set(hlp) then begin
	  print,' Display a distance scale on an image.'
	  print,' dist_scale, x0, y0'
	  print,'   x0, y0 = pixel coordinates of the center of scale.  in'
	  print,' Keywords:'
	  print,'   SCALE=sc    Number of units per pixels (like 12.5 m).'
	  print,'   LENGTH=len  length of scale in units given in SCALE.'
	  print,'   HEIGHT=ht   height of scale in units given in SCALE.'
	  print,'   TITLE=txt   Scale title text (like 10 km).'
	  print,'   SIZE=sz     Text size (def=1).'
	  print,'   COLOR=clr   Color of scale (def=!p.color).'
	  print,'   BACKGROUND=bclr   Background color (def=!p.background).'
	  print,'   THICK=thk   Scale thickness.'
	  return
	endif
 
	;--------  Update common  -----------
	if n_elements(len) ne 0 then len0 = len
	if n_elements(ht) ne 0 then ht0 = ht
	if n_elements(sc) ne 0 then sc0 = sc
	if n_elements(ttl) ne 0 then ttl0 = ttl
	if n_elements(ttl0) eq 0 then ttl0 = ''
	if n_elements(sz) ne 0 then sz0 = sz
	if n_elements(sz0) eq 0 then sz0 = 1
	if n_elements(thk) ne 0 then thk0 = thk
 
	if n_params(0) lt 2 then return
 
	if n_elements(sc0) eq 0 then begin
	  print,' Error in dist_scale: Keyword SCALE not specified.'
	  return
	endif
 
	if n_elements(len0) eq 0 then begin
	  print,' Error in dist_scale: Keyword LENGTH not specified.'
	  return
	endif
 
	if n_elements(ht0) eq 0 then begin
	  ht0 = 10.*sc0		; Def = 20 pixels.
;	  return
	endif
 
	;----------  Plot scale  -----------
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(bclr) eq 0 then bclr = !p.background
	if n_elements(thk0) eq 0 then thk0 = 1
	dx2 = len0/(sc0*2.)
	dy2 = ht0/(sc0*2.)
 
	for iy = -thk0,thk0 do begin
	  y = y0 + iy
	  for ix = -thk0, thk0 do begin
	    x = x0+ix
	    plots,/dev,[-dx2,dx2]+x,[0,0]+y,color=bclr
	    plots,/dev,[-dx2,-dx2]+x,[-dy2,dy2]+y,color=bclr
	    plots,/dev,[dx2,dx2]+x,[-dy2,dy2]+y,color=bclr
	    xyouts, x, y+dy2, /dev, align=.5, ttl0, charsize=sz0, color=bclr
	  endfor
	endfor
	for iy = -thk0/2.,thk0/2. do begin
	  y = y0 + fix(iy)
	  for ix = -thk0/2., thk0/2. do begin
	    x = x0 + fix(ix)
	    plots,/dev,[-dx2,dx2]+x,[0,0]+y,color=clr
	    plots,/dev,[-dx2,-dx2]+x,[-dy2,dy2]+y,color=clr
	    plots,/dev,[dx2,dx2]+x,[-dy2,dy2]+y,color=clr
	    xyouts, x, y+dy2, /dev, align=.5, ttl0, charsize=sz0, color=clr
	  endfor
	endfor
 
 
	return
	end
