;-------------------------------------------------------------
;+
; NAME:
;       COLOR_WHEEL
; PURPOSE:
;       Pick a color using a color wheel.
; CATEGORY:
; CALLING SEQUENCE:
;       color_wheel, clr
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /VARYWHEEL means vary wheel brightness using bar.
;         XPOS=xpos, YPOS=ypos Window position.
;         SIZE=sz  Size of color wheel (def=200).
; OUTPUTS:
;       clr = Returned color.   out
;         -1 means ignore new color.
; COMMON BLOCKS:
; NOTES:
;       Notes: color is selected by clicking on a color
;         wheel and brightness bar.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Aug 22
;       R. Sterner, 2001 Feb 15 --- Added HSV and RGB listing.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro color_wheel, clr, size=sz, varywheel=vary, help=hlp, $
	   xpos=xpos, ypos=ypos
 
	if keyword_set(hlp) then begin
	  print,' Pick a color using a color wheel.'
	  print,' color_wheel, clr'
	  print,'   clr = Returned color.   out'
	  print,'     -1 means ignore new color.'
	  print,' Keywords:'
	  print,'   /VARYWHEEL means vary wheel brightness using bar.'
	  print,'   XPOS=xpos, YPOS=ypos Window position.'
	  print,'   SIZE=sz  Size of color wheel (def=200).'
	  print,' Notes: color is selected by clicking on a color'
	  print,'   wheel and brightness bar.
	  return
	endif
 
	if n_elements(sz) eq 0 then sz=200
	if n_elements(xpos) eq 0 then xpos=0
	if n_elements(ypos) eq 0 then ypos=0
	xmar = fix(0.25*sz)
;	ymar = fix(0.25*sz)
	ymar = fix(0.35*sz)
	csz = 1.1*sz/200.
	lst_hsv = ''
	lst_rgb = ''
 
	;-------  Set up color wheel  ----------
	makenxy, -1.05, 1.05, sz, -1.05, 1.05, sz, xx, yy
	recpol,xx,yy,wss,whh,/deg
	wvv = wss*0+1.
	whl = where(wss le 1)
	w = where(wss gt 1)
	wvv(w) = 0.7
	wss(w) = 0.0
	color_convert,whh,wss,wvv,wrr,wgg,wbb,/hsv_rgb
 
	;-------  Set up brightness bar  -----------
	makenxy, -.1,1.1,xmar,-0.05,1.05,sz,bxx,bvv
	bhh = 0*bvv
	bss = 0*bvv
	wbar = where((bvv gt 0) and (bvv lt 1) and $
	     (bxx gt 0) and (bxx lt 1))
	wb = where((bvv lt 0) or (bvv gt 1) or $
	     (bxx lt 0) or (bxx gt 1))
	bvv(wb) = 0.9
	bss(wb) = 0.0
	color_convert,bhh,bss,bvv,brr,bgg,bbb,/hsv_rgb
 
	;-------  Display  -----------------
	xsz = sz+xmar
	ysz = sz+ymar
	window,/free,xsize=xsz,ysize=ysz,title='Select Color', $
	  xpos=xpos, ypos=ypos
	win = !d.window
	erase, -1
	tx = sz/2
	ty = sz+ymar-csz*10
	dt = csz*12
	xyouts,tx,ty,/dev,align=0.5,col=0,chars=csz,$
	  'Mouse buttons:'
	xyouts,tx,ty-dt,/dev,align=0.5,col=0,chars=csz,$
	  'Left: Color Wheel/Brightness Bar'
	xyouts,tx,ty-2*dt,/dev,align=0.5,col=0,chars=csz,$
	  'Other: Exit'
	tv,wrr,0,0,1
	tv,wgg,0,0,2
	tv,wbb,0,0,3
 
	tv,brr,sz,0,1
	tv,bgg,sz,0,2
	tv,bbb,sz,0,3
 
	;---------  Setup  ---------------------
	apat = fltarr(xmar,ymar)
	ix0 = sz/2		; Central point.
	iy0 = ix0
	rfact = 2*1.05/sz	; Radial factor.
	vfact = 1.1/sz		; V factor.
	tvcrs,sz/2,sz/2		; Put cursor at center.
	mode = 0		; Free mode.
	ixhs = ix0		; HS cursor.
	iyhs = iy0
	ixv = sz+xmar/2		; V cursor.
	iyv = iy0
	v = 1.0
 
	;---------  Cursor  --------------
loop:	cursor,/dev,ix,iy,/change
 
	iy = iy<sz
	tvcrs,ix,iy
 
	;------  V cursor  --------------
	if mode eq 1 then begin
	  ix = ix>sz
	  tvcrs,ix,iy
	  v = (iy*vfact-0.05)>0<1
	  ;-------  Color patch  ---------
	  act_vv = apat + v
	  color_convert,act_hh,act_ss,act_vv,rr,gg,bb,/hsv_rgb
	  tv,rr,sz,sz,1
	  tv,gg,sz,sz,2
	  tv,bb,sz,sz,3
	  ;------  List color values  ---------------
	  txt_hsv = 'H S V: '+string(act_hh(0),act_ss(0),act_vv(0), $
	    form='(F5.1,X,F5.3,X,F5.3)')
	  txt_rgb = +'R G B: '+$
	    string(rr(0),gg(0),bb(0),form='(3I4.3)')
	  xyouts,tx,ty-3*dt,/dev,align=0.5,col=-1,chars=csz,lst_hsv
	  xyouts,tx,ty-4*dt,/dev,align=0.5,col=-1,chars=csz,lst_rgb
	  xyouts,tx,ty-3*dt,/dev,align=0.5,col=0,chars=csz,txt_hsv
	  xyouts,tx,ty-4*dt,/dev,align=0.5,col=0,chars=csz,txt_rgb
	  lst_hsv = txt_hsv
	  lst_rgb = txt_rgb
	  ;--------  Color wheel  --------
	  if keyword_set(vary) then begin
	    wvv(whl) = v
	    color_convert,whh,wss,wvv,wrr,wgg,wbb,/hsv_rgb
	    tv,wrr,0,0,1
	    tv,wgg,0,0,2
	    tv,wbb,0,0,3
	  endif
	endif
 
	;-------  HS cursor  ------------
	if mode eq 0 then begin
	  ix = ix<sz
	  tvcrs,ix,iy
	  recpol,ix-ix0,iy-iy0,s,h,/deg
	  s = (s*rfact)<1.0
	  ;-------  Color patch  ------------
	  act_hh = apat + h
	  act_ss = apat + s
	  act_vv = apat + v
	  color_convert,act_hh,act_ss,act_vv,rr,gg,bb,/hsv_rgb
	  tv,rr,sz,sz,1
	  tv,gg,sz,sz,2
	  tv,bb,sz,sz,3
	  ;------  List color values  ---------------
	  txt_hsv = 'H S V: '+string(act_hh(0),act_ss(0),act_vv(0), $
	    form='(F5.1,X,F5.3,X,F5.3)')
	  txt_rgb = +'R G B: '+$
	    string(rr(0),gg(0),bb(0),form='(3I4.3)')
	  xyouts,tx,ty-3*dt,/dev,align=0.5,col=-1,chars=csz,lst_hsv
	  xyouts,tx,ty-4*dt,/dev,align=0.5,col=-1,chars=csz,lst_rgb
	  xyouts,tx,ty-3*dt,/dev,align=0.5,col=0,chars=csz,txt_hsv
	  xyouts,tx,ty-4*dt,/dev,align=0.5,col=0,chars=csz,txt_rgb
	  lst_hsv = txt_hsv
	  lst_rgb = txt_rgb
	  ;-------  V bar  -----------
	  bhh(wbar) = h
	  bss(wbar) = s
	  color_convert,bhh,bss,bvv,brr,bgg,bbb,/hsv_rgb
	  tv,brr,sz,0,1
	  tv,bgg,sz,0,2
	  tv,bbb,sz,0,3
	endif
 
	;---------  Mode switch  ------------------------
	if !mouse.button eq 1 then begin
	  if mode eq 0 then begin	; Was HS cursor.
	    ixhs = ix			; Remember HS cursor loc.
	    iyhs = iy
	    tvcrs,ixv,iyv		; Jump to V cursor loc.
	  endif else begin		; Was V cursor.
	    ixv = ix			; Remember V cursor loc.
	    iyv = iy
	    tvcrs,ixhs,iyhs		; Jump to HS cursor loc.
	  endelse
	  mode = 1-mode			; Switch cursor mode.
	  wait, 0.1			; Debounce.
	endif
 
	;----------  Exit  ------------------
	if !mouse.button gt 1 then goto, done
 
	goto, loop
 
	;-------  Done  --------------------
done:	wdelete, win
	opt = xoption(['Accept new color','Ignore new color'])
	if opt eq 1 then begin
	  clr = -1
	  return
	endif
	clr = tarclr(h,s,v,/hsv)
	return
 
	end
