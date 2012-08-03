;-------------------------------------------------------------
;+
; NAME:
;       AXIS2
; PURPOSE:
;       General axis routine for screen.
; CATEGORY:
; CALLING SEQUENCE:
;       axis2, ix0,iy0
; INPUTS:
;       ix0,iy0 = Axis reference point in device coordinates.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         RANGE=rng  Axis range: [min,max] (def=[0,100]).
;         SIDE=side Ticks and labels: 0=below (def), 1=above axis.
;         LENGTH=len  Length of axis in pixels.
;         TITLE=ttl Axis title (def=none).
;         ALIGN=aln Alignment of axis with reference point.
;           Fraction of way reference point is from axis start to
;           axis end.  Like align in xyouts. Def=0.
;         TALIGN=taln.  Axis title placement.  3 values only:
;           0: title is on left of axis, .5: title at midaxis (def),
;           1: title is on right of axis, -1 for no title.
;         TICKLENGTH=tk  Ticklength in pixels (def=8).
;         LABOFF=off Label offset in tick lengths (def=1.5).
;         /NOLABELS means plot ticks but not labels.
;         /FLIP means flip labels and title 180 degrees.
;         TSPACE=tspac  Labeled tick spacing in pixels (def=50).
;         TDELTA=tdel   Labeled tick spacing in data units.
;           Value forced to a nice number.  Overrides TSPACE.
;         /NO25 means do not use multiples of 2.5 as tick spacing.
;         /NOMINOR  do not plot minor ticks.
;         /DECLUTTER Try if tick labels are touching or crowded.
;         CHARSIZE=csz  Character size (def=1).
;         ORIENTATION=ang  Angle of scale, deg CCW (def=0).
;         COLOR=clr  Color of scale and labels (def=!.color).
;         THICKNESS=thk  Thickness of scale (def=!p.thick).
;         GUARD=g Number of characters to keep title from tick
;           label (def=1).  Only works for horizontal axes,
;           disabled for any other angle.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Apr 01
;       R. Sterner, 2002 Apr 15 --- Added /NOLABELS.  Lined up maj/min ticks.
;       R. Sterner, 2002 May 01 --- Added TDELTA=tick spacing in data units.
;       R. Sterner, 2002 Nov 05 --- Correct axis endpoint.
;       R. Sterner, 2003 Mar 11 --- Added /NO25 option.
;       R. Sterner, 2003 Apr 23 --- Title offset decreased.
;       R. Sterner, 2003 May 08 --- Added GUARD=g and label crowding code.
;       R. Sterner, 2004 Jan 14 --- Added /DECLUTTER.
;       R. Sterner, 2004 Jan 19 --- Minor tuning of /declutter.
;       R. Sterner, 2007 May 11 --- Added /FLIP.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro axis2, ix0,iy0, align=aln, talign=taln0, side=side, $
	  length=len, ticklength=tlen, tspace=tspac0, title=ttl, $
	  charsize=csz, orientation=ang, color=clr, thickness=thk, $
	  range=rng, help=hlp, laboff=laboff, nolabels=nolab, $
	  tdelta=tdelta, nominor=nominor,no25=no25, guard=guard0, $
	  declutter=declutter,flip=flip
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' General axis routine for screen.'
	  print,' axis2, ix0,iy0'
	  print,'   ix0,iy0 = Axis reference point in device coordinates.  in'
	  print,' Keywords:'
	  print,'   RANGE=rng  Axis range: [min,max] (def=[0,100]).'
	  print,'   SIDE=side Ticks and labels: 0=below (def), 1=above axis.'
	  print,'   LENGTH=len  Length of axis in pixels.'
	  print,'   TITLE=ttl Axis title (def=none).'
	  print,'   ALIGN=aln Alignment of axis with reference point.'
	  print,'     Fraction of way reference point is from axis start to'
	  print,'     axis end.  Like align in xyouts. Def=0.'
	  print,'   TALIGN=taln.  Axis title placement.  3 values only:'
	  print,'     0: title is on left of axis, .5: title at midaxis (def),'
	  print,'     1: title is on right of axis, -1 for no title.'
	  print,'   TICKLENGTH=tk  Ticklength in pixels (def=8).'
	  print,'   LABOFF=off Label offset in tick lengths (def=1.5).'
	  print,'   /NOLABELS means plot ticks but not labels.'
	  print,'   /FLIP means flip labels and title 180 degrees.'
	  print,'   TSPACE=tspac  Labeled tick spacing in pixels (def=50).'
	  print,'   TDELTA=tdel   Labeled tick spacing in data units.'
	  print,'     Value forced to a nice number.  Overrides TSPACE.'
	  print,'   /NO25 means do not use multiples of 2.5 as tick spacing.'
	  print,'   /NOMINOR  do not plot minor ticks.'
	  print,'   /DECLUTTER Try if tick labels are touching or crowded.'
	  print,'   CHARSIZE=csz  Character size (def=1).'
	  print,'   ORIENTATION=ang  Angle of scale, deg CCW (def=0).'
	  print,'   COLOR=clr  Color of scale and labels (def=!.color).'
	  print,'   THICKNESS=thk  Thickness of scale (def=!p.thick).'
	  print,'   GUARD=g Number of characters to keep title from tick'
	  print,'     label (def=1).  Only works for horizontal axes,'
	  print,'     disabled for any other angle.'
	  return
	endif
 
	;-------  Set defaults  -------------------------
	if keyword_set(flip) then aflip=180. else aflip=0.
	if n_elements(aln) eq 0 then aln=0.
	if n_elements(taln0) eq 0 then taln0=0.5
	taln = taln0>0.<1.
	if (taln gt 0) and (taln lt 1) then taln=0.5	; 0, .5, 1 allowed only.
	if n_elements(len) eq 0 then len='100 pixels'
	if n_elements(tlen) eq 0 then tlen=8
	if n_elements(tspac0) eq 0 then tspac0=50
	tspac = tspac0				; Declutter may change tspac.
	if n_elements(csz) eq 0 then csz=1.
	if n_elements(ang) eq 0 then ang=0.
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(side) eq 0 then side=0
	if n_elements(rng) eq 0 then rng=[0,100]
	if n_elements(ttl) eq 0 then ttl=''
	if n_elements(laboff) eq 0 then laboff=1.5
	if n_elements(guard0) eq 0 then guard0=1.
	guard = guard0
	if ang ne 0 then guard=0.	; Only for horizontal axes (for now).
	dtry = 0			; Declutter tries (max=3).
 
	;----  Deal with length of scale: want in pixels  -----------
	len_pix = len				; Length of axis in pixels.
dloop:	ntks = (len_pix/float(tspac))>2		; Raw # labeled ticks.
 
	;------  Which side?  ----------------------
	if side eq 0 then begin
	  ux_2=0.D0 & uy_2=-1.D0	; Unit vector along ticks.
	  if keyword_set(flip) then begin
	    aa   = [0.5,0.0]		; Labels alignment.
	    aa00 = [1.0,0.0]
	    aa05 = [0.5,-2.5]		; Title alignment.
	    aa10 = [0.0,0.0]
	  endif else begin
	    aa   = [0.5,1.0]		; Labels alignment.
	    aa00 = [1.0,1.0]
	    aa05 = [0.5,3.5]		; Title alignment.
	    aa10 = [0.0,1.0]
	  endelse
	endif else begin
	  ux_2=0.D0 & uy_2=1.D0		; Unit vector along ticks.
	  if keyword_set(flip) then begin
	    aa   = [0.5,1.0]		; Labels alignment.
	    aa00 = [1.0,1.0]
	    aa05 = [0.5,3.5]		; Title alignment.
	    aa10 = [0.0,1.0]
	  endif else begin
	    aa   = [0.5,0.0]		; Labels alignment.
	    aa00 = [1.0,0.0]
	    aa05 = [0.5,-2.5]		; Title alignment.
	    aa10 = [0.0,0.0]
	  endelse
	endelse
 
	;-----  Tick and minor tick spacing  -----------------
	drng = rng(1)-rng(0)
	if n_elements(tdelta) ne 0 then begin
	  ntks = drng/tdelta		; Round maybe?
	endif
loop:
	dx = nicenumber(double(drng)/ntks,minor=dx2,no25=no25)
	xmn = ceil(rng(0)/dx)*dx		; Min tick value.
	xmx = floor(rng(1)/dx)*dx		; Max tick value.
	if xmn eq xmx then begin
	  ntks = ntks*2
	  goto, loop
	endif
	if abs((xmx+dx)-rng(1)) lt 0.001*abs(rng(1)-rng(0)) then begin
	  xmx = xmx + dx			; Correct xmx.
	endif
	xmn2 = ceil(rng(0)/dx2)*dx2		; Min minor tick value.
	xmx2 = floor(rng(1)/dx2)*dx2		; Max minor tick value.
	;------  Scaling  ------------------------------------
	pixu = float(len)/drng			; Pixels/unit
	;-----  Declutter  -----------------------------------
	if keyword_set(declutter) then begin	; Check if labels crowded.
	  if dtry gt 3 then begin		; Give up.
	    print,' Error in axis2: giving up on declutter after 3 tries.'
	  endif else begin
	    dtry = dtry + 1			; Count # trys to declutter.
	    tpix = dx*pixu			; Labeled tick space in pixels.
	    v1 = str_cliptrail0(float(xmn))	; Find longest label.
	    v2 = str_cliptrail0(float(xmx))
	    if strlen(v1) gt strlen(v2) then v=v1 else v=v2
	    textplot,/dev,0,0,v,chars=csz,/noplot,xbox=bx ; Don't plot text.
	    dbx = round(max(bx)-min(bx))	; Label width in pixels.
	    if (1.10*dbx) ge tpix then begin	; Crowded?
	      tspac = round(tspac*1.20)		; Yes, spread ticks apart.
	      goto, dloop			; Try again.
	    endif
	  endelse
	endif
	;-----  Find start point, needed vectors  ------------
	rotate_xy, 1.D0,0.D0,ang,/deg,0,0,ux,uy		; Step along axis.
	rotate_xy, ux_2,uy_2,ang,/deg,0,0,ux2,uy2	; Step along ticks.
	x1 = ix0 - ux*aln*len_pix			; Start x.
	y1 = iy0 - uy*aln*len_pix			; Start y.
	x2 = x1 + ux*len_pix				; End x.
	y2 = y1 + uy*len_pix				; End y.
	;------  Plot axis  --------------------
	plots,[x1,x2],[y1,y2],/dev,color=clr,thick=thk
	;------  Do labeled ticks  -------------
	v = makex(xmn,xmx,dx)
	lab = str_cliptrail0(float(v))
	for j=0, n_elements(v)-1 do begin
	  r = v(j)-rng(0)		; Dist from min range.
	  t = r*pixu			; Pixels from start point.
	  xt1 = x1 + t*ux		; Labeled tick start x,y.
	  yt1 = y1 + t*uy
	  xt2 = xt1 + tlen*ux2	; Labeled tick end x,y.
	  yt2 = yt1 + tlen*uy2
	  xt3 = xt1 + laboff*tlen*ux2	; Label x,y.
	  yt3 = yt1 + laboff*tlen*uy2
	  plots,round([xt1,xt2]),round([yt1,yt2]),/dev,color=clr,thick=thk
	  if n_elements(labxmin) eq 0 then labxmin=xt1	; res 03may08
	  if n_elements(labxmax) eq 0 then labxmax=xt1	; res 03may08
	  labxmin = labxmin < xt1			; res 03may08
	  labxmax = labxmax > xt1			; res 03may08
	  if not keyword_set(nolab) then begin 
	    textplot,/dev,xt3,yt3,lab(j),align=aa, chars=csz,color=clr, $
	      ori=ang+aflip, xbox=xbox
	    labxmin = labxmin < min(xbox)		; res 03may08
	    labxmax = labxmax > max(xbox)		; res 03may08
	  endif
	endfor
	;------  Do minor ticks  -------------
	if not keyword_set(nominor) then begin
	  for r=xmn2, xmx2, dx2 do begin
	    t = (r-rng(0))*pixu		; Pixels from start point.
	    xt1 = x1 + t*ux		; Labeled tick start x,y.
	    yt1 = y1 + t*uy
	    xt2 = xt1 + tlen*ux2/2.	; Labeled tick end x,y.
	    yt2 = yt1 + tlen*uy2/2.
	    plots,round([xt1,xt2]),round([yt1,yt2]),/dev,color=clr,thick=thk
	  endfor
	endif
	;------  Display units title  ----------
	if taln0 ne -1 then begin		; No units labels.
	  textplot,/dev,-1000,-1000,'X',chars=csz,xbox=bx
	  offset = max(bx)-min(bx)		; Size in pixels of 1 letter.
	  if taln eq 0 then begin			; Title on left.
	    x0 = x1 + laboff*tlen*ux2 - offset*ux	; Offset title pt.
	    y0 = y1 + laboff*tlen*uy2 - offset*uy
	    aatt = aa00
	    if guard ne 0 then begin
	      if (x0+guard*offset) gt labxmin then begin
	        x0 = labxmin - guard*offset
	      endif
	    endif
	  endif
	  if taln eq 0.5 then begin			; Title in middle.
	    x0 = (x1+x2)/2. + laboff*tlen*ux2		; Position for title.
	    y0 = (y1+y2)/2. + laboff*tlen*uy2
	    aatt = aa05
	  endif
	  if taln eq 1 then begin			; Title on right.
	    x0 = x2 + laboff*tlen*ux2 + offset*ux	; Offset title pt.
	    y0 = y2 + laboff*tlen*uy2 + offset*uy
	    aatt = aa10
	    if guard ne 0 then begin
	      if (x0-guard*offset) lt labxmax then begin
	        x0 = labxmax + guard*offset
	      endif
	    endif
	  endif
	  textplot,/dev,x0,y0,ttl, align=aatt, chars=csz, $
	    color=clr,ori=ang+aflip
	endif
 
	end
