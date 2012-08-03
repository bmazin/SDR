;-------------------------------------------------------------
;+
; NAME:
;       XCURVE
; PURPOSE:
;       Draw a curve in the display window.
; CATEGORY:
; CALLING SEQUENCE:
;       xcurve, x, y
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA   means use data coordinates (default).
;         /DEVICE means use device coordinates.
;         /NORMAL means use normalized coordinates.
;         /MAG    means display a magnification window.
;                 Default mag is 10x, MAG=pwr to set to other.
;         SIZE=sz Approx mag window size (def=200).
;         STEP_MIN = minimum step size between points.
;           Must be > 0 for data,normal, or >1 for device.
;         /AUTOCENTER Automatically center current point if
;           possible.
; OUTPUTS:
;       x,y = coordinates of curve.   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Mar 28
;       R. Sterner, 2000 Aug 08 --- Fixed repeated points. Still has erase
;       problems.
;       R. Sterner, 2002 Jul 24 --- Fixed mag window for 24-bit color.
;       R. Sterner, 2004 Mar 08 --- Fixed long term bug in drop pts erase.
;       R. Sterner, 2005 Sep 06 --- Added new keyword /AUTOCENTER.
;       R. Sterner, 2005 Sep 07 --- Added a wait after point delete.
;       R. Sterner, 2005 Sep 08 --- Fixed unerased last rubber band line.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;-----------------------------------------------------------------
;	xplot = XOR plot (avoid 0 length lines).
;	If 0 length lines are plotted it sometimes leads to unerased
;	points when points are dropped.  Related to some odd number
;	of XOR plots through a point.  This fixes the problem.
;	R. Sterner, 1995 Mar 2=30.
;-----------------------------------------------------------------
 
	pro xplot, x1,x2,y1,y2,device=dev,data=dat,normal=nor
 
	dx = x2-x1
	dy = y2-y1
	if (abs(dx)+abs(dy)) eq 0 then return
 
	device, get_graph=sv
	device, set_graph=6			; XOR mode.
        plots,[x1,x2],[y1,y2],data=dat,dev=dev,norm=nor
	empty
	device, set_graph=sv			; Reset entry mode.
 
	return
	end
 
;-----------------------------------------------------------------
;	xcurve_pnts = update point count display.
;	R. Sterner, 1995 Mar 30
;-----------------------------------------------------------------
 
	pro xcurve_pnts, id, n
 
	nn = strtrim(n,2)
	if n eq 1 then txt=nn+' point' else txt=nn+' points'
	widget_control, id, set_val=txt
 
	return
	end
 
 
;=================================================================
;	xcurve = Main routine
;=================================================================
 
	pro xcurve, xa, ya, device=dev, data=data,normal=norm, $
	  mag=mag0, size=msize0, step_min=step, autocenter=autocenter, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Draw a curve in the display window.'
	  print,' xcurve, x, y'
	  print,'   x,y = coordinates of curve.   out'
	  print,' Keywords:'
	  print,'   /DATA   means use data coordinates (default).'
	  print,'   /DEVICE means use device coordinates.'
	  print,'   /NORMAL means use normalized coordinates.'
	  print,'   /MAG    means display a magnification window.'
	  print,'           Default mag is 10x, MAG=pwr to set to other.'
	  print,'   SIZE=sz Approx mag window size (def=200).'
	  print,'   STEP_MIN = minimum step size between points.'
	  print,'     Must be > 0 for data,normal, or >1 for device.'
	  print,'   /AUTOCENTER Automatically center current point if'
	  print,'     possible.'
	  return
	endif
 
	;------  Find color depth  ---------------
        device, get_visual_name=vis    ; Get visual type.
        vflag = vis ne 'PseudoColor'   ; 0 if PseudoColor.
        tvtr = 0
        if vflag eq 1 then tvtr=3      ; True color flag.
 
 
	;-----  Deal with mag window  --------
	win1 = !d.window                                ; Current window.
	if n_elements(mag0) eq 0 then mag0=0
	if (n_elements(msize0) ne 0) and (mag0 eq 0) then mag0=1
        if mag0 ne 0 then begin
          if n_elements(msize0) eq 0 then msize0 = 200  ; Def mag win size.
          msize = round(msize0)                         ; Rounded size.
          mag = round(mag0)                             ; Rounded mag.
          if mag eq 1 then mag = 10                     ; Def is 10.
          rdsz = round(float(msize)/mag)                ; Read size.
          rdsz2 = rdsz/2                                ; Offset.
          xmid = rdsz2*mag                              ; Mag win midpoint.
          ymid = rdsz2*mag
          wsz = rdsz*mag                                ; True mag win size.
          window, /free, xs=msize, ys=msize, title='Mag: '+strtrim(mag,2)
          win2 = !d.window                              ; Mag window.
          lum = ct_luminance(dark=dark, bright=bright)  ; Center pix colors.
          wset, win1                                    ; Return to first win.
        endif
 
	;-----  Deal with the coordinate system  --------
	if n_elements(dev)  eq 0 then dev=0
	if n_elements(data) eq 0 then data=0
	if n_elements(norm) eq 0 then norm=0
	if (dev+data+norm) eq 0 then data=1	; Default is data.
	if data eq 1 then begin
	  typ = 'Data '
	  dmin = 0.	; Default min dist.
	endif
	if dev eq 1 then begin
	  typ = 'Device '
	  dmin = 1	; Default min dist.
	endif
	if norm eq 1 then begin
	  typ = 'Normalized '
	  dmin = 0.	; Default min dist.
	endif
	if keyword_set(data) and !x.s(1) eq 0 then begin
	  print,' Data coordinate system not established.'
	  return
	endif
	if n_elements(step) ne 0 then dmin=step		; Set min step size.
 
	;-------  Set up point display widget  --------
	top = widget_base(/column,title=' ')
	id = widget_text(top,xsize=35,ysize=5,$
	  val=['Draw a curve using the mouse.',' ',$
	  'Left button --- new segment.',$
	  'Middle button --- delete segment.',$
	  'Right button --- quit curve.'])
	idcnt = widget_label(top,val='0 points',/dynamic)
	id = widget_label(top,val=typ+'coordinates of cursor')
	idc = widget_label(top,val=' ',/dynamic)
	idxy = widget_list(top,xsize=20,ysize=20)
	widget_control, top, /real
 
	;--------  Initialize values  -----------
	n = 0
	xa = fltarr(1)		; Curve X coordinates.
	ya = fltarr(1)		; Curve Y coordinates.
	ta = strarr(1)		; Display string.
	!mouse.button = 0
	!err = 0
	device, get_graph=graph_sv
	lx = -1.
	ly = -1.
	ltm = 0L		; Time in millisec.
 
	;--------   Main loop  ---------------
	while !mouse.button ne 4 do begin
	  cursor, x, y, data=data,dev=dev,norm=norm, /nowait
	  if (x eq lx) and (y eq ly) then begin
	    cursor, x, y, data=data,dev=dev,norm=norm, /change
	  endif
	  lx=x & ly=y
	  txt = string(x,y,form='(2f15.5)')
	  widget_control, idc, set_val=txt
 
	  ;------  Left button: add point  ---------
	  if !mouse.button eq 1 then begin
            if n eq 0 then begin
	      xa1=x & ya1=y				; First point.
	      rx=x & ry=y				; New RB pt.
	      device, set_graph=6			; XOR mode.
              plots,xa1,ya1,data=data,dev=dev,norm=norm,psym=4
	      device, set_graph=graph_sv		; entry mode.
	      xa(0) = x+2*dmin
            endif
	    ;-------  Avoid points too close in time  ---------
	    tm = !mouse.time
	    dtm = abs(ltm-tm)
	    if dtm gt 200 then begin
	      ltm = tm
	      ;-------  Avoid repeated points  --------
	      dx = x-xa(n>0)				; Find dist from last.
	      dy = y-ya(n>0)
	      dst = sqrt(dx^2+dy^2)			; Dist from last pt.
	      if dst gt dmin then begin			; Dist > min.
                n = n + 1				; Yes, add new point.
		;-----------------------------------------
		; Last plotted line was to rx,ry.  Cursor
		; point, x,y may have moved since then.
		; So save rx,ry as new point.
		;-----------------------------------------
                xa = [xa,rx]
                ya = [ya,ry]
	        ta = [ta,txt]
		if keyword_set(autocenter) then begin
		  swincenter, rx, ry, data=data,dev=dev,norm=norm ; Center pt.
		endif
	        widget_control, idxy, set_val=ta(1:*)	; Display points.
	        xcurve_pnts, idcnt, n
	      endif
	    endif
          endif
 
	  ;-------  Middle button: Drop point.  ---------
          if !mouse.button eq 2 then begin
            if n gt 0 then begin
              xplot,xa(n),rx,ya(n),ry, $		; Erase old rubber-band.
		data=data,dev=dev,norm=norm
              xplot,xa(n),xa((n-1)>1),ya(n),ya((n-1)>1), $	; Deleted line.
		data=data,dev=dev,norm=norm
              n = n - 1					; Drop point from list.
              xa = xa(0:n)
              ya = ya(0:n)
	      ta = ta(0:n)
              if n eq 0 then begin			; Deal with 1st pt.
	        device, set_graph=6			  ; XOR
                plots,xa1,ya1,data=data,dev=dev,norm=norm,psym=4
		empty
	        device, set_graph=graph_sv		  ; Entry graphics mode.
              endif else begin				; New RB.
                xplot,xa(n), x,ya(n), y, $		  ; Plot new RB.
		  data=data,dev=dev,norm=norm
	      endelse
	      rx=x & ry=y				; New RB pt.
	      if keyword_set(autocenter) then begin
	        swincenter, rx, ry, data=data,dev=dev,norm=norm ; Center pt.
	      endif
	      if n gt 0 then widget_control, idxy, set_val=ta(1:*) $
		else widget_control, idxy, set_val=''
	      xcurve_pnts, idcnt, n
	      wait,.1
            endif
          endif
 
	  ;----  Do rubber banding if anchor pt available (and not drop) -----
	  if (n gt 0) and (!mouse.button ne 2) then begin
	    if n_elements(rx) eq 0 then begin		; Force RB pt defined.
	      rx=xa(n)  &  ry=ya(n)
	    endif
            xplot,xa(n),rx,ya(n),ry, $ 			; Erase old RB.
	      data=data,dev=dev,norm=norm
            xplot,xa(n), x,ya(n), y, $			; Plot new RB.
	      data=data,dev=dev,norm=norm
	    rx=x  &  ry=y				; Remember new.
	  endif
 
          ;----------  Update mag window if any  --------------
          if mag0 ne 0 then begin
	    tmp=convert_coord(x,y,dev=dev,norm=norm,dat=data,/to_dev)
	    xdv=tmp(0)  &  ydv=tmp(1)
            t=tvrd2(xdv-rdsz2,ydv-rdsz2,rdsz,rdsz,tr=tvtr)  ; Read patch.
	    if vflag eq 0 then begin
              t = rebin(t,wsz,wsz,/samp)            ; Magnify.
	    endif else begin
              t = rebin(t,wsz,wsz,3,/samp)          ; Magnify.
	    endelse
            it = t(xmid,ymid)                       ; Mid pixel.
            if lum(it) lt 128 then cc=bright $
               else cc=dark                         ; Outline color.
            t(xmid:xmid+mag,ymid)=cc                ; Draw mid pixel outline.
            t(xmid:xmid+mag,ymid+mag)=cc
            t(xmid,ymid:ymid+mag)=cc
            t(xmid+mag,ymid:ymid+mag)=cc
            wset, win2                              ; Set to mag window.
            tv, t, tr=tvtr                          ; Display mag view.
            wset, win1                              ; Set back to original win.
          endif
 
	endwhile
 
	;---------  Finish up  ---------
	if mag0 ne 0 then wdelete, win2		; Delete any mag window.
	widget_control, top, /dest		; Delete text widget.
	if n_elements(xa) lt 2 then return	; No points.
	xplot,xa(n),rx,ya(n),ry, $ 		; Erase old RB.
	  data=data,dev=dev,norm=norm
        xa = xa(1:*)				; Drop seed value.
        ya = ya(1:*)
 
	return
	end
