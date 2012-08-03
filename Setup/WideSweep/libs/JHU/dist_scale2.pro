;-------------------------------------------------------------
;+
; NAME:
;       DIST_SCALE2
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
;         THICK=thk   Text thickness.
;         BORDER=brd  Border thickness.
; OUTPUTS:
; COMMON BLOCKS:
;       dist_scale_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Mar 7
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro dist_scale2, x0, y0, length=len, height=ht, scale=sc, $
	  title=ttl, size=sz, help=hlp, color=clr, background=bclr, $
	  thick=thk, border=brd
 
	common dist_scale_com, len0, ht0, sc0, ttl0, sz0, thk0, brd0
 
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
	  print,'   THICK=thk   Text thickness.'
	  print,'   BORDER=brd  Border thickness.'
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
        if n_elements(brd) ne 0 then brd0 = brd
 
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
          ht0 = 10         ; Def = 10 pixels.
        endif
 
        ;----------  Plot scale  -----------
        if n_elements(clr) eq 0 then clr = !p.color
        if n_elements(bclr) eq 0 then bclr = !p.background
        if n_elements(thk0) eq 0 then thk0 = 1
        if n_elements(brd0) eq 0 then brd0 = 1
        dx2 = len0/(sc0*2.)
        dy2 = ht0/2.
	bx = [-dx2,dx2,dx2,-dx2,-dx2]	; Box.
	by = [-dy2,-dy2,dy2,dy2,-dy2]
 
	;----------  Ticks  ----------------
	naxes,0,len,5,tx1,tx2,nt,xinc,ndec
	tk = makex(0,len,xinc)
	if ndec eq 0 then tks=string(tk,form='(I0)')
	if ndec ne 0 then tks=strtrim(string(tk,form=$
	  '(F10.'+strtrim(ndec,2)+')'),2)
	tkv = round(tk/sc0-dx2)
 
	;----------  Charsize  -------------
	chy = 0.5*!d.y_ch_size*sz+dy2
	ctk = 1.5*!d.y_ch_size*sz
 
	;------  Do background  --------
	brdr = brd0+thk0-1
        for iy = -brdr,brdr do begin
          y = y0 + iy
          for ix = -brdr, brdr do begin
            x = x0+ix
            plots,/dev,bx+x,by+y,color=bclr
            xyouts, x, chy+y, /dev, align=.5, ttl0, charsize=sz0, color=bclr
	    for i=0,n_elements(tks)-1 do $
	      xyouts,x+tkv(i),y-ctk,/dev,align=.5,tks(i),charsize=sz0,color=bclr
          endfor
        endfor
 
	;------  Do foreground  --------
        for iy = -thk0/2.,thk0/2. do begin
          y = y0 + fix(iy)
          for ix = -thk0/2., thk0/2. do begin
            x = x0 + fix(ix)
            plots,/dev,bx+x,by+y,color=clr
            xyouts, x, y+chy, /dev, align=.5, ttl0, charsize=sz0, color=clr
	    for i=0,n_elements(tks)-1 do $
	      xyouts,x+tkv(i),y-ctk,/dev,align=.5,tks(i),charsize=sz0,color=clr
          endfor
        endfor
 
	;-----  Divisions  ----------
	dx2 = round(dx2)
	tkv = [tkv,dx2]
	for i=0,n_elements(tkv)-2 do begin
	  cc = bclr
	  if (i mod 2) eq 1 then cc=clr
	  x1=x0+tkv(i) & x2=(x0+tkv(i+1)+1)<(x0+dx2-1)
	  y1=y0-dy2 & y2=y0+dy2
	  if x2 gt x1 then tv,bytarr(x2-x1-1,y2-y1-1)+cc,x1+1,y1+1
	endfor
 
        return
        end
