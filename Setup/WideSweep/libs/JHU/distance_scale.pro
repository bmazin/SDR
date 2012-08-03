;-------------------------------------------------------------
;+
; NAME:
;       DISTANCE_SCALE
; PURPOSE:
;       Plot a distance scale in graphics screen.
; CATEGORY:
; CALLING SEQUENCE:
;       distance_scale, ix0,iy0
; INPUTS:
;       ix0,iy0 = Axis reference point in device coordinates.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         U1=u1 Main units for scale (like Miles, Km, ...). Required.
;         U2=u2 Optional secondary units (like Km).
;           Main units are below scale, secondary above.
;           Only the following units are allowed:
;           nmiles (nautical miles), miles (statute miles),
;           kms (kilometers), meters, yards, feet.
;         SCALE=scl  Scaling between units and pixels.  Required.
;           May give as u1/pixel, u2/pixel, pixels/u1, or pixels/u2.
;           Ex: SCALE='10 miles/pixel', SCALE='23.5 pixels/km', ...
;         LENGTH=len  Length of scale in any allowed units or pixels.
;           Ex: '200 miles', '300 km', '100 pixels'=default.
;           If no units are given pixels are assumed.
;         ALIGN=aln Alignment of axis with reference point.
;           Fraction of way reference point is from axis start to
;           axis end.  Like align in xyouts.
;         TALIGN=taln.  Axis units label placement.  3 values only:
;           0: units are on left of axis, .5: units at midaxis,
;           1: units are on right of axis, -1 for no units.
;         TICKLENGTH=tk  Ticklength in pixels (def=8).
;         TSPACE=tspac  Labeled tick spacing in pixels (def=50).
;         CHARSIZE=csz  Character size (def=1).
;         ORIENTATION=ang  Angle of scale, deg CCW (def=0).
;         COLOR=clr  Color of scale and labels (def=!.color).
;         THICKNESS=thk  Thickness of scale (def=!p.thick).
; OUTPUTS:
; COMMON BLOCKS:
;       distance_scale_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Feb 04
;       R. Sterner, 2002 Feb 10 --- Moved labels closer to axis.
;       R. Sterner, 2003 Apr 23 --- Smaller units label offset.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro distance_scale, ix0,iy0, u1=u1, u2=u2, align=aln, talign=taln0, $
	  scale=scl, length=len, ticklength=tlen, tspace=tspac, $
	  charsize=csz, orientation=ang, color=clr, thickness=thk, help=hlp
 
	common distance_scale_com, unames, uabr, cf
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Plot a distance scale in graphics screen.'
	  print,' distance_scale, ix0,iy0'
	  print,'   ix0,iy0 = Axis reference point in device coordinates.  in'
	  print,' Keywords:'
	  print,'   U1=u1 Main units for scale (like Miles, Km, ...). Required.'
	  print,'   U2=u2 Optional secondary units (like Km).'
	  print,'     Main units are below scale, secondary above.'
	  print,'     Only the following units are allowed:'
	  print,'     nmiles (nautical miles), miles (statute miles),'
	  print,'     kms (kilometers), meters, yards, feet.'
	  print,'   SCALE=scl  Scaling between units and pixels.  Required.'
	  print,'     May give as u1/pixel, u2/pixel, pixels/u1, or pixels/u2.'
	  print,"     Ex: SCALE='10 miles/pixel', SCALE='23.5 pixels/km', ..."
	  print,'   LENGTH=len  Length of scale in any allowed units or pixels.'
	  print,"     Ex: '200 miles', '300 km', '100 pixels'=default."
	  print,'     If no units are given pixels are assumed.'
	  print,'   ALIGN=aln Alignment of axis with reference point.'
	  print,'     Fraction of way reference point is from axis start to'
	  print,'     axis end.  Like align in xyouts.'
	  print,'   TALIGN=taln.  Axis units label placement.  3 values only:'
	  print,'     0: units are on left of axis, .5: units at midaxis,'
	  print,'     1: units are on right of axis, -1 for no units.'
	  print,'   TICKLENGTH=tk  Ticklength in pixels (def=8).'
	  print,'   TSPACE=tspac  Labeled tick spacing in pixels (def=50).'
	  print,'   CHARSIZE=csz  Character size (def=1).'
	  print,'   ORIENTATION=ang  Angle of scale, deg CCW (def=0).'
	  print,'   COLOR=clr  Color of scale and labels (def=!.color).'
	  print,'   THICKNESS=thk  Thickness of scale (def=!p.thick).'
	  return
	endif
 
	;-------  Initialize internal common  ----------------
	;	unames = Names of recognized units.
	;	uabr = Allowed abbreviations of units.
	;	cf = Conversion factors between units.
	;-----------------------------------------------------
	if n_elements(unames) eq 0 then begin
	  unames = ['nautical miles','statute miles','kilometers', $
		    'meters','yards','feet']
	  uabr = ['NM','MI','KM','ME','YA','FE']
	  cf = [1852.,1609.344,1000.,1.,0.9144,0.3048]
	endif
 
	;-------  Check required keywords  -------------------
	if n_elements(u1) eq 0 then begin
	  print,' Error in distance_scale: Required keyword U1 not given.'
	  return
	endif
	if n_elements(scl) eq 0 then begin
	  print,' Error in distance_scale: Required keyword SCALE not given.'
	  return
	endif
 
	;-------  Set defaults  -------------------------
	if n_elements(u2) eq 0 then u2=''
	if n_elements(aln) eq 0 then aln=0.
	if n_elements(taln0) eq 0 then taln0=0.5
	taln = taln0>0.<1.
	if (taln gt 0) and (taln lt 1) then taln=0.5	; 0, .5, 1 allowed only.
	if n_elements(len) eq 0 then len='100 pixels'
	if n_elements(tlen) eq 0 then tlen=8
	if n_elements(tspac) eq 0 then tspac=50
	if n_elements(csz) eq 0 then csz=1.
	if n_elements(ang) eq 0 then ang=0.
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(thk) eq 0 then thk=!p.thick
 
	;-------  Deal with units  ------------------------
	units = [strmid(strupcase(u1),0,2)]
	if u2 ne '' then units=[units,strmid(strupcase(u2),0,2)]
 
	;----  Deal with scale: want meters/pixel  -------------------
	if nwrds(scl) lt 2 then begin
	  print,' Error in distance_scale: the SCALE keyword must give a'
	  print,'   number and then units.  Like 15 miles/pixel or'
	  print,'   13.5 pixels/km'
	  return
	endif
	val = getwrd(scl,0)+0.0		; Grab value.
	utxt0 = getwrd(scl,1,3)		; Grab units text.
	utxt = repchr(utxt0,'/')	; Replace / with space.
	ut = strmid(strupcase(getwrd(utxt,0)),0,2)	; Units on top.
	ub = strmid(strupcase(getwrd(utxt,1)),0,2)	; Units on bottom.
	if (ut ne 'PI') and (ub ne 'PI') then begin
	  print,' Error in distance_scale: SCALE must be in units/pixel'
	  print,"   or pixels/unit, like SCALE='12.5 km/pixel'."
	  return
	endif
	if ut eq 'PI' then begin	; Force units/pixel.
	  val = 1./val			; Invert value.
	  ut = ub			; Want ut to be units.
	endif
	w = where(uabr eq ut,cnt)
	if cnt eq 0 then begin
	  print,' Error in distance_scale: unknown units in scale: '+scl
	  return
	endif
	m_pix = val*cf(w(0))		; Scale in meters/pixel.
 
	;----  Deal with length of scale: want in pixels  -----------
	len_s = string(len)
	val = getwrd(len_s,0)+0.0		; Grab value.
	utxt = getwrd(len_s,1)		; Grab units text.
	if utxt eq '' then utxt='pixels'		; Pixels are default.
	ut = strmid(strupcase(getwrd(utxt,0)),0,2)	; Units abbreviation.
	if ut ne 'PI' then begin
	  w = where(uabr eq ut,cnt)
	  if cnt eq 0 then begin
	    print,' Error in distance_scale: unknown units in length: '+len_s
	    return
	  endif
	  len_pix = val*cf(w(0))/m_pix		; Length of axis in pixels.
	endif else len_pix=val
	len_m = len_pix*m_pix			; Length of axis in m.
	ntks = (len_pix/float(tspac))>2		; Raw # labeled ticks.
 
	;------  Loop through the 1 or 2 units  ----------------
	for i=0,n_elements(units)-1 do begin
	  ;-----  Set up values for main or secondary axis  -------
	  if i eq 0 then begin		; Below axis.
	    ux_2=0. & uy_2=-1.		; Unit vector along ticks.
	    aa = [0.5,1.0]		; Label alignment.
	    aa00 = [1.0,1.0]
	    aa05 = [0.5,3.5]		; Title alignment.
	    aa10 = [0.0,1.0]
	  endif else begin		; Above axis.
	    ux_2=0. & uy_2=1.		; Unit vector along ticks.
	    aa = [0.5,0.0]		; Label alignment.
	    aa00 = [1.0,0.0]
	    aa05 = [0.5,-2.5]		; Title alignment.
	    aa10 = [0.0,0.0]
	  endelse
	  ;-----  Find length, title, step, and minor step  -------
	  w = where(uabr eq units(i),cnt)
	  iw = w(0)		; Index for units(i).
	  cfu = cf(iw)		; m per units(i).
	  pixu = cfu/m_pix	; Pixels per units(i).
	  len_u = len_m/cfu	; Axis length in units(i).
	  ttl = unames(iw)	; Full name of units(i).
	  dx = nicenumber(len_u/ntks,minor=dx2)
	  ;-----  Find start point, needed vectors  ------------
	  rotate_xy, 1.,0.,ang,/deg,0,0,ux,uy		; Step along axis.
	  rotate_xy, ux_2,uy_2,ang,/deg,0,0,ux2,uy2	; Step along ticks.
	  x1 = ix0 - ux*aln*len_pix			; Start x.
	  y1 = iy0 - uy*aln*len_pix			; Start y.
	  x2 = x1 + ux*len_pix				; End x.
	  y2 = y1 + uy*len_pix				; End y.
	  ;------  Plot axis  --------------------
	  plots,[x1,x2],[y1,y2],/dev,color=clr,thick=thk
	  ;------  Do labeled ticks  -------------
	  v = makex(0., len_u, dx)
	  lab = str_cliptrail0(v)
	  for j=0, n_elements(v)-1 do begin
	    r = v(j)
	    t = r*pixu			; Pixels from start point.
	    xt1 = x1 + t*ux		; Labeled tick start x,y.
	    yt1 = y1 + t*uy
	    xt2 = xt1 + tlen*ux2	; Labeled tick end x,y.
	    yt2 = yt1 + tlen*uy2
;	    xt3 = xt1 + 2*tlen*ux2	; Label x,y.
;	    yt3 = yt1 + 2*tlen*uy2
	    xt3 = xt1 + 1.5*tlen*ux2	; Label x,y.
	    yt3 = yt1 + 1.5*tlen*uy2
	    plots,[xt1,xt2],[yt1,yt2],/dev,color=clr,thick=thk
	    textplot,/dev,xt3,yt3,lab(j),align=aa, chars=csz,color=clr,ori=ang
	  endfor
	  ;------  Do minor ticks  -------------
	  for r=0., len_u, dx2 do begin
	    t = r*pixu			; Pixels from start point.
	    xt1 = x1 + t*ux		; Labeled tick start x,y.
	    yt1 = y1 + t*uy
	    xt2 = xt1 + tlen*ux2/2.	; Labeled tick end x,y.
	    yt2 = yt1 + tlen*uy2/2.
	    plots,[xt1,xt2],[yt1,yt2],/dev,color=clr,thick=thk
	  endfor
	  ;------  Display units title  ----------
	  if taln0 ne -1 then begin		; No units labels.
	    textplot,/dev,-1000,-1000,'XX',chars=csz,xbox=bx
	    offset = max(bx)-min(bx)		; Size in pixels of 4 letters.
	    if taln eq 0 then begin
	      x0 = x1 + 1.5*tlen*ux2 - offset*ux	; Offset title pt.
	      y0 = y1 + 1.5*tlen*uy2 - offset*uy
	      aatt = aa00
	    endif
	    if taln eq 0.5 then begin
	      x0 = (x1+x2)/2. + 1.5*tlen*ux2	; Position for title.
	      y0 = (y1+y2)/2. + 1.5*tlen*uy2
	      aatt = aa05
	    endif
	    if taln eq 1 then begin
	      x0 = x2 + 1.5*tlen*ux2 + offset*ux	; Offset title pt.
	      y0 = y2 + 1.5*tlen*uy2 + offset*uy
	      aatt = aa10
	    endif
	    textplot,/dev,x0,y0,ttl, align=aatt, chars=csz,color=clr,ori=ang
	  endif
	endfor
 
	end
