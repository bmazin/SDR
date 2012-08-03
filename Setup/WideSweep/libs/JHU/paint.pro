;-------------------------------------------------------------
;+
; NAME:
;       PAINT
; PURPOSE:
;       Paint on an image.
; CATEGORY:
; CALLING SEQUENCE:
;       paint
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         MAG=m  Viewing window magnification (def=10).
;         SIZE=s Mag window approx. size in pixels (def=200).
;         BOUND=b  Pixel value of boundary for flood fill command.
;           May be a scalar or array of values.  If not given
;           the connected region with same pixel value as the
;           starting point is filled.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Apr 12
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro paint, help=hlp, mag=mag, size=sz, boundary=bound
 
	if keyword_set(hlp) then begin
	  print,' Paint on an image.'
	  print,' paint'
	  print,'   No arguments.'
	  print,' Keywords:'
	  print,'   MAG=m  Viewing window magnification (def=10).'
	  print,'   SIZE=s Mag window approx. size in pixels (def=200).'
	  print,'   BOUND=b  Pixel value of boundary for flood fill command.'
	  print,'     May be a scalar or array of values.  If not given'
	  print,'     the connected region with same pixel value as the'
	  print,'     starting point is filled.'
	  return
	endif
 
	;------  Handle current window  ---------
	win1 = !d.window			; win1 = Current window.
	if win1 lt 0 then begin
	  print,' No window is active.'
	  return
	endif
	save = tvrd()				; Make backup.
	save0 = save				; Original image.
	work = save				; Working array.
	xwrk=0 & ywrk=0				; Working region LL corner.
	sze = size(save0)			; Full image size.
	nx=sze(1) & ny=sze(2)
	idx=nx & idy=ny				; Working region size.
        small_flag = 0          		; Any small area fills?
 
	;-------  Handle mag window  -------
	if n_elements(mag) eq 0 then mag = 10	; Def mag.
	if n_elements(sz) eq 0 then sz = 200	; Def mag win size.
	s0 = round(sz)				; Rounded size.
	m = round(mag)				; Rounded mag.
	r = round(float(s0)/m)			; Read area size.
	r2 = r/2				; Offset.
	xm=r2*m & ym=r2*m			; Mid mag win.
	s = r*m					; True mag win size.
	window, /free, xs=s0, ys=s0, title='Mag: '+strtrim(m,2)
	win2 = !d.window			; win2 = mag window.
 
	;-------  Palette window  ----------
	window, /free, xs=622, ys=100, title='Paint Colors'
	win3 = !d.window			; win3 = palette window.
	tv, rebin(bindgen(256),512,100)
 
	;------  Look at colors  ----------
        tvlct,/get,r_curr,g_curr,b_curr
        ;-----  4 lines lifted from ct_luminance (userslib)  ----
        lum= (.3 * r_curr) + (.59 * g_curr) + (.11 * b_curr)
        bright = max(lum, min=dark)
        c1 = where(lum eq bright)
        c0 = where(lum eq dark)
        c1=c1(0) & c0=c0(0)
;	lum = ct_luminance(dark=c0, bright=c1)
	clr = c1<(!d.table_size-1)
	wset, win3
	tv,bytarr(100,100)+clr,522,0
	ctxt = c0
	if lum(clr) lt 128 then ctxt = c1
	xyouts,567,50,/dev,strtrim(fix(clr),2),chars=2,color=ctxt,align=.5
 
	dopt = 'Q'
 
	repeat begin
 
	;-------  Options  ----------------
	val =  ['Q','H','P','D','FF','FFS','UFF','RC','PF',$
		'PC','IC','S','R','R0']
	k = xoption(['Quit','Help','Paint pixels','Draw lines',$
		'Fill a region',$
		'Fill a small region',$
		'Undo last Fill',$
		'Replace a color',$
		'Draw a filled polygon',$
	        'Pick palette color',$
		'Pick image color','Save current state',$
		'Restore last saved state',$
		'Restore original image'], $
		val=val, title='Paint options', def=dopt)
 
	;---------  Options loop  -------------
	case k of
	;--------------------------------------------
'Q':	begin		; Quit
	  wdelete, win2
	  wdelete, win3
	end
	;--------------------------------------------
'H':	begin		; Help
	  xhelp,title='Paint help',$
	    ['1. Select an option from options menu.',' ',$
	     '2. To exit option press right button.']
	end
	;--------------------------------------------
'RC':	begin		; Help
	  xhelp,/nowait,wid=wid,title='Replace a color',$
	    ['Click on an image color to replace',$
	     'by the current color.']
	  wset, win1
	  wshow
	  crossi,ix,iy,/dev,/dia,/mag,menu=['Replace color','Cancel'],$
	    exit=ex, color=-2
	  if ex eq 0 then begin
	    t = tvrd()
	    in = t(ix,iy)
	    w = where(t eq in, cnt)
	    if cnt gt 0 then t(w)=clr
	    tv,t
	  endif
	  if wid ne 0 then widget_control,wid,/dest
	end
	;--------------------------------------------
'FF':	begin		; Flood Fill
	  xhelp,title='Flood Fill',$
	    ['1. Select an image point using cursor.'], $
	    /nowait,wid=wid
	  wset, win1
	  wshow
	  crossi,ix,iy,/dev,/dia,/mag,menu=['Fill','Cancel'],exit=ex,$
	    def=0, color=-2
	  if ex eq 0 then begin
	    widget_control,wid,/dest
	    if n_elements(bound) eq 0 then begin
	      xhelp, ['Flood filling region . . .'], $
	        /nowait,wid=wid
	      seedfillr, work, seed=[ix-xwrk,iy-ywrk],fill=clr
	      widget_control,wid,/dest
	      wid = 0
	    endif else begin
	      xhelp, ['Flood filling region . . .'], $
	        /nowait,wid=wid
	      seedfill, work, seed=[ix-xwrk,iy-ywrk],fill=clr, bound=bound
	      widget_control,wid,/dest
	      wid = 0
	    endelse
	    tv,work,0,0
	    dopt = 'FF'
	  endif
	  if wid ne 0 then widget_control,wid,/dest
	end
	;--------------------------------------------
'P':	begin		; Paint
	  xhelp, title='Paint help',$
	     ['1. To paint hold left button.  Current paint',$
	     '   color is shown in the Paint colors labeled patch.',$
	     '2. To unpaint hold middle button.',$
	     '3. To exit paint mode press right button.'],/nowait,wid=wid
	  wshow, win1
	  wshow, win2
	  !mouse.button = 0
	  ixl=-2 & iyl=-2
	  while !mouse.button lt 4 do begin
	    wset, win1
	    cursor, ix,iy,/dev,/nowait
	    if (ix eq ixl) and (iy eq iyl) then begin
	      cursor, ix,iy,/dev,/change
	    endif
	    ixl=ix & iyl=iy
	    if !mouse.button eq 1 then tv,[clr],ix,iy
	    if !mouse.button eq 2 then tv,[save(ix,iy)],ix,iy
	    t = tvrd2(ix-r2,iy-r2,r,r)
	    t = rebin(t,s,s,/samp)
	    it = t(xm,ym)
	    if lum(it) lt 128 then cc=c1 else cc=c0
	    t(xm:xm+m,ym)=cc
	    t(xm:xm+m,ym+m)=cc
	    t(xm,ym:ym+m)=cc
	    t(xm+m,ym:ym+m)=cc
	    wset, win2
	    tv, t
	  endwhile
	  wset, win1
	  work = tvrd()
	  widget_control,wid,/dest
	end
	;--------------------------------------------
'D':	begin		; Draw
	  xhelp, title='Draw help',$
	     ['1. To draw a line press left button at next point.  Current',$
	      '   draw color is shown in the Paint Colors labeled patch.',$
	      '2. To undraw press middle button once for each line to undraw.',$
	      '3. To exit draw mode press right button.'],/nowait,wid=wid
	  wshow, win1
	  wshow, win2
	  !mouse.button = 0
	  ixl=-2 & iyl=-2
	  pcnt = 0
	  xx=intarr(1) &  yy=intarr(1)
	  while !mouse.button lt 4 do begin
	    wset, win1
	    cursor, ix,iy,/dev,/nowait
	    if (ix eq ixl) and (iy eq iyl) then begin
	      cursor, ix,iy,/dev,/change
	    endif
	    ixl=ix & iyl=iy
	    ;--------  Draw  --------------
	    if !mouse.button eq 1 then begin
	      xx=[xx,ix] & yy=[yy,iy] & pcnt=pcnt+1
	      if pcnt eq 1 then begin
		tv,[clr],ix,iy
	      endif else begin
		linepts, xx(pcnt-1),yy(pcnt-1),xx(pcnt),yy(pcnt),x,y
		for i=0,n_elements(x)-1 do tv,[clr],x(i),y(i)
	      endelse
	    endif
	    ;--------  Undraw  --------------
	    if !mouse.button eq 2 then begin
	      if pcnt eq 1 then begin 
		tv,[save(xx(1),yy(1))],xx(1),yy(1)
		xx=xx(0) & yy=yy(0) & pcnt=0
	      endif
	      if pcnt gt 1 then begin
		linepts, xx(pcnt-1),yy(pcnt-1),xx(pcnt),yy(pcnt),x,y
		for i=0,n_elements(x)-1 do tv,[save(x(i),y(i))],x(i),y(i)
		pcnt=pcnt-1 & xx=xx(0:pcnt) & yy=yy(0:pcnt)
	      endif
	    endif
	    t = tvrd2(ix-r2,iy-r2,r,r)
	    t = rebin(t,s,s,/samp)
	    it = t(xm,ym)
	    if lum(it) lt 128 then cc=c1 else cc=c0
	    t(xm:xm+m,ym)=cc
	    t(xm:xm+m,ym+m)=cc
	    t(xm,ym:ym+m)=cc
	    t(xm+m,ym:ym+m)=cc
	    wset, win2
	    tv, t
	  endwhile
	  wset, win1
	  work = tvrd()
	  widget_control,wid,/dest
	end
	;--------------------------------------------
'PF':	begin		; Polygon Fill
	  xhelp, title='Polygon Fill help',$
	     ['1. Polygons are made by drawing lines.  Polygon will be',$
	      '   closed automatically and filled on exit.  To abort',$
	      '   polygon fill erase entire polygon before exiting.',$
	      '2. To draw a line press left button at next point.  Current',$
	      '   draw color is shown in the Paint Colors labeled patch.',$
	      '3. To undraw press middle button once for each line to undraw.',$
	      '4. To exit draw mode press right button.'],/nowait,wid=wid
	  wshow, win1
	  wshow, win2
	  !mouse.button = 0
	  ixl=-2 & iyl=-2
	  pcnt = 0
	  xx=intarr(1) &  yy=intarr(1)
	  while !mouse.button lt 4 do begin
	    wset, win1
	    cursor, ix,iy,/dev,/nowait
	    if (ix eq ixl) and (iy eq iyl) then begin
	      cursor, ix,iy,/dev,/change
	    endif
	    ixl=ix & iyl=iy
	    ;--------  Draw  --------------
	    if !mouse.button eq 1 then begin
	      xx=[xx,ix] & yy=[yy,iy] & pcnt=pcnt+1
	      if pcnt eq 1 then begin
		tv,[clr],ix,iy
	      endif else begin
		linepts, xx(pcnt-1),yy(pcnt-1),xx(pcnt),yy(pcnt),x,y
		for i=0,n_elements(x)-1 do tv,[clr],x(i),y(i)
	      endelse
	    endif
	    ;--------  Undraw  --------------
	    if !mouse.button eq 2 then begin
	      if pcnt eq 1 then begin 
		tv,[save(xx(1),yy(1))],xx(1),yy(1)
		xx=xx(0) & yy=yy(0) & pcnt=0
	      endif
	      if pcnt gt 1 then begin
		linepts, xx(pcnt-1),yy(pcnt-1),xx(pcnt),yy(pcnt),x,y
		for i=0,n_elements(x)-1 do tv,[save(x(i),y(i))],x(i),y(i)
		pcnt=pcnt-1 & xx=xx(0:pcnt) & yy=yy(0:pcnt)
	      endif
	    endif
	    t = tvrd2(ix-r2,iy-r2,r,r)
	    t = rebin(t,s,s,/samp)
	    it = t(xm,ym)
	    if lum(it) lt 128 then cc=c1 else cc=c0
	    t(xm:xm+m,ym)=cc
	    t(xm:xm+m,ym+m)=cc
	    t(xm,ym:ym+m)=cc
	    t(xm+m,ym:ym+m)=cc
	    wset, win2
	    tv, t
	  endwhile
	  wset, win1
	  if pcnt ge 3 then polyfill,xx(1:pcnt),yy(1:pcnt),/dev,color=clr
	  wset, win1
	  work = tvrd()
	  widget_control,wid,/dest
	end
	;--------------------------------------------
'PC':	begin		; Pick palette color
	  xhelp, title='Pick palette color help',$
	     ['Use mouse in Paint Colors window to point to desired new',$
	      'paint color.  Press any mouse button to select it.'],$
	     /nowait,wid=wid
	  wset, win3
	  wshow
	  !mouse.button = 0
	  ixl=2*clr & iyl=50
	  tvcrs, ixl, iyl
	  while !mouse.button eq 0 do begin
	    cursor, ix,iy,/dev,/nowait
	    if (ix eq ixl) and (iy eq iyl) then begin
	      cursor, ix,iy,/dev,/change
	    endif
	    ixl=ix & iyl=iy
	    if (ix ge 0) and (iy ge 0) then begin
	      clr = (tvrd(ix,iy,1,1))(0)
	      tv,bytarr(100,100)+clr,522,0
	      ctxt = c0
	      if lum(clr) lt 128 then ctxt = c1
	      xyouts,567,50,/dev,strtrim(fix(clr),2), $
		chars=2,color=ctxt,align=.5
	    endif
	  endwhile
	  widget_control,wid,/dest
	end
	;--------------------------------------------
'IC':	begin		; Pick image color
	  xhelp, title='Pick image color help',$
	     ['Use mouse in image window to point to desired new',$
	      'paint color.  Press any mouse button to select it.'],$
	     /nowait,wid=wid
	  wshow, win1
	  wshow, win2
	  wset, win1
	  crossi,ix,iy,/dev,/mag,color=-2,/nostatus
	  it = (tvrd(ix,iy,1,1))(0)
	  clr = it
	  wset, win3
	  tv,bytarr(100,100)+clr,522,0
	  ctxt = c0
	  if lum(clr) lt 128 then ctxt = c1
	  xyouts,567,50,/dev,strtrim(fix(clr),2),chars=2,color=ctxt,align=.5
	  widget_control,wid,/dest
	end
	;--------------------------------------------
'S':	begin		; Save current state
	  wset, win1
	  save = tvrd()
	  work = save
	  xmess, 'Current image saved',/nowait, wid=wid
	  wait,1
	  widget_control, wid, /dest
	end
	;--------------------------------------------
'R':	begin		; Restore last saved state
	  wset, win1
	  work = save
	  tv,work
	  xmess, 'Last image restored',/nowait, wid=wid
	  wait,1
	  widget_control, wid, /dest
	end
	;--------------------------------------------
'R0':	begin		; Restore original image.
	  wset, win1
	  work = save0
	  tv,work
	  xmess, 'Original image restored',/nowait, wid=wid
	  wait,1
	  widget_control, wid, /dest
	end
	;--------------------------------------------
else:
	endcase
 
	endrep until k eq 'Q'
 
	wdelete, win2
	wdelete, win3
 
	return
	end
