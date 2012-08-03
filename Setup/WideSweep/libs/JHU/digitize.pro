;-------------------------------------------------------------
;+
; NAME:
;       DIGITIZE
; PURPOSE:
;       Digitize a plot in an image using the mouse cursor.
; CATEGORY:
; CALLING SEQUENCE:
;       digitize, x, y
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         MAG=mag  Cursor mag factor (def=5).
;         /NOAUTOCENTER Do not try to automatically center the
;           current point when entering them.  Autocentering is
;           useful for large scrolling windows, but does not allow
;           tracing the curve while keeping the left button pressed.
; OUTPUTS:
;       x,y = Output points along the curve.  out
; COMMON BLOCKS:
;       digitize_com
; NOTES:
;       Notes: For an XY plot in an image this routine
;       can be used to trace along the points in the curve.
;       Only linear plots are handled.  The plot need not be
;       perfectly straight, it can be at an angle.
;       The data coordinates where the axes cross may not be known
;       so to calibrate the plot 5 points are entered:
;         The point where the x and y axes cross,
;         a point about halfway out the x axis,
;         the last labeled point on the x axis,
;         a point about halfway out the y axis,
;         and the last labeled point on the y axis.
;       The known data coordinates of each point are also entered.
;       The accuracy is limited by the pixel resolution of the plot.
;       
;       Make sure to carefully follow the directions that come up.
;       Make sure to click exactly on the axes.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Sep 01
;       R. Sterner, 2005 Sep 06 --- Allowed positioning and added autocenter.
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro digitize, x, y, mag=mag, noautocenter=noauto, help=hlp
 
	common digitize_com, flag
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Digitize a plot in an image using the mouse cursor.'
	  print,' digitize, x, y'
	  print,'   x,y = Output points along the curve.  out'
	  print,' Keywords:'
	  print,'   MAG=mag  Cursor mag factor (def=5).'
	  print,'   /NOAUTOCENTER Do not try to automatically center the'
	  print,'     current point when entering them.  Autocentering is'
	  print,'     useful for large scrolling windows, but does not allow'
	  print,'     tracing the curve while keeping the left button pressed.'
	  print,' Notes: For an XY plot in an image this routine'
	  print,' can be used to trace along the points in the curve.'
	  print,' Only linear plots are handled.  The plot need not be'
	  print,' perfectly straight, it can be at an angle.'
	  print,' The data coordinates where the axes cross may not be known'
	  print,' so to calibrate the plot 5 points are entered:'
	  print,'   The point where the x and y axes cross,'
	  print,'   a point about halfway out the x axis,'
	  print,'   the last labeled point on the x axis,'
	  print,'   a point about halfway out the y axis,'
	  print,'   and the last labeled point on the y axis.'
	  print,' The known data coordinates of each point are also entered.'
	  print,' The accuracy is limited by the pixel resolution of the plot.'
	  print,' '
	  print,' Make sure to carefully follow the directions that come up.'
	  print,' Make sure to click exactly on the axes.'
	  return
	endif
 
	if n_elements(flag) eq 0 then flag=0
	if flag eq 0 then begin
	  flag = 1
	  txt = ['This help will appear only once for an IDL session.',$
		' ',$
		'The X and Y scales of the plot are calibrated using',$
		'two points on each axis.  The first step is to enter',$
		'the X coordinates of two known points on the X axis,',$
		'(one near the middle and one near the end).  Do the same',$
		'for the Y axis.  After the four coordinates have been',$
		'entered click the OK button.  At the bottom of the diagram',$
		'prompts will be given for which points to click on using',$
		'the mouse.  The point names correspond to the diagram.',$
		'Then position to the start of the curve (if needed) and',$
		'left click points on the curve.  Right click when done.']
	  xhelp,/wait,txt
	endif
 
	;--------------------------------------------------------
	;  Defaults
	;--------------------------------------------------------
	if n_elements(mag) eq 0 then mag=5
	if n_elements(noauto) eq 0 then noauto=0
	win = !d.window		; Current window.
	xsz = !d.x_size		; Window size.
	ysz = !d.y_size
 
	;--------------------------------------------------------
	;  Assume that two labeled points on both the X and Y
	;  axes may be entered.  Also assume that in general
	;  the Y data coordinate of the X axis points is not
	;  known or the X axis coordinate of the Y axis.  These
	;  will be computed.
	;
	;  First get two points on each axis:
	;	X. a1b = A point close to where the axes cross.
	;	    a1 = Another point on x axis.
	;	Y. a2b = A point close to where the axes cross.
	;	    a2 = Another point on y axis.
	;  Coordinates are device coordinates.
	;  Must also enter X data coordinates for X axis points
	;  and Y data coordinates for Y axis points:
	;	x1b, x1, y2b, y2.
	;  From lengths of axis segments compute data
	;  coordinates of the crossing points of the axes.
	;  Compute device coordinates of a0, the point where the
	;    axes cross.  Then find data coordinates d0 of a0.
	;--------------------------------------------------------
 
	;--------------------------------------------------------
	;  Set up axis points widget display and get values
	;--------------------------------------------------------
	;----------------------
	;  Layout Defaults
	;----------------------
	nx = 250
	ny = 200
	dx = 40
	dy = 40
	csz = 1.5
	csz2 = 1.2
	psz = 1
 
	;----------------------
	;  Axis points
	;----------------------
	ix0 = dx		; Axis crossing.
	iy0 = dy
	ix1 = nx-dx		; Axis end pts.
	iy1 = ny-dy
	ix2 = (ix0+ix1)/2	; Mid axis pts.
	iy2 = (iy0+iy1)/2
 
	;----------------------
	;  Set up widget
	;----------------------
	top = widget_base(title='Digitize a plot')
	b = widget_base(top,/frame,/col,xoff=0,yoff=ny)
	id_lab = widget_label(b,val='',/dynamic,/align_left)
	id_pt = widget_label(b,val='',/dynamic,/align_left)
	id_y2 = widget_text(top,xoff=ix0+7,yoff=ny-iy1-15,xsize=10,/edit)
	id_y1 = widget_text(top,xoff=ix0+7,yoff=ny-iy2-15,xsize=10,/edit)
	id_x1 = widget_text(top,xoff=ix2-38,yoff=ny-iy0-40,xsize=10,/edit)
	id_x2 = widget_text(top,xoff=ix1-38,yoff=ny-iy0-40,xsize=10,/edit)
	id_ok = widget_button(top,xoff=ix2+20,yoff=ny-iy2-10,val='OK')
	id_drw = widget_draw(top,xsize=nx,ys=ny)
	widget_control, top, /real
 
	;----------------------
	;  Draw diagram
	;----------------------
	widget_control, id_drw, get_val=win1
	wset, win1
	erase,tarclr(/hsv,0,0,.75)
	plots,/dev,[ix0,ix0,ix1+dx/3],[iy1+dy/3,iy0,iy0],col=0,thick=2
	point,/dev,ix0,iy0,col=0,size=psz
	textplot,/dev,ix0,iy0,'A',align=[.5,2],chars=csz,col=0,bold=2
	point,/dev,ix2,iy0,col=0,size=psz
	textplot,/dev,ix2,iy0,'X1',align=[.5,2],chars=csz,col=0,bold=2
	point,/dev,ix1,iy0,col=0,size=psz
	textplot,/dev,ix1,iy0,'X2',align=[.5,2],chars=csz,col=0,bold=2
	point,/dev,ix0,iy2,col=0,size=psz
	textplot,/dev,ix0,iy2,'Y1',align=[1.5,.5],chars=csz,col=0,bold=2
	point,/dev,ix0,iy1,col=0,size=psz
	textplot,/dev,ix0,iy1,'Y2',align=[1.5,.5],chars=csz,col=0,bold=2
	xyouts,/dev,ix2+10,iy1,'Enter indicated',col=0,chars=csz2
	xyouts,/dev,ix2+10,iy1-20,'known X and Y',col=0,chars=csz2
	xyouts,/dev,ix2+10,iy1-40,'coordinates',col=0,chars=csz2
 
	;----------------------
	;  Collect coordinates
	;----------------------
loop:
	ev = widget_event(id_ok)
	widget_control,id_x1,get_val=v & x1b=v(0)
	widget_control,id_x2,get_val=v & x1=v(0)
	widget_control,id_y1,get_val=v & y2b=v(0)
	widget_control,id_y2,get_val=v & y2=v(0)
	if (x1b eq '') or (x1 eq '') or (y2b eq '') or (y2 eq '') then begin
	  opt = xoption(['Try again','Cancel'], $
	    titl='Error, did not enter all values')
	  if opt eq 0 then goto, loop
	  widget_control, top, /destroy
	  return
	endif
 
	;--------------------------------------------------------
	;  Collect positions of axis points
	;--------------------------------------------------------
	wset, win		; Set to plot window.
	;--- a0:
	wshow
	swincenter,/dev,0,0
	widget_control,id_lab,set_val='Click on the following point:'
	widget_control,id_pt,set_val='A: The point where the axes cross'
	crossi,/dev,mag=mag,/xmode,button=butt,/nostatus,ix,iy
	if butt ne 1 then begin
	  widget_control, top, /dest
	  return
	endif
	wait,.2
	a0 = [ix,iy]
 
	;--- a1b:
	swincenter,/dev,xsz/2,0
	widget_control,id_pt,set_val='X1: The point on the X axis where X='+x1b
	crossi,/dev,mag=mag,/xmode,button=butt,/nostatus,ix,iy
	if butt ne 1 then begin
	  widget_control, top, /dest
	  return
	endif
	wait,.2
	a1b = [ix,iy]
	x1b = x1b+0.
 
	;--- a1:
	swincenter,/dev,xsz,0
	widget_control,id_pt,set_val='X2: The point on the X axis where X='+x1
	crossi,/dev,mag=mag,/xmode,/nostatus,button=butt,ix,iy
	if butt ne 1 then begin
	  widget_control, top, /dest
	  return
	endif
	wait,.2
	a1 = [ix,iy]
	x1 = x1+0.
 
	;--- a2b:
	swincenter,/dev,0,ysz/2
	widget_control,id_pt,set_val='Y1: The point on the Y axis where Y='+y2b
	crossi,/dev,mag=mag,/xmode,/nostatus,button=butt,ix,iy
	if butt ne 1 then begin
	  widget_control, top, /dest
	  return
	endif
	wait,.2
	a2b = [ix,iy]
	y2b = y2b+0.
 
	;--- a2:
	swincenter,/dev,0,ysz
	widget_control,id_pt,set_val='Y2: The point on the Y axis where Y='+y2
	crossi,/dev,mag=mag,/xmode,/nostatus,button=butt,ix,iy
	if butt ne 1 then begin
	  widget_control, top, /dest
	  return
	endif
	a2 = [ix,iy]
	y2 = y2+0.
 
	widget_control, top, /dest	; Done with diagram widget.
 
	;--------------------------------------------------------
	;  Compute Y coordinate of X axis and
	;  X coordinate of Y axis.  Then compute axes
	;  crossing point data coordinates, d0.
	;  Pack the computed coordinates into points.
	;--------------------------------------------------------
	len1 = sqrt((a1(0)-a1b(0))^2 + (a1(1)-a1b(1))^2)
	len0 = sqrt((a1(0)-a0(0))^2 + (a1(1)-a0(1))^2)
	x0 = x1 - (len0/len1)*(x1-x1b)
	len1 = sqrt((a2(0)-a2b(0))^2 + (a2(1)-a2b(1))^2)
	len0 = sqrt((a2(0)-a0(0))^2 + (a2(1)-a0(1))^2)
	y0 = y2 - (len0/len1)*(y2-y2b)
 
	d0 = [x0,y0]
	d1 = [x1,y0]
	d2 = [x0,y2]
 
	;--------------------------------------------------------
	;  Form axis unit vectors
	;--------------------------------------------------------
	v1 = a1-a0		; Vector for X axis.
	v2 = a2-a0		; Vector for Y axis.
	u1 = unit(v1)		; Unit vector for X axis.
	u2 = unit(v2)		; Unit vector for Y axis.
	len1 = sqrt(total(v1*v1))  ; Length of v1.
	len2 = sqrt(total(v2*v2))  ; Length of v2.
 
	;--------------------------------------------------------
	;  Collect points on curve
	;--------------------------------------------------------
	swincenter,/dev,0,0
	xmess,'Position to start of curve'
	xcurve,/dev,ix,iy,mag=mag,auto=1-noauto
	v3x = ix - a0(0)	; Vector from axes crossing to curve pt.
	v3y = iy - a0(1)
	n = n_elements(ix)	; # curve pts.
	v3 = [transpose(v3x),transpose(v3y)]
 
	;--------------------------------------------------------
	;  Resolve curve point vectors into components
	;  parallel to axes
	;--------------------------------------------------------
	v31 = 0.*v3x
	v32 = 0.*v3x
	for i=0,n-1 do begin
	  v31(i) = total(v3(*,i)*u1)	; Pixels along x axis.
	  v32(i) = total(v3(*,i)*u2)	; Pixels along y axis.
	endfor
 
	;--------------------------------------------------------
	;  Convert from pixels to data units.
	;--------------------------------------------------------
	x0 = d0(0)			; Axis crossing x value.
	y0 = d0(1)			; Axis crossing y value.
	xsc = (d1(0)-d0(0))/len1	; X scale (units/pixel).
	ysc = (d2(1)-d0(1))/len2	; Y scale (units/pixel).
	x = v31*xsc + x0
	y = v32*ysc + y0
 
	end
