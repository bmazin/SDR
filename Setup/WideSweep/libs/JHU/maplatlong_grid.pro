;-------------------------------------------------------------
;+
; NAME:
;       MAPLATLONG_GRID
; PURPOSE:
;       Plot a lat/long grid on last map.
; CATEGORY:
; CALLING SEQUENCE:
;       maplatlong_grid
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         XDELTA=d   Longitude grid spacing in degrees (def=10).
;         YDELTA=d   Latitude grid spacing in degrees (def=10).
;         GRIDPIX=n  Approx grid spacing in pixels (def=100).
;           Use either XDELTA,YDELTA, or GRIDPIX but not both.
;         COLOR=clr Grid color (def=!p.color).
;         BOLD=bld  Bold text for labels (def=1).
;         LINESTYLE=sty = Grid linestyle (def=0).
;         THICKNESS=thk = Grid thickness (def=1).
;         /LABELS to display grid line labels.
;         CHARSIZE=csz  Label character size (def=1).
;         LCOLOR=lclr Label color (def=!p.color).
;         MARGINS=mar Array of margins needed for the labels on
;           the four sides of the map, pixels (0=bottom,1=right,...).
;         /NOPLOT do not plot grid or labels (but do LABMARGIN).
;         TICK=frac  Tick length as fraction of distance from
;           label to side of window.  /TICK gives 0.5
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: When the grid is too dense to label each line the
;         labels start with the first grid line on each side of
;         the map window, working from the bottom counter-clockwise
;         and dropping labels if they crowd previous ones too much.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jan 02
;       R. Sterner, 2002 Jan 13 --- New: xdelta, ydelta, gridpix.
;       R. Sterner, 2002 Jan 23 --- Eliminated messages.
;       R. Sterner, 2002 Jan 24 --- Fixed label spacing, added label ticks.
;       R. Sterner, 2002 Jan 29 --- Fixed a label problem.
;       R. Sterner, 2002 Jan 30 --- Allowed xdelta/ydelta=0 to autoscale.
;       R. Sterner, 2002 Feb 07 --- Added /NOPLOT and LABMARGIN keywords.
;       R. Sterner, 2004 Apr 01 --- Fixed minor bug in tick labels.
;       R. Sterner, 2004 May 28 --- Speeded up side check (added <1000).
;       R. Sterner, 2004 May 28 --- Also speeded up maplatlong call.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro maplatlong_grid, xdelta=xdelta, ydelta=ydelta, color=clr, $
	  linestyle=sty, thickness=thk, help=hlp, labels=lab, tick=tick0, $
	  charsize=csz, lcolor=lclr, bold=bld, gridpix=gridpix, $
	  noplot=noplot, margins=lbmar
 
	if keyword_set(hlp) then begin
	  print,' Plot a lat/long grid on last map.'
	  print,' maplatlong_grid'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   XDELTA=d   Longitude grid spacing in degrees (def=10).'
	  print,'   YDELTA=d   Latitude grid spacing in degrees (def=10).'
	  print,'   GRIDPIX=n  Approx grid spacing in pixels (def=100).'
	  print,'     Use either XDELTA,YDELTA, or GRIDPIX but not both.'
	  print,'   COLOR=clr Grid color (def=!p.color).'
	  print,'   BOLD=bld  Bold text for labels (def=1).'
	  print,'   LINESTYLE=sty = Grid linestyle (def=0).'
	  print,'   THICKNESS=thk = Grid thickness (def=1).'
	  print,'   /LABELS to display grid line labels.'
	  print,'   CHARSIZE=csz  Label character size (def=1).'
	  print,'   LCOLOR=lclr Label color (def=!p.color).'
	  print,'   MARGINS=mar Array of margins needed for the labels on'
	  print,'     the four sides of the map, pixels (0=bottom,1=right,...).'
	  print,'   /NOPLOT do not plot grid or labels (but do LABMARGIN).'
	  print,'   TICK=frac  Tick length as fraction of distance from'
	  print,'     label to side of window.  /TICK gives 0.5'
	  print,' Note: When the grid is too dense to label each line the'
	  print,'   labels start with the first grid line on each side of'
	  print,'   the map window, working from the bottom counter-clockwise'
	  print,'   and dropping labels if they crowd previous ones too much.'
	  return
	endif
 
	;------  Find plot window covered by last map  ------------
	mapwindow,ix1=ix1,ix2=ix2,iy1=iy1,iy2=iy2,/quiet  ; Get plot window.
	ddx = ix2-ix1		; Plot window x size in pixels.
	ddy = iy2-iy1		; Plot window y size in pixels.
 
	;------  Find lat/long range covered by last map  ------------
	step = 3.				; Default search step.
	nsteps = (ddx/step)>(ddy/step)		; How many steps?
	if nsteps gt 1000 then begin		; Too many.
	  step = round((ddx/1000.)>(ddy/1000.))	; Compute new step size.
	endif
	maplatlong,range=r,err=err,/quiet,step=step
	if err ne 0 then return
	x1=r(0) & x2=r(1) & y1=r(2) & y2=r(3)	; Map extent.
 
	;------  Set default grid spacing and color  ---------------
	if n_elements(gridpix) eq 0 then gridpix=100
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(lclr) eq 0 then lclr=!p.color
	if n_elements(bld) eq 0 then bld=1
	if n_elements(csz) eq 0 then csz=1.
	if n_elements(sty) eq 0 then sty=0
	if n_elements(thk) eq 0 then thk=0
	if n_elements(tick0) ne 0 then begin
	  if tick0 eq 1 then tick=0.5 else tick=tick0
	endif
	if n_elements(xdelta) eq 0 then xdelta=0
	if n_elements(ydelta) eq 0 then ydelta=0
 
	;-------  Automatic delta  ----------------------
	if xdelta eq 0 then begin			; No long grid step.
	  ngrid	= round(float(ddx)/gridpix)		; # of long grid lines.
	  naxes,x1,x2,ngrid,tx1,tx2,nt,xdelta,ndecx	; Compute xdelta.
	endif else begin				; Long grid step given.
	  tmp = makex(x1,x2,xdelta)			; Need to find #
	  tmp2 = str_cliptrail0(tmp,ndec=ndecx) 	; dec places needed.
	endelse
	if ydelta eq 0 then begin			; No lat grid step.
	  ngrid	= round(float(ddy)/gridpix)		; # of lat grid lines.
	  naxes,y1,y2,ngrid,ty1,ty2,nt,ydelta,ndecy	; Compute ydelta.
	endif else begin				; Lat grid step given.
	  tmp = makex(y1,y2,ydelta)			; Need to find #
	  tmp2 = str_cliptrail0(tmp,ndec=ndecy) 	; dec places needed.
	endelse
 
	;------  Find limits to plot grid  -----------------
	x10 = ceil(x1/xdelta)*xdelta		; Min grid long line.
	x20 = floor(x2/xdelta)*xdelta		; Max grid long line.
	y10 = ceil(y1/ydelta)*ydelta		; Min grid lat line.
	y20 = floor(y2/ydelta)*ydelta		; Max grid lat line.
 
	if not keyword_set(noplot) then begin
	  ;--------  Do lines of latitude  ---------------------
	  for y=y10,y20,ydelta do begin
	    xx = makex(x1,x2,xdelta/20.)
	    yy = xx*0 + y
	    oplot,xx,yy,color=clr,linestyle=sty,thick=thk
	  endfor
 
	  ;---------   Do lines of longitude  --------------------
	  for x=x10,x20,xdelta do begin
	    yy = makex(y1,y2,ydelta/20.)
	    xx = yy*0 + x
	    oplot,xx,yy,color=clr,linestyle=sty,thick=thk
	  endfor
	endif
 
	;---------  Grid labels  --------------------------------
	if not keyword_set(lab) then return
	;----  Get label offset from window side  --------------
	textplot,-1000,-1000,'X',charsize=csz,/dev,xbox=xb,ybox=yb
	cdy = max(yb)-min(yb)	; Char height in pixels.
	loff = 1.0*cdy		; Labels offset by loff from side of window.
	;----  Set up segment tables for the 4 sides of the window  -----
	xw1 = [ix1,ix2,ix2,ix1]	; P1x = Window side 1st pt x (in pixels).
	xw2 = [ix2,ix2,ix1,ix1]	; P2x = Window side 2nd pt x (in pixels).
	yw1 = [iy1,iy1,iy2,iy2]	; P1y = Window side 1st pt y (in pixels)
	yw2 = [iy1,iy2,iy2,iy1]	; P2y = Window side 2nd pt y (in pixels).
	n = [ddx,ddy,ddx,ddy]	; # pixels in i'th side.
	aln = [[.5,1],[0,.5],[.5,0],[1,.5]]	; Alignment table (no offset).
	xoff = [0,loff,0,-loff]			; Offset table for x.
	yoff = [-loff,0,loff,0]			; Offset table for y.
	lbmar = intarr(4)		; For returned label margins (pixels).
	;-----  Process each of the 4 sides  -------------------
	;  May have to do a first pass to find which side
	;  should be labeled lat and which long.  For now
	;  just use which has max # to set this.
	;  Order of sides: 0=bottom, 1=right, 2=top, 3=left.
	;  Look at lat and long along each side, every pixel
	;  (up to 1000).  Look at coordinates mod the grid
	;  spacing (sawtooth pattern), count how many teeth
	;  for each lat and long along a side.  Coordinate
	;  with most teeth gets the labels (lat or long).
	;-------------------------------------------------------
	for i=0,3 do begin
	  imod2 = i mod 2
	  xx = maken(xw1(i),xw2(i),n(i)<1000)	; Dev x along side i.
	  yy = maken(yw1(i),yw2(i),n(i)<1000)	; Dev y along side i.
	  t = convert_coord(xx,yy,/dev,/to_data)  ; Find side pixel lat/lons.
	  x = t(0,*)				; Lons along side.
	  y = t(1,*)				; Lats along side.
	  ;----  drop points along a side that are outside the map  -----
	  w = where(finite(x) eq 1,c)
	  if c eq 0 then goto, skiplab
	  x = x(w)
	  y = y(w)
	  xx = xx(w)
	  yy = yy(w)
	  ;------  Find indices of grid/side intersections  ----------
	  pmodx = pmod(x,xdelta)
	  pmody = pmod(y,ydelta)
	  inx = extremes(pmodx,-1)	; Indices for grid/side i, Long.
	  iny = extremes(pmody,-1)	; Indices for grid/side i, Lat.
	  n_x = n_elements(inx)	; # long grid lines hitting side i.
	  n_y = n_elements(iny)	; # lat grid lines hitting side i.
	  ;------  Make sure grid lines really cross side  ------
	  if max(abs(pmodx(1:*)-pmodx)) lt (xdelta/2.) then n_x=0
	  if max(abs(pmody(1:*)-pmody)) lt (ydelta/2.) then n_y=0
	  ;-----  Label side with longitudes  ------------
	  if n_x gt n_y then begin		; Side has more long grids.
	    if inx(0) lt 0 then goto,skiplab
	    ;---  Make array of labels depending on decimal places needed. --
	    if ndecx eq 0 then begin		; Label is integer.
	      txt = strtrim(fix(round((x(inx)/xdelta))*xdelta),2)
	    endif else begin			; Label has decimal fraction.
	      fmt = '(F15.'+strtrim(fix(ndecx),2)+')'
	      txt = strtrim(string(round(x(inx)/xdelta)*xdelta,form=fmt),2)
	    endelse
	    ;-----  Find size of biggest label  --------------
	    txtmx = (txt(where(strlen(txt) eq max(strlen(txt)))))(0)
	    textplot,-1000,-1000,txtmx,charsize=csz,/dev,xbox=xb,ybox=yb
	    if imod2 eq 0 then begin	; Horizontal side of window.
	      sep2 = abs(1.5*(max(xb)-min(xb)))
	      lbmar(i) = 2*loff + (max(yb)-min(yb))
	    endif else begin		; Vertical side of window.
	      sep2 = abs(2.5*(max(yb)-min(yb)))
	      lbmar(i) = 2*loff + (max(xb)-min(xb))
	    endelse
	    lstx = -1000		; Position of last label (none).
	    lsty = -1000
	    ;------  Loop through long labels  -------------------
	    if not keyword_set(noplot) then begin
	      for j=0,n_elements(txt)-1 do begin
	        in = inx(j)		; Index into position arrays.
	        aa = aln(*,i)		; Alignment for i'th side.
	        curx = xx(in)		; Position for current label.
	        cury = yy(in)
	        if imod2 eq 0 then begin	; Horizontal side of window.
	          sep = abs(curx-lstx)
	        endif else begin		; Vertical side of window.
	          sep = abs(cury-lsty)
	        endelse
	        if sep ge sep2 then begin ; Plot if not too close to last.
	          textplot, curx+xoff(i), cury+yoff(i), txt(j), charsize=csz, $
	            color=lclr, align=aa, /dev, bold=bld
	          lstx = curx		; Remember label position.
	          lsty = cury
		  if n_elements(tick0) ne 0 then $
		    plots,/dev,[curx,curx+tick*xoff(i)], $
		      [cury,cury+tick*yoff(i)], color=lclr
	        endif
	      endfor  ; j=
	    endif  ; /noplot.
	  ;-----  Label side with latitudes  ------------
	  endif else begin			; Side has more long grids.
	    if iny(0) lt 0 then goto,skiplab
	    ;---  Make array of labels depending on decimal places needed. --
	    if ndecy eq 0 then begin		; Label is integer.
	      txt = strtrim(fix(round((y(iny)/ydelta))*ydelta),2)
	    endif else begin			; Label has decimal fraction.
	      fmt = '(F15.'+strtrim(fix(ndecy),2)+')'
	      txt = strtrim(string(round(y(iny)/ydelta)*ydelta,form=fmt),2)
	    endelse
	    ;-----  Find size of biggest label  --------------
	    txtmx = (txt(where(strlen(txt) eq max(strlen(txt)))))(0)
	    textplot,-1000,-1000,txtmx,charsize=csz,/dev,xbox=xb,ybox=yb
	    if imod2 eq 0 then begin	; Horizontal side of window.
	      sep2 = abs(1.5*(max(xb)-min(xb)))
	      lbmar(i) = 2*loff + (max(yb)-min(yb))
	    endif else begin		; Vertical side of window.
	      sep2 = abs(2.5*(max(yb)-min(yb)))
	      lbmar(i) = 2*loff + (max(xb)-min(xb))
	    endelse
	    lstx = -1000		; Position of last label (none).
	    lsty = -1000
	    ;------  Loop through lat labels  -------------------
	    if not keyword_set(noplot) then begin
	      for j=0,n_elements(txt)-1 do begin
	        in = iny(j)
	        aa = aln(*,i)
	        curx = xx(in)
	        cury = yy(in)
	        if imod2 eq 0 then begin	; Horizontal side of window.
	          sep = abs(curx-lstx)
	        endif else begin		; Vertical side of window.
	          sep = abs(cury-lsty)
	        endelse
	        if sep ge sep2 then begin
	          textplot, curx+xoff(i), cury+yoff(i), txt(j), charsize=csz, $
	    	  color=lclr, align=aa, /dev, bold=bld
	          lstx = curx
	          lsty = cury
		  if n_elements(tick0) ne 0 then $
		    plots,/dev,[curx,curx+tick*xoff(i)], $
		      [cury,cury+tick*yoff(i)], color=lclr
	        endif
	      endfor  ; j=
	    endif  ; /noplot.
	  endelse
skiplab:
	endfor
 
	end
