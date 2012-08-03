;--------------------------------------------------------------
;  rturtle__define.pro = Relative turtle like graphics
;  R. Sterner, 2004 Dec 13
;  R. Sterner, 2004 Dec 20 --- Made oclr default to clr.
;  R. Sterner, 2004 Dec 21 --- Added ANG=ang and /ABS to PLOT method.
;  R. Sterner, 2004 Dec 22 --- Fixed angle update after plot.
;  R. Sterner, 2005 Feb 09,10 --- Fixed turtle color. Fixed polygon ang.
;	cleanup up code, dropped unused code.
;  R. Sterner, 2005 Feb 10 --- Added Help method. Added GET method.
;  R. Sterner, 2005 Nov 03 --- Moved turle code to end of SET so it reflects
;    any new values (like new position).
;
;  External routines called:
;    rotate_xy: rotate points about a given point.
;    polrec: convert from polar to rectangular coordinates.
;    recpol: convert from rectangular to polar coordinates.
;    whoami: Find source directory (in help).
;    filename: Make help file name (in help).
;    getfile: read help file (in help).
;
;  Terms:
;	Screen coordinates: This is the same is IDL device
;	  coordinates.  The origin is at the lower left
;	  screen corner.
;	Relative device coordinates: Device or pixel
;	  coordinates relative to the reference point.
;	  dx, dy below are in these coordinates so will
;	  be at angle orient and scale sc.
;	Device point: Coordinates of a point in screen
;	  coordinates.
;	Current point: Coordinates of the current turtle
;	  position in pixels relative to the reference point
;	  in relative coordinates.  This position gets
;	  scaled by sc and rotated by orient to get the
;	  final plotted screen coordinates.  The origin of
;	  this system is the reference point in screen
;	  coordinates.
;
;  Methods:
;	HELP
;	  Display or return help text.
;	DRAW, dist, ang
;	  Draw from current point at ang from current direction.
;	MOVE, dist, ang
;	  Move from current point at ang from current direction.
;	  Both DRAW and MOVE allow TOX=tox or TOY=toy which mean
;	  do not cross the given x or y limit in rel coords.
;	  Useful to return to the specified x or y line.
;	DRAWXY, dx, dy
;	  Draw from current point to point dx,dy away.
;	MOVEXY, dx, dy
;	  Move from current point to point dx,dy away.
;	DRAWTOXY, x, y
;	  Draw to x,y in relative coords.
;	MOVETOXY, x, y
;	  Move to x,y in relative coords.
;
;	Each of the above routines may also give any keywords
;	known by the SET method.  This allows items like color,
;	ocolor, thickness, linestyle to be changed on the call.
;	Also the keyword /START may be given on one call to
;	start building a polygon.  Use the above routines to
;	build the polygon.  To terminate the polygon use on
;	the last call the keywords /CLOSE, and /FILL and/or
;	/OUTLINE.
;
;	SAVE = Save current position and direction.
;	RESTORE = Restore saved position and direction.
;	PLOT = internal utility used by all the DRAWs and MOVEs.
;	POLY = Plot a polygon about current point.  Used by XTURTLE.
;	XTURTLE = Plot or erase a turtle symbol.  Plots in XOR mode.
;	CIRCLE, radius, N=n
;	  Draw a circle about the current point. May give N sides for a poly.
;	CHORD
;	  Draw chords in a circle about the current point.
;	SET = Set values.
;	GET = get values.
;	STATUS = Display internal status.
;--------------------------------------------------------------
 
	;======================================================
	;  HELP = Read and list help file.
	;======================================================
	pro rturtle::help, out=txt, quiet=quiet
	whoami, dir
	hfile = filename(dir,'rturtle_help.txt',/nosym)
	txt = getfile(hfile)
	if not keyword_set(quiet) then more,txt
	end
 
	;======================================================
	;  DRAW = Do specified polar draw.
	;    Relative to current position and direction.
	;    TOX=tox, TOY=toy means draw up to but not past
	;      specified x or y limit (relative to ref pt).
	;======================================================
	pro rturtle::draw, dist, ang, tox=tox, toy=toy, _extra=extra
	self->xturtle, /off
	self->plot, dist, ang, pen=1, /polar, tox=tox, toy=toy, _extra=extra
	self->xturtle, /on
	end
 
	;======================================================
	;  MOVE = Do specified polar move.
	;    Relative to current position and direction.
	;    TOX=tox, TOY=toy means draw up to but not past
	;      specified x or y limit (relative to ref pt).
	;======================================================
	pro rturtle::move, dist, ang, tox=tox, toy=toy, _extra=extra
	self->xturtle, /off
	self->plot, dist, ang, pen=0, /polar, tox=tox, toy=toy, _extra=extra
	self->xturtle, /on
	end
 
	;======================================================
	;  DRAWXY = Do specified rect draw.
	;    Relative to current position.
	;======================================================
	pro rturtle::drawxy, dx, dy, _extra=extra
	self->xturtle, /off
	self->plot, dx, dy, pen=1, _extra=extra
	self->xturtle, /on
	end
 
	;======================================================
	;  MOVEXY = Do specified rect move.
	;    Relative to current position.
	;======================================================
	pro rturtle::movexy, dx, dy, _extra=extra
	self->xturtle, /off
	self->plot, dx, dy, pen=0, _extra=extra
	self->xturtle, /on
	end
 
	;======================================================
	;  DRAWTOXY = Do specified abs rect draw.
	;    Relative to reference point.
	;======================================================
	pro rturtle::drawtoxy, x, y, _extra=extra
	self->xturtle, /off
	self->plot, x, y, pen=1, /ref, _extra=extra
	self->xturtle, /on
	end
 
	;======================================================
	;  MOVETOXY = Do specified abs rect move.
	;    Relative to reference point.
	;======================================================
	pro rturtle::movetoxy, x, y, _extra=extra
	self->xturtle, /off
	self->plot, x, y, pen=0, /ref, _extra=extra
	self->xturtle, /on
	end
 
	;======================================================
	;  XTURTLE = Show turtle in xor mode.
	;    Call once to show turtle, again to erase.
	;    /ON means ignore if turle is already plotted.
	;    /OFF means ignore if turle is already erased.
	;======================================================
	pro rturtle::xturtle, on=on, off=off
	if self.showturtle eq 0 then return
	if (self.turtleon eq 1) and keyword_set(on) then return
	if (self.turtleon eq 0) and keyword_set(off) then return
	device,get_graphics=gmode	; Current graphics mode.
	device,set_graphics=6		; XOR mode.
	d = self.turtlescale*5./self.sc	; 10 pixels (for scale of 1).
	xx = [-d,d,2*d,d,-d,-d]		; Turtle polygon.
	yy = [-d,-d,0,d,d,-d]
	self->poly, xx, yy, ocolor=-1,/outline	; Plot turtle.
	device,set_graphics=gmode	; Restore graphics mode.
	self.turtleon = 1 - self.turtleon  ; Swap state.
	end
 
	;======================================================
	;  CIRCLE = Plot a circle or other regular polygon.
	;    Outline by default, use OCOLOR=oclr to set color.
	;    /FILL fills with COLOR=clr.
	;    /OUTLINE with /FILL to also outline.
	;======================================================
	pro rturtle::circle, r, n=n, _extra=extra
	if n_elements(r) eq 0 then r=1.
	if n_elements(n) eq 0 then n=90
	polrec, r, 360.*findgen(n+1)/n, /deg, xx, yy
	self->xturtle, /off
	self->poly, xx, yy, _extra=extra
	self->xturtle, /on
	end
 
	;======================================================
	;  SAVE = Save current location and direction.
	;    ANGLE=ang means use given angle instead of
	;    saved angle.  /ABS means given angle is the angle
	;    in unrotated device coordinates, else ang is
	;    the new pointing direction in relative turtle
	;    coordinates.
	;======================================================
	pro rturtle::save, angle=ang, abs=abs
	self.xsv = self.x0
	self.ysv = self.y0
	if n_elements(ang) then begin
	  self->xturtle, /off
	  if keyword_set(abs) then begin
	    self.ang = ang - self.orient
	  endif else begin
	    self.ang = ang
	  endelse 
	  self->xturtle, /on
	endif else self.asv=self.ang
	end
 
	;======================================================
	;  RESTORE = Restore saved location and direction.
	;    ANGLE=ang means use given angle instead of
	;    saved angle.  /ABS means given angle is the angle
	;    in unrotated device coordinates, else ang is
	;    the new pointing direction in relative turtle
	;    coordinates.
	;======================================================
	pro rturtle::restore, angle=ang, abs=abs
	self->xturtle, /off
	self.x0 = self.xsv
	self.y0 = self.ysv
	if n_elements(ang) then begin
	  self->xturtle, /off
	  if keyword_set(abs) then begin
	    self.ang = ang - self.orient
	  endif else begin
	    self.ang = ang
	  endelse
	  self->xturtle, /on
	endif else self.ang=self.asv
	self->xturtle, /on
	end
 
 
	;======================================================
	;  CHORD = Draw chords for a circle of radius rd about
	;    the current point.
	;    rr = array of offsets from circle center.
	;    RADIUS=rd Radius of circle (device units).
	;    ANG=a = single angle of normal to chords (deg).
	;      Default is relative to current pointing direction.
	;    /ABS means angle is for unrotated device coords.
	;    /REL means angle is for relative turtle coordinates.
	;    COLOR=clr, THICKNESS=thk, LINESTYLE=sty allowed.
	;======================================================
	pro rturtle::chord, rr, angle=ang, radius=rd, abs=abs, $
	  rel=rel, color=clr, thickness=thk, linestyle=sty
 
	;-------------------------------------------------------
	;  Default values
	;-------------------------------------------------------
	if n_elements(ang) eq 0 then ang=0
	if n_elements(clr) eq 0 then clr=self.clr
	if n_elements(thk) eq 0 then thk=self.thk
	if n_elements(sty) eq 0 then sty=self.sty
 
	;-------------------------------------------------------
	;  Find chord points.
	;-------------------------------------------------------
	if n_elements(rd) eq 0 then rd=10.	; Default radius.
	if n_elements(rr) eq 0 then rr=0.	; Default chord = at 0 x.
	w = where(abs(rr) lt rd, cnt)		; Only keep inside circle.
	if cnt eq 0 then return			; No good chords.
	rr2 = transpose(rr(w))			; Drop any bad chords, trans.
	xx = [rr2,rr2]				; Chord x coords.
	y = sqrt(rd^2-rr2^2)			; Upper y coords.
	yy = [y,-y]				; Chord y coords.
 
	;-------------------------------------------------------
	;  Rotate chord(s) about current point
	;-------------------------------------------------------
	ang2 = ang + self.ang			; Angle from pointing angle.
	if keyword_set(abs) then $		; Angle from device coord.
	  ang2 = ang - self.orient
	if keyword_set(rel) then $		; Angle from RTC.
	  ang2 = ang
	rotate_xy,xx,yy, ang2, /deg, 0, 0, x, y
	xarr = x + self.x0			; Offset from current point.
	yarr = y + self.y0
 
	;-------------------------------------------------------
	;  Transform coordinates
	;-------------------------------------------------------
	rotate_xy,xarr*self.sc,yarr*self.sc, $	; Transform.
	  self.orient, /deg, 0, 0, x, y
	xp = round(x + self.ref_x)		; Offset from ref. point.
	yp = round(y + self.ref_y)
 
	;-------------------------------------------------------
	;  Plot
	;-------------------------------------------------------
	self->xturtle, /off
	sz = size(xp)
	if sz(0) eq 1 then n=1 else n=sz(2)
	for i=0,n-1 do begin
	  plots,/dev,[xp(0,i),xp(1,i)],[yp(0,i),yp(1,i)], $
	    col=clr,thick=thk,linestyle=sty,noclip=self.noclip
	endfor
	self->xturtle, /on
 
	end
 
	;======================================================
	;  POLY = Draw polygon about current point.
	;    xx, yy = polygon x and y arrays in dev coords.
	;    Polygon plot will not update current point
	;    or direction.  All keywords apply only to this
	;    polygon and are not global.
	;    /FILL fill polygon with COLOR=clr (def=global color),
	;    /OUTLINE outline polygon with given attributes
	;      (def=global attributes).
	;    ANG=ang Rotate polygon about current point by ang.
	;      Default is relative to current pointing direction.
	;    /ABS means angle is for unrotated device coords.
	;    /REL means angle is for relative turtle coordinates.
	;
	;  Note: cannot call xturtle from with this routine
	;  since xturtle calls this routine and an endless
	;  recursion results.
	;======================================================
	pro rturtle::poly, xx, yy, fill=fill, outline=outline, $
	  color=clr, ocolor=oclr, thickness=thk, linestyle=sty, $
	  angle=ang, abs=abs,rel=rel
 
	;-------------------------------------------------------
	;  Default values
	;-------------------------------------------------------
	if (n_elements(fill) eq 0) and (n_elements(outline) eq 0) then $
	  outline=1	; Default to outline.
	if n_elements(ang) eq 0 then ang=0
	if n_elements(clr) eq 0 then clr=self.clr
	if n_elements(oclr) eq 0 then oclr=self.oclr
	if n_elements(thk) eq 0 then thk=self.thk
	if n_elements(sty) eq 0 then sty=self.sty
 
	;-------------------------------------------------------
	;  Rotate polygon about current point
	;-------------------------------------------------------
	ang2 = ang + self.ang			; Angle from pointing angle.
	if keyword_set(abs) then $		; Angle from device coord.
	  ang2 = ang - self.orient
	if keyword_set(rel) then $		; Angle from RTC.
	  ang2 = ang
	rotate_xy,xx,yy, ang2, /deg, 0, 0, x, y
	xarr = x + self.x0			; Offset from current point.
	yarr = y + self.y0
 
	;-------------------------------------------------------
	;  Transform coordinates
	;-------------------------------------------------------
	rotate_xy,xarr*self.sc,yarr*self.sc, $	; Transform.
	  self.orient, /deg, 0, 0, x, y
	xp = round(x + self.ref_x)		; Offset from ref. point.
	yp = round(y + self.ref_y)
 
	;-------------------------------------------------------
	;  Fill (or outline)
	;-------------------------------------------------------
	if keyword_set(fill) then begin		; Fill polygon.
	  polyfill,/dev,xp,yp,col=clr,noclip=self.noclip
	endif
	if keyword_set(outline) then begin	; Outline.
	  plots,/dev,xp,yp,col=oclr,thick=thk,linestyle=sty,noclip=self.noclip
	endif
 
	end
 
 
	;======================================================
	;  PLOT = Draw or Move.  Scalars only.
	;    PEN: 0=move, 1=draw.
	;    /POLAR p1=dist, p2=ang else p1=dx, p2=dy
	;    /REF move or draw relative to reference point,
	;      else last point.
	;    TOX=tox Do not move past x = tox (non-polar).
	;    TOY=toy Do not move past y = toy (non-polar).
	;    /START start a turtle polygon (made from draws
	;      and moves).
	;    /CLOSE close current turtle polygon using first
	;      point.
	;      /FILL fill polygon with clr.
	;      /OUTLINE plot outline with oclt, thk, sty.
	;======================================================
	pro rturtle::plot, p1, p2, pen=pen, polar=polar, $
	  ref=ref, start=start, close=close, $
	  fill=fill, outline=outline, $
	  tox=tox, toy=toy, _extra=extra
 
	;-------------------------------------------------------
	;  Update any plot attributes
	;-------------------------------------------------------
	self->set, _extra=extra
 
	;-------------------------------------------------------
	;  Compute delta x and delta y to new point
	;  (in relative turtle coordinates)
	;-------------------------------------------------------
	if keyword_set(polar) then begin	; Polar coordinates.
	  ang2 = self.ang + p2			; Update angle.
	  polrec, p1, ang2, /deg, dx, dy	; From polar.
	endif else begin			; Rectangular coordinates.
	  dx = p1
	  dy = p2
	endelse
 
	;-------------------------------------------------------
	;  Don't step past any given x or y limits
	;-------------------------------------------------------
	if (n_elements(tox) ne 0) and (dx ne 0) then begin
	  tox2 = tox - self.x0			; Limit relative to current.
	  fact = tox2/dx			; Reduction factor.
	  if fact lt 1. then begin		; Only use to reduce step.
	    dy = dy*fact			; Reduce step in y.
	    dx = tox2				; Set to x limit.
	  endif
	endif
	if (n_elements(toy) ne 0) and (dy ne 0) then begin
	  toy2 = toy - self.y0			; Limit relative to current.
	  fact = toy2/dy			; Reduction factor.
	  if fact lt 1. then begin		; Only use to reduce step.
	    dx = dx*fact			; Reduce step in x.
	    dy = toy2				; Set to y limit.
	  endif
	endif
 
	;-------------------------------------------------------
	;  Move or Draw: from last point or reference point?
	;-------------------------------------------------------
	if keyword_set(ref) then begin
	  xr = 0				; From ref point.
	  yr = 0
	endif else begin
	  xr = self.x0				; From last point.
	  yr = self.y0
	endelse
 
	;-------------------------------------------------------
	;  Do move and make segment
	;-------------------------------------------------------
	x1 = xr + dx				; Move from last point.
	y1 = yr + dy
	xarr = [self.x0, x1]			; Include last point.
	yarr = [self.y0, y1]
 
	;-------------------------------------------------------
	;  Transform coordinates
	;  Rotate, scale, offset.
	;-------------------------------------------------------
	rotate_xy,xarr*self.sc,yarr*self.sc, $	; Transform.
	  self.orient, /deg, 0, 0, x, y
	xp = round(x + self.ref_x)		; Offset from ref. point.
	yp = round(y + self.ref_y)
 
	;-------------------------------------------------------
	;  Plot (if pen down)
	;-------------------------------------------------------
	if pen eq 1 then begin
	  plots,/dev,xp,yp,noclip=self.noclip, $	; Plot.
	    color=self.clr, linestyle=self.sty, thick=self.thk
	endif
 
	;-------------------------------------------------------
	;  Update last point
	;-------------------------------------------------------
	self.pen = pen		; Save last pen code.
	lst = n_elements(dx)-1
	self.x0 = x1(lst)	; Save current point in rel turtle coords.
	self.y0 = y1(lst)
	lstp = n_elements(xp)-1
	self.xp0 = xp(lstp)	; Save current point in device coordinates.
	self.yp0 = yp(lstp)
	if keyword_set(polar) then begin	; Save last pointing angle.
	  self.ang = pmod(ang2,360)
	endif else begin
	  recpol, float(xarr(lst+1)-xarr(lst)), yarr(lst+1)-yarr(lst), $
	    dist, ang, /deg
	  self.ang = pmod(ang,360)
	endelse
 
	;-------------------------------------------------------
	;  Deal with polygon
	;    Polygon points are transformed points,
	;    ready to plot in dev coords.
	;-------------------------------------------------------
	if self.poly_flag then begin			; Continue a polygon.
	  px = *self.ppoly_x				; Grab current poly pts.
	  py = *self.ppoly_y
	  ptr_free, self.ppoly_x,self.ppoly_y		; Free ptrs.
	  self.ppoly_x = ptr_new([px,xp(1)])		; Add next pt.
	  self.ppoly_y = ptr_new([py,yp(1)])
	endif
 
	if keyword_set(start) then begin		; Start a new polygon.
	  ptr_free, self.ppoly_x, self.ppoly_y		; Free ptrs.
	  self.ppoly_x = ptr_new(xp)			; Start polygon.
	  self.ppoly_y = ptr_new(yp)
	  self.poly_flag = 1				; Set polygon flag.
	endif
 
	if keyword_set(close) then begin		; Terminate a polygon.
	  if self.poly_flag ne 1 then return		; No polygon.
	  px = *self.ppoly_x				; Grab current poly pts.
	  py = *self.ppoly_y
	  px = [px,px(0)]				; Close polygon.
	  py = [py,py(0)]
	  if keyword_set(fill) then begin		; Fill poygon.
	    polyfill,/dev,px,py,col=self.clr,noclip=self.noclip
	  endif
	  if keyword_set(outline) then begin		; Outline.
	    plots,/dev,px,py,col=self.oclr,thick=self.thk, $
	      linestyle=self.sty,noclip=self.noclip
	  endif
	  ptr_free, self.ppoly_x, self.ppoly_y		; Free polygon.
	  self.poly_flag = 0				; Not in polygon.
	endif
 
	end
 
 
	;======================================================
	;  SET = Set new values
	;======================================================
	pro rturtle::set, orientation=orient, scale=sc, $
	  refpoint=cen, device=dev, normal=norm, data=dat, $
	  color=clr, ocolor=oclr, linestyle=sty, thickness=thk, $
	  noclip=noclip, ton=ton, toff=toff, tstate=tstate, ang=ang, $
	  turtlescale=tsc
 
	;-------------------------------------------------------
	;  Point in new direction
	;    Sets angle in relative coordinate system.
	;    0 points in relative x, 90 in relative y.
	;-------------------------------------------------------
	if n_elements(ang) ne 0 then begin
	  self->xturtle, /off
	  self.ang = ang
	  self->xturtle, /on
	endif
 
	;-------------------------------------------------------
	;  New values
	;-------------------------------------------------------
	if n_elements(orient) ne 0 then self.orient=orient
	if n_elements(sc) ne 0 then self.sc=sc
	if n_elements(clr) ne 0 then self.clr=clr
	if n_elements(oclr) ne 0 then self.oclr=oclr
	if n_elements(sty) ne 0 then self.sty=sty
	if n_elements(thk) ne 0 then self.thk=thk
	if n_elements(noclip) ne 0 then self.noclip=noclip
 
	;-------------------------------------------------------
	;  Deal with new center.  Convert to device coords.
	;  Center is also called the reference point and is
	;  the origin of the relative turtle coordinate system.
	;-------------------------------------------------------
	if n_elements(cen) eq 2 then begin
	  xc = cen(0)		; Grab given reference point.
	  yc = cen(1)
	  self.ref_x0 = xc	; Save new reference point as given.
	  self.ref_y0 = yc
	  if keyword_set(norm) then begin
	    tmp = convert_coord(xc,yc,/norm,/to_dev)
	    ixc = tmp(0)
	    iyc = tmp(1)
	    self.ref_sys = 2	; Norm.
	  endif else if keyword_set(dat) then begin
	    tmp = convert_coord(xc,yc,/data,/to_dev)
	    ixc = tmp(0)
	    iyc = tmp(1)
	    self.ref_sys = 1	; Data.
	  endif else begin
	    ixc = xc
	    iyc = yc
	    self.ref_sys = 0	; Dev.
	  endelse
	  self.ref_x = ixc	; Ref point in device coordinates.
	  self.ref_y = iyc
	  self.x0 = 0.		; Start current point at origin.
	  self.y0 = 0.
	endif
 
	;-------------------------------------------------------
	;  Deal with turtle
	;-------------------------------------------------------
	if n_elements(tsc) ne 0 then self.turtlescale=tsc
	if n_elements(ton) ne 0 then begin
	  self.showturtle = 1
	  if not self.turtleon then begin
	    self->xturtle		; If off then plot.
	    self.turtleon = 1		; Set flag to on.
	  endif
	endif
	if n_elements(toff) ne 0 then begin
	  if self.turtleon then begin
	    self->xturtle		; If on then erase.
	    self.turtleon = 0		; Set flag to off.
	  endif
	  self.showturtle = 0
	endif
	if n_elements(tstate) ne 0 then self.turtleon=tstate
 
	end
 
 
	;======================================================
	;  STATUS = List current status
	;======================================================
	pro rturtle::status
 
	print,' '
	print,' rturtle status:'
	print,' '
	print,' Reference point: '+strtrim(self.ref_x0,2)+$
	  ', '+strtrim(self.ref_y0,2)+' '+$
	  (['Dev','Data','Norm'])(self.ref_sys)
	print,' Reference point in dev coords: '+strtrim(self.ref_x,2)+$
	  ', '+strtrim(self.ref_y,2)
	print,' Scale factor: '+strtrim(self.sc,2)
	print,' Orientation (deg): '+strtrim(self.orient,2)
	print,' Plot color: '+strtrim(self.clr,2)
	print,' Outline color: '+strtrim(self.oclr,2)
	print,' Plot thickness: '+strtrim(self.thk,2)
	print,' Plot linestyle: '+strtrim(self.sty,2)
	print,' Last pen code: '+strtrim(self.pen,2)
	print,' Last distance: '+strtrim(self.dist,2)
	print,' Last angle: '+strtrim(self.ang,2)
	print,' Current point in relative dev coords: '+strtrim(self.x0,2)+$
	  ', '+strtrim(self.y0,2)
	print,' Current point in actual dev coords: '+strtrim(self.xp0,2)+$
	  ', '+strtrim(self.yp0,2)
	print,' Showturtle: '+strtrim(self.showturtle,2)
	print,' Turtle is plotted: '+strtrim(self.turtleon,2)
	print,' Turtle size scale: '+strtrim(self.turtlescale,2)
	print,' '
	if ptr_valid(self.ppoly_x) then begin
	  px = *self.ppoly_x
	  py = *self.ppoly_y
	  n = n_elements(px)
	  print,' Turtle polygon under construction with '+strtrim(n,2)+' pts.'
	endif else print,' No turtle polygon.'
 
	end
 
	;======================================================
	;  GET = Get specified values
	;======================================================
	pro rturtle::get, orientation=orient, scale=sc, $
	  ang=ang, curr_x=curr_x, curr_y=curr_y, $
	  color=clr, ocolor=oclr, linestyle=sty, thickness=thk
 
	orient = self.orient
	sc = self.sc
	ang = self.ang
	curr_x = self.x0
	curr_y = self.y0
	clr = self.clr
	oclr = self.oclr
	sty = self.sty
	thk = self.thk
 
	end
 
 
	;======================================================
	;  CLEANUP = Cleanup any existing polygon pointers.
	;======================================================
	pro rturtle::cleanup
	ptr_free, self.ppoly_x, self.ppoly_y
	end
 
	;======================================================
	;  INIT = set up initial values
	;======================================================
	function rturtle::init, orientation=orient, scale=sc, $
	  refpoint=cen, device=dev, normal=norm, data=dat, $
	  color=clr, ocolor=oclr, linestyle=sty, thickness=thk, $
	  noclip=noclip
 
	;-------------------------------------------------------
	;  Defaults
	;-------------------------------------------------------
	if n_elements(orient) eq 0 then orient=0.
	if n_elements(sc) eq 0 then sc=1.
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(oclr) eq 0 then oclr=clr
	if n_elements(sty) eq 0 then sty=!p.linestyle
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(noclip) eq 0 then noclip=0
	if n_elements(cen) ne 2 then cen=[0.,0.]
	self.orient = orient
	self.sc = sc
	self.clr = clr
	self.oclr = oclr
	self.sty = sty
	self.thk = thk
	self.noclip = noclip
	self.turtlescale = 1.
 
	;-------------------------------------------------------
	;  Deal with center.  Convert to device coords.
	;-------------------------------------------------------
	xc = cen(0)		; Grab given reference point.
	yc = cen(1)
	self.ref_x0 = xc	; Save given values.
	self.ref_y0 = yc
	if keyword_set(norm) then begin		  ; Ref point in Norm.
	  tmp = convert_coord(xc,yc,/norm,/to_dev)
	  ixc = tmp(0)
	  iyc = tmp(1)
	  self.ref_sys = 2	; Norm.
	endif else if keyword_set(dat) then begin ; Ref point in Data.
	  tmp = convert_coord(xc,yc,/data,/to_dev)
	  ixc = tmp(0)
	  iyc = tmp(1)
	  self.ref_sys = 1	; Data.
	endif else begin			  ; Ref point in dev (default).
	  ixc = xc
	  iyc = yc
	  self.ref_sys = 0	; Dev.
	endelse
	self.ref_x = ixc	; Work in device coordinates.
	self.ref_y = iyc
 
	return, 1
        end
 
	;======================================================
	; rturtle object structure 
	;======================================================
	pro rturtle__define
 
	tmp = { rturtle, $
		ref_x: 0., $		; Reference point x (device coords).
		ref_y: 0., $		; Reference point y (device coords).
		ref_x0: 0., $		; Given reference point x.
		ref_y0: 0., $		; Given reference point y.
		ref_sys: 0, $		; Reference point coordinate system.
		orient: 0., $		; Plot orientation (deg).
		sc: 0., $		; Plot scale factor.
		clr: 0L, $		; Line color.
		oclr: 0L, $		; Outline color.
		sty: 0, $		; Linestyle.
		thk: 0, $		; Line thickness.
		noclip: 0, $		; No Clip Flag: 0=clip, 1=no clip.
		poly_flag:0, $		; Turtle polygon flag (1=in progress).
		ppoly_x: ptr_new(), $	; Pointer to turtle polygon x.
		ppoly_y: ptr_new(), $	; Pointer to turtle polygon y.
		x0: 0., $		; Current turtle x (rel device coords).
		y0: 0., $		; Current turtle y (rel device coords).
		xsv: 0., $		; Saved turtle x (rel device coords).
		ysv: 0., $		; Saved turtle y (rel device coords).
		asv: 0., $		; Saved turtle ang (rel device coords).
		xp0: 0., $		; Current turtle x (device coords).
		yp0: 0., $		; Current turtle y (device coords).
		dist: 0., $		; Last distance used.
		ang: 0., $		; Last angle used.
		pen: 0, $		; Last pen code.
		showturtle: 0, $	; Show turtle symbol.
		turtleon: 0, $		; Try to keep track of turtle plot.
		turtlescale: 0., $	; Turtle size scale (def=1).
		dum: 0 }
 
	end
