;-------------------------------------------------------------
;+
; NAME:
;       XMETER
; PURPOSE:
;       Display a 0 to 100% meter on a text screen.
; CATEGORY:
; CALLING SEQUENCE:
;       txtmeter, fr
; INPUTS:
;       fr = fraction, 0 to 1.00 to display as %.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /INITIALIZE must be called to start meter.
;         /CLEAR will erase the specified meter.
;         TITLE=txt set meter title (def=no title). Only on /INIT.
; OUTPUTS:
; COMMON BLOCKS:
;       xmeter_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Feb 27
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xmeter, fr, initialize=init, title=tt, $
	  clear=clear, help=hlp
 
	common xmeter_com, top, win, last, br, dr
 
	if keyword_set(hlp) then begin
	  print,' Display a 0 to 100% meter on a text screen.'
	  print,' txtmeter, fr'
	  print,'   fr = fraction, 0 to 1.00 to display as %.  in'
	  print,' Keywords:'
	  print,'   /INITIALIZE must be called to start meter.'
	  print,'   /CLEAR will erase the specified meter.'
	  print,'   TITLE=txt set meter title (def=no title). Only on /INIT.'
	  return
	end
 
	;--------  Make sure needed values exist  ---------
	if n_elements(fr) eq 0 then fr = 0.	; Default fraction is 0.
	f = 4					; Pixels/percent.
	sx = 100*f				; Meter x size in pixels.
	sy = 20					; Meter y size in pixels.
	win0 = !d.window			; Entry window.
 
	;--------  Clear meter  ----------
	if keyword_set(clear) then begin
	  widget_control, top, /dest		; Destroy meter widget.
	  return
	endif
 
	;--------  Start meter  ----------
	if keyword_set(init) then begin		; Start a new meter.
	  if n_elements(tt) eq 0 then tt = ''	; Default title = no title.
	  top = widget_base(title=' ',/column)
	  id = widget_label(top,val=tt)
	  id = widget_draw(top,xsize=sx,ys=sy)
	  widget_control,top,/real
	  win = !d.window
	  tvlct,r,g,b,/get
	  lum = .3 * r + .59 * g + .11 * b
	  dr = (where(lum eq min(lum)))(0)
	  br = (where(lum eq max(lum)))(0)
	  erase,dr
	  last = (fr>0<1.)*100.			; Compute percent.
	endif
 
	;--------  Update meter  ------------
	pct = (fr>0<1.)*100.			; Compute percent.
	next = fix(.5+pct)			; Next meter endpoint.
	wset, win				; Meter window.
	;--------  Meter went up  --------
	if next gt last then begin		; If next > last:
	  polyfill,/dev,f*[last,next,next,last],[0,0,sy-1,sy-1],col=br
	endif
	;--------  Meter went down  --------
	if next lt last then begin		; If next < last:
	  polyfill,/dev,f*[next,last,last,next],[0,0,sy-1,sy-1],col=dr
	endif
	;--------  Update %  ----------
	last = next				; Remember next as last.
	if win0 ge 0 then wset, win0		; Back to entry window.
 
	return
	end
