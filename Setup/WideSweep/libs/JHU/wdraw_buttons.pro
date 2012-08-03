;-------------------------------------------------------------
;+
; NAME:
;       WDRAW_BUTTONS
; PURPOSE:
;       Make button images for draw widget buttons.
; CATEGORY:
; CALLING SEQUENCE:
;       wdraw_buttons, dx, dy, txt
; INPUTS:
;       dx = Button x size in pixels.   in
;       dy = Button y size in pixels.   in
;       txt = Label text.               in
;         May be a text array for a multiline label.
; KEYWORD PARAMETERS:
;       Keywords:
;         UP=up  returned image when button is up.
;         DN=dn  returned image when button is down.
;         BCOLOR=bclr Button color (def=gray).
;         CHARSIZE=csz  Character size (def=1).
;         BOLD=bld Bold value (def=2).
;         COLOR=clr 24-bit text color (def=white).
;         /GLOW glow when down, dark when up.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Feb 19
;       R. Sterner, 2006 Feb 20 --- Multiline labels.  Colored buttons.
;       R. Sterner, 2006 Feb 28 --- Made widget background darker.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro wdraw_buttons, dx, dy, txt, up=up,dn=dn, help=hlp, $
	  charsize=csz, bold=bld, color=clr, glow=glow, bcolor=bclr
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make button images for draw widget buttons.'
	  print,' wdraw_buttons, dx, dy, txt'
	  print,'   dx = Button x size in pixels.   in'
	  print,'   dy = Button y size in pixels.   in'
	  print,'   txt = Label text.               in'
	  print,'     May be a text array for a multiline label.'
	  print,' Keywords:'
	  print,'   UP=up  returned image when button is up.'
	  print,'   DN=dn  returned image when button is down.'
	  print,'   BCOLOR=bclr Button color (def=gray).'
	  print,'   CHARSIZE=csz  Character size (def=1).'
	  print,'   BOLD=bld Bold value (def=2).'
	  print,'   COLOR=clr 24-bit text color (def=white).'
	  print,'   /GLOW glow when down, dark when up.'
	  return
	endif
 
	;--------------------------------------------------------
	;  OS dependent values
	;--------------------------------------------------------
	if !version.os_family eq 'unix' then begin
	  tzero = 0.75
	endif
	if !version.os_family eq 'Windows' then begin
;	  tzero = 0.91
	  tzero = 0.82
	endif
 
	;--------------------------------------------------------
	;  Default values
	;--------------------------------------------------------
	if n_elements(csz) eq 0 then csz=1
	if n_elements(bld) eq 0 then bld=2
	if n_elements(clr) eq 0 then clr=!p.color
	
	;--------------------------------------------------------
	;  Create text position arrays
	;--------------------------------------------------------
	window,xs=dx,ys=dy,/pixmap,/free; Use pixmap to get exact size.
	textplot,/dev,dx/2,dy/2,txt[0],align=[.5,.5], $	; Find text size.
	  chars=csz, /noplot,ybox=yb
	n = n_elements(txt)				; # lines of text.
	t = findgen(n)
	off = midv(t) - t				; Y offset in lines.
	xtxt = intarr(n) + round(dx/2.)			; X positions.
	ytxt = round(dy/2. + 2.*exdiff(yb)*off)		; Y positions.
 
	;--------------------------------------------------------
	;  Deal with any button color
	;--------------------------------------------------------
	if n_elements(bclr) gt 0 then begin
	  erase,bclr			; Erase pixmap window to button color.
	  filt = tvrd(tr=1)		; Read back as color filter.
	endif
 
	;--------------------------------------------------------
	;  Create button base
	;--------------------------------------------------------
	bx = dx - 3			; Fill size.
	by = dy - 3
	a = fltarr(dx,dy)		; Button Array.
	a(1:bx,1:by) = 1.		; High part.
 
	;--------------------------------------------------------
	;  Deal with /GLOW
	;--------------------------------------------------------
	if keyword_set(glow) then begin
	  c2hsv, clr, h, s, v		; Decompose given color.
	  upclr = tarclr(/hsv,h,s,v*.25); Dark color for UP.
	endif else begin		; Just use given color.
	  upclr = clr
	endelse
 
	;--------------------------------------------------------
	;  Up button 
	;--------------------------------------------------------
	tv,255*topo(smooth(a,3),45,135,zero=tzero)	; Shade button.
	if n_elements(bclr) gt 0 then begin	; Color button before text.
	  up = tvrd(tr=1)			; Read back shaded button.
	  tv,tr=1,img_cfilter(up, filt)		; Color and load back.
	endif
	for i=0,n-1 do begin			; Add text.
	  textplot,/dev,xtxt(i),ytxt(i),txt(i),align=[.5,.5],chars=csz, $
	    bold=bld,/anti,col=upclr
	endfor
	up = tvrd(tr=1)				; Final button.
 
	;--------------------------------------------------------
	;  Down button 
	;--------------------------------------------------------
	tv,255*topo(smooth(-a,3),45,135,zero=tzero)	; Shade button.
	if n_elements(bclr) gt 0 then begin	; Color button before text.
	  dn = tvrd(tr=1)			; Read back shaded button.
	  tv,tr=1,img_cfilter(dn, filt)		; Color and load back.
	endif
	if keyword_set(glow) then begin		; Add text: dark halo.
	  for i=0,n-1 do begin
	    textplot,/dev,xtxt(i),ytxt(i),txt(i),align=[.5,.5],chars=csz, $
	      bold=bld+3,/anti,col=upclr
	  endfor
	endif
	for i=0,n-1 do begin			; Add text: glowing text.
	  textplot,/dev,xtxt(i),ytxt(i),txt(i),align=[.5,.5],chars=csz, $
	    bold=bld,/anti,col=clr
	endfor
	dn = tvrd(tr=1)				; Final button.
	wdelete					; Delete working window.
 
	end
