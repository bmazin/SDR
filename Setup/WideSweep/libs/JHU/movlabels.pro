;-------------------------------------------------------------
;+
; NAME:
;       MOVLABELS
; PURPOSE:
;       Interactively position labels and list xyouts statement.
; CATEGORY:
; CALLING SEQUENCE:
;       movlabels, x, y, lab
; INPUTS:
;       x, y = Array of initial label origin points.   in
;       lab = Array of labels to position.             in
; KEYWORD PARAMETERS:
;       Keywords:
;         INFLAG=iflg Initial label flags: 0=off, 1=on (def=all off).
;         X_ORIG=x0, Y_ORIG=y0 Label origin points (def=x,y).
;           This is where the origin point returns after label
;           is dropped.  Default is entry label position.
;         /DATA use data coordinates (def).
;         /DEVICE use device coordinates.
;         /NORMAL use normalized coordinates.
;         RADIUS=r  Click radius (pixels) to pick up a label (def=5).
;         CHARSIZE=csz  Array of character sizes.
;         FONT=fnt      Array of fonts.
;         LX=x2, LY=y2  Output label positions.
;         FLAG=flg      Label on/off flag (0=off, 1=on).
; OUTPUTS:
; COMMON BLOCKS:
;       movlabels_com
; NOTES:
;       Notes: click mouse button for options (right button exits).
;         May change text size and angle.
;         May list xyouts call to plot text in current position.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Apr 12
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro movlabels, x0, y0, lab, inflag=flag0, $
	  x_orig=x_orig, y_orig=y_orig, $
	  data=data,device=dev,normal=norm, $
	  radius=radius, charsize=csz0, font=fnt0,  $
	  lx=lx, ly=ly, flag=flag, help=hlp
 
	common movlabels_com, mx, my
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Interactively position labels and list xyouts statement.'
	  print,' movlabels, x, y, lab'
	  print,'   x, y = Array of initial label origin points.   in'
	  print,'   lab = Array of labels to position.             in'
	  print,' Keywords:'
	  print,'   INFLAG=iflg Initial label flags: 0=off, 1=on (def=all off).'
	  print,'   X_ORIG=x0, Y_ORIG=y0 Label origin points (def=x,y).'
	  print,'     This is where the origin point returns after label'
	  print,'     is dropped.  Default is entry label position.'
	  print,'   /DATA use data coordinates (def).'
	  print,'   /DEVICE use device coordinates.'
 	  print,'   /NORMAL use normalized coordinates.'
	  print,'   RADIUS=r  Click radius (pixels) to pick up a label (def=5).'
	  print,'   CHARSIZE=csz  Array of character sizes.'
	  print,'   FONT=fnt      Array of fonts.'
	  print,'   LX=x2, LY=y2  Output label positions.'
	  print,'   FLAG=flg      Label on/off flag (0=off, 1=on).'
	  print,' Notes: click mouse button for options (right button exits).'
	  print,'   May change text size and angle.'
	  print,'   May list xyouts call to plot text in current position.'
	  return
	endif
 
	device, get_graph=svgrf	; Entry Graphics mode.
	device, set_graph=6	; Graphics XOR mode.
 
	;------  Set initial values  ---------
	if n_elements(data) eq 0 then data=0
	if n_elements(dev) eq 0 then dev=0
	if n_elements(norm) eq 0 then norm=0
	if (data+dev+norm) eq 0 then data=1
	if n_elements(mx) eq 0 then mx = 0
	if n_elements(my) eq 0 then my = 0
	if n_elements(radius) eq 0 then radius = 5
	r2 = radius^2
	n = n_elements(lab)
	if n_elements(csz0) eq 0 then csz0 = 1.
	csz = fltarr(n)
	if n_elements(csz0) eq 1 then csz(0:*)=csz0 else csz=csz0
	if n_elements(fnt0) eq 0 then fnt0 = '!3'
	fnt = strarr(n)
	if n_elements(fnt0) eq 1 then fnt(0:*)=fnt0 else fnt=fnt0
	if n_elements(flag0) eq 0 then flag0 = intarr(n)
 
	;--------  Check for data coordinates  --------
	if keyword_set(data) then begin
	  if total(abs(!x.crange)) eq 0 then begin
	    print,' Error in movlabels: Data coordinates not established yet.'
	    return
	  endif
	endif
 
	xlst = -1000
	ylst = -1000
	slst = 1.
 
	tvcrs, mx, my		; Initial cursor position.
 
	;------  Convert label origin points to device  -------
	tmp = convert_coord(x0,y0,data=data,dev=dev,norm=norm,/to_dev)
	ix0 = fix(tmp(0,*))	; Entry device coord of label positions.
	iy0 = fix(tmp(1,*))
	ix = ix0		; Working dev coord of label positions.
	iy = iy0
 
	;------  Label origin points  --------------
	if n_elements(x_orig) eq 0 then x_orig = x0
	if n_elements(y_orig) eq 0 then y_orig = y0
	tmp = convert_coord(x_orig,y_orig,data=data,dev=dev,norm=norm,/to_dev)
	ix_o = fix(tmp(0,*))	; Device coord of label origins.
	iy_o = fix(tmp(1,*))
 
	;-------  Put labels in initial state  ----------
	for i=0, n-1 do begin
	   if flag0(i) ne 0 then xyouts,ix(i),iy(i),/dev,$
	     fnt(i)+lab(i),chars=csz(i)
	endfor
 
	flag = flag0
 
 
	;===========  Main loop  ===================
	;--------  Pick up a label ---------------
loop:	dmn = 2*r2
	while (dmn gt r2) do begin
	  cursor, x, y, /device
	  if !err eq 4 then goto, done
	  d = (x-ix)^2+(y-iy)^2
	  ii = (where(d eq min(d)))(0)
	  dmn = d(ii)
	endwhile
	x = ix(ii)		; Closest point (is inside radius).
	y = iy(ii)
	txt = lab(ii)
	if flag(ii) eq 1 then $		; Erase active label first.
	   xyouts, x, y, /dev, fnt(ii)+txt, chars=csz(ii)
	if !mouse.button eq 2 then begin	; Drop a label.
	  flag(ii)=0		; Label inactive.
	  ix(ii) = ix_o(ii)	; Move label origin point back
	  iy(ii) = iy_o(ii)	;   to it's base position.
	  wait,.1
	  goto, loop
	endif
	wait,.1
 
	;--------  Move mode  ---------------
	while !mouse.button eq 1 do begin
	  cursor, x, y, /dev,/change
	  xyouts, xlst,ylst,/dev,fnt(ii)+txt, chars=csz(ii)
	  xyouts, x, y, /dev, fnt(ii)+txt, chars=csz(ii)
	  xlst=x
	  ylst=y
	endwhile
	ix(ii) = x	; Update label origin point to label position.
	iy(ii) = y
	flag(ii) = 1	; Label is now active.
	xlst = -1000
	ylst = -1000
 
	goto, loop
	;=========  End of main loop  ================
 
done:
	mx = !mouse.x
	my = !mouse.y
	device, set_graph=svgrf	; Back to entry graphics mode.
 
	;-------  Convert ix,iy to working coordinate system  -----
	tmp = convert_coord(ix,iy,to_data=data,to_dev=dev,to_norm=norm,/dev) 
	lx = reform(tmp(0,*))
	ly = reform(tmp(1,*))
 
	return
	end
