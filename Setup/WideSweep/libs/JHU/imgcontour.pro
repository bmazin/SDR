;-------------------------------------------------------------
;+
; NAME:
;       IMGCONTOUR
; PURPOSE:
;       Plot an image with contours.
; CATEGORY:
; CALLING SEQUENCE:
;       imgcontour, z,[x,y]
; INPUTS:
;       z = Image.                       in
;       x, y = Optional x and y arrays.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         LEVELS=lv Array of contour values (def=10 levels).
;         OUTLEVELS=olv Returned levels array (useful for default).
;         CCOLOR=Contour color (def=0).
;         CTHICK=Contour thickness (def=2).
;         /SHADE Do shaded relief of data.
;         FACTOR=fct Z factor for shaded relief (def=1).
;           Increase fct for more contrast.
;         MINSHADE=mnsh Min output shading value (0 to 1, def=0).
;         /NOBAR means do not plot a color bar.
;         BARPOS=posb Color bar position (def=to the right of plot).
;           May be given in device or normalized coordinates.
;         OUTBARPOS=oposb Returned bar position (useful for default).
;           In same coordinates as given.  Default pos is device.
;         BARTITLE=ttb Color bar title (def=none).
;         OUTPOS=outpos Returned main plot position.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Plot keywords can be given to control the main plot.
; MODIFICATION HISTORY:
;       R. Sterner, A. Najmi, 2007 Jun 29
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro imgcontour, z,x,y, levels=lv, $
	    position=pos, charsize=csz, $
	    ccolor=cclr, cthick=cthk, shade=shade, $
	    factor=fct, minshade=mnsh, $
	    outlevels=outlv, _extra=extra, iso=iso, $
	    nobar=nobar, barpos=posb, bartitle=ttb, $
	    outbarpos=outposb, outpos=outpos, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot an image with contours.'
	  print,' imgcontour, z,[x,y]'
	  print,'   z = Image.                       in'
	  print,'   x, y = Optional x and y arrays.  in'
	  print,' Keywords:'
	  print,'   LEVELS=lv Array of contour values (def=10 levels).'
	  print,'   OUTLEVELS=olv Returned levels array (useful for default).'
	  print,'   CCOLOR=Contour color (def=0).'
	  print,'   CTHICK=Contour thickness (def=2).'
	  print,'   /SHADE Do shaded relief of data.'
	  print,'   FACTOR=fct Z factor for shaded relief (def=1).'
	  print,'     Increase fct for more contrast.'
	  print,'   MINSHADE=mnsh Min output shading value (0 to 1, def=0).'
	  print,'   /NOBAR means do not plot a color bar.'
	  print,'   BARPOS=posb Color bar position (def=to the right of plot).'
	  print,'     May be given in device or normalized coordinates.'
	  print,'   OUTBARPOS=oposb Returned bar position (useful for default).'
	  print,'     In same coordinates as given.  Default pos is device.'
	  print,'   BARTITLE=ttb Color bar title (def=none).'
	  print,'   OUTPOS=outpos Returned main plot position.'
	  print,' Notes: Plot keywords can be given to control the main plot.'
    	  return
	end
 
	;-------------------------------------------
	;  Set defaults
	;-------------------------------------------
	if n_elements(x)    eq 0 then x=findgen(dimsz(z,1))
	if n_elements(y)    eq 0 then y=findgen(dimsz(z,2))
	if n_elements(pos)  eq 0 then pos=[.1, .1, .8, .9]
	if n_elements(csz)  eq 0 then csz=1.5
	if n_elements(cclr) eq 0 then cclr=0
	if n_elements(cthk) eq 0 then cthk=2
	if n_elements(fct)  eq 0 then fct=1.
	if n_elements(mnsh) eq 0 then mnsh=0.
	if n_elements(ttl)  eq 0 then ttl=''
	if n_elements(ttx)  eq 0 then ttx=''
	if n_elements(tty)  eq 0 then tty=''
	if n_elements(ttb)  eq 0 then ttb=''
	outpos = pos
 
	;-------------------------------------------
	;  Deal with default levels
	;-------------------------------------------
	if n_elements(lv) eq 0 then begin
	  naxes,min(z),max(z),10,tx1, tx2, nt, xinc, ndec
	  lv = makex(tx1, tx2, xinc)
	endif
	outlv = lv			; Return levels (in case defaulted).
 
	;-------------------------------------------
	;  Prepare image for display
	;-------------------------------------------
	mx = n_elements(lv)		; Max region number (0-mx).
	rg = regions(z,lv)		; Convert image to regions.
	s = scalearray(rg,0,mx)>0<255	; Scale regions image for disp.
	tvlct,rr,gg,bb,/get		; Read current color table.
	r = rr[s]			; Split scaled image into R,G,B.
	g = gg[s]
	b = bb[s]
	if keyword_set(shade) then begin  ; Shade surface.
	  t = topo2(z*fct,ax=135,/scale,min=mnsh) ; Shading array (0 to 1).
	  r = round(r*t)		; Shaded R,G,B components.
	  g = round(g*t)
	  b = round(b*t)
	endif
	img = img_merge(r,g,b,tr=3)	; Merge R,G,B components.
 
	;-------------------------------------------
	;  Do plot
	;-------------------------------------------
	izoom, x, y, img, _extra=extra, iso=iso, $
          position=pos,back=-1,col=0,chars=csz
	contour, z, x, y, lev=lv, /noerase, iso=iso, $
          xstyle=5,ystyle=5,position=pos, $
          col=cclr,thick=cthk,chars=csz
 
	;-------------------------------------------
	;  Color bar
	;-------------------------------------------
	if keyword_set(nobar) then return
	plotwin, ix,iy,dx,dy		; Main plot position.
	if n_elements(posb) eq 0 then begin  ; Default bar position.
	  xoff = 6*!d.x_ch_size		; X offset in pixels.
	  dxb = 8*!d.x_ch_size		; Bar width in pixels.
	  ixb = ix + dx + xoff
	  iyb = (iy+.5*dy)-dy/3.
	  dyb = 2.*dy/3.		; Bar height.
	  posb = [ixb,iyb,ixb+dxb,iyb+dyb] ; Bar position.
	  outposb = posb		; Return bar position.
	endif 
	devflg = 0			; Assume bar position in norm coord.
	if max(posb) gt 1 then devflg=1 ; Bar position was dev coord.
	dyb = posb[3]-posb[1]		; Bar height.
	dxb = posb[2]-posb[0]
	ixb = posb[0]
	if devflg eq 0 then begin
	  dyb = dyb*!d.y_size		; Force to pixels.
	  dxb = dxb*!d.x_size
	  ixb = ixb*!d.x_size
	endif
	zb0 = maken(min(z),max(z),dyb+1) ; Bar values.
	zb = transpose(zb0)
	rg = regions(zb,lv)		; Convert image to regions.
	rg = rebin(rg,dxb,dimsz(rg,2))
	s = scalearray(rg,0,mx)>0<255	; Scale regions image for disp.
	tvlct,rr,gg,bb,/get		; Read current color table.
	r = rr[s]			; Split scaled image into R,G,B.
	g = gg[s]
	b = bb[s]
	;---  Shade color bar  ---
	xx = maken(0,!pi,dxb)		; X axis (for shading if requested).
	if keyword_set(shade) then begin   ; Shade surface.
	  zbar = rebin(sin(xx)^1,dxb,dimsz(rg,2))
	  t = topo2(zbar*10,ax=135,/scale,min=mnsh) ; Shading array (0 to 1).
	  r = round(r*t)		; Shaded R,G,B components.
	  g = round(g*t)
	  b = round(b*t)
	endif
	img = img_merge(r,g,b,tr=3)	; Merge R,G,B components.
	izoom,xx,zb0,img,pos=posb,$     ; Display bar.
	  xstyl=5,ystyl=5,/noerase,dev=devflg
	plot_posbox,posb,col=0,dev=devflg ; Outline bar.
	tmp = convert_coord(lv*0,lv,/data,/to_dev) ; Find regions in device.
	ty = tmp[1,*]			; Region boundaries.
	for i=0,n_elements(lv)-1 do $   ; Plot contour positions.
	  plots,[ixb,ixb+dxb],[ty[i],ty[i]],/dev,col=cclr,thick=cthk
	axis,/yaxis, $                  ; Add labeled axis.
	  col=0,chars=csz,ytickv=lv, $
	  yticks=n_elements(lv)+1,ytitle=ttb
 
	end
 
