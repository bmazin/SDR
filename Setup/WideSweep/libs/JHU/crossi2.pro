;-------------------------------------------------------------
;+
; NAME:
;       CROSSI2
; PURPOSE:
;       Interactive cross-hair cursor on screen or plot.
; CATEGORY:
; CALLING SEQUENCE:
;       crossi, [x, y]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA   Causes data coordinates to be used (default).
;         /DEVICE Causes window device coordinates to be used.
;         /NORMAL Causes normalized coordinates to be used.
;         /ORDER  Reverse device y coordinate (0 at window top).
;         STATUS_PRO=pro  Name of optional status update procedure.
;         /DETAILS for more info on using STATUS_PRO.
;         COLOR=c Set color of line (ignored for /XOR).
;           Use -2 for dotted line.
;         LINESTYLE=s Line style.
;         MAG=m   Magnification for an optional magnified window.
;           Setting MAG turns window on. /MAG gives magnification 10.
;         SIZE=sz Mag window approx. size in pixels (def=200).
;         /XMODE  Means use XOR plot mode instead of tvrd mode.
;         /DIALOG Means give an exit dialog box.
;         MENU=m  A string array with exit dialog box options.
;           An option labeled Continue is always added. Def=Continue.
;         DEFAULT=def  Set exit menu default.
;         EXITCODE=x Returns exit code.  Always 0 unless a dialog
;           box is requested, then is selected exit option number.
;         BUTTON=b   Returned button code: 1=left, 2=middle, 4=right.
; OUTPUTS:
;       x = X coordinate of line.             in, out
;       y = Y coordinate of line.             in, out
; COMMON BLOCKS:
; NOTES:
;       Note: data coordinates are default.
;         X and Y may be set to starting position in entry.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Oct 6.
;	R. Sterner, 1998 Jan 15 --- Dropped the use of !d.n_colors.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
        pro crossi2, x, y, zdv, color=color, linestyle=linestyle, $ 
          help=hlp, exitcode=exitcode, $
          device=device, normal=norm, data=data, xmode=xmode,$
	  button=button, $
	  dialog=dialog,menu=menu,default=def, $
          mag=mag0, size=msize0, order=order, status_pro=statpro, $
	  details=details, out=out
 
        if keyword_set(hlp) then begin 
          print,' Interactive cross-hair cursor on screen or plot.' 
          print,' crossi, [x, y]' 
          print,'   x = X coordinate of line.             in, out' 
          print,'   y = Y coordinate of line.             in, out' 
          print,' Keywords:' 
          print,'   /DATA   Causes data coordinates to be used (default).'
          print,'   /DEVICE Causes window device coordinates to be used.'
          print,'   /NORMAL Causes normalized coordinates to be used.'
	  print,'   /ORDER  Reverse device y coordinate (0 at window top).'
	  print,'   STATUS_PRO=pro  Name of optional status update procedure.'
	  print,'   /DETAILS for more info on using STATUS_PRO.'
          print,'   COLOR=c Set color of line (ignored for /XOR).' 
	  print,'     Use -2 for dotted line.'
          print,'   LINESTYLE=s Line style.'
	  print,'   MAG=m   Magnification for an optional magnified window.'
	  print,'     Setting MAG turns window on. /MAG gives magnification 10.'
	  print,'   SIZE=sz Mag window approx. size in pixels (def=200).'
          print,'   /XMODE  Means use XOR plot mode instead of tvrd mode.'
          print,'   /DIALOG Means give an exit dialog box.'
          print,'   MENU=m  A string array with exit dialog box options.'
          print,'     An option labeled Continue is always added. Def=Continue.'
	  print,'   DEFAULT=def  Set exit menu default.'
          print,'   EXITCODE=x Returns exit code.  Always 0 unless a dialog' 
          print,'     box is requested, then is selected exit option number.'
	  print,'   BUTTON=b   Returned button code: 1=left, 2=middle, 4=right.'
          print,' Note: data coordinates are default.' 
          print,'   X and Y may be set to starting position in entry.' 
          return 
        endif 
  
	if keyword_set(details) then begin
	  print,' crossi2 may be customized by calling with a routine that'
	  print,' displays the cursor position.  This routine must be able'
	  print,' to set up (/INIT) and destroy (/TERM) the coordinate display'
	  print,' widget, and must operate on the current cursor device'
	  print,' coordinates (with 0,0 at lower left corner, not y reversed).'
	  print," Ex: status_pro='test_update'"
	  print,' The given procedure must have at least 3 modes:'
	  print,'   test_update,x,y,out=out   ; updates displayed coordinates.'
	  print,'     The keyword OUT must be allowed and may return values.'
	  print,'     OUT may be a structure containing coordinates.'
	  print,'   test_update,/init ; sets up display widget.'
 	  print,'   test_update,/term ; destroys display widget.'
	  print,' This technique allows any function of x and y to be'
	  print,' displayed.  For example, nongeoreferenced landsat'
	  print,' images may have coordinates displayed by converting'
	  print,' from device x,y to full scene samp,line to long,lat.'
	  print,' Must call crossi2 with /dev:'
	  print,"   crossi2,/dev,/mag,stat='landsat_crs_stat',out=out"
	  return
	endif
 
	;-------  Coordinate system  ---------
        if n_elements(device) eq 0 then device=0
        if n_elements(norm) eq 0 then norm=0
        if n_elements(data) eq 0 then data=0
        if (device+norm) eq 0 then data=1
        if (!x.s(1) eq 0) and $ 
           (not keyword_set(device)) and $
           (not keyword_set(norm)) then begin 
          print,' Error in crossi: data coordinates not yet established.' 
          print,'  Must make a plot before calling crossi or use /DEVICE
          print,'   or /NORMAL keyword.' 
          return 
        endif 
        if device  eq 1 then ctyp = 0              ; Coordinate flag.
        if norm eq 1 then ctyp = 1
        if data eq 1 then ctyp = 2
 
        ;---------  Set defaults  -------------
	if n_elements(x) eq 0 then begin
	  case ctyp of
0:	    begin
	      x = !d.x_size/2
	      y = !d.y_size/2
	    end
1:	    begin
	      x = .25
	      y = .25
	    end
2:	    begin
	      x = midv(!x.crange)
	      y = midv(!y.crange)
	      if !x.type eq 2 then begin
		x = !map.out(9)*!radeg
		y = !map.out(8)*!radeg
	      endif
	    end
	  endcase
	endif else begin
	  ;-----  Handle y reversal  --------
	  if (ctyp eq 0) and keyword_set(order) then y=(!d.y_size-1)-y
	endelse
        if n_elements(color) eq 0 then color=!p.color
        clr = color
        if n_elements(linestyle) eq 0 then linestyle=!p.linestyle
        if keyword_set(xmode) then begin
          device,get_graph=old,set_graph=6
          clr = 255
        endif
	stat = keyword_set(nostat) eq 0
        top = -1L
        if n_elements(st) ne 0 then top=st.top
        if n_elements(menu) eq 0 then menu = ['Exit']
        if n_elements(def) eq 0 then def = n_elements(menu)
        if n_elements(instr) eq 0 then instr = ['Press any button to exit.']
        if n_elements(xsize) eq 0 then begin
          xsize=12
          if strupcase(!version.os) eq 'MACOS' then xsize=6
        endif
        if n_elements(ysize) eq 0 then begin
          ysize=12
          if strupcase(!version.os) eq 'MACOS' then ysize=6
        endif
 
	;-------  Find brightest and darkest colors  --------------
	tvlct,/get,r_curr,g_curr,b_curr
	;-----  4 lines lifted from ct_luminance (userslib)  ----
        lum= (.3 * r_curr) + (.59 * g_curr) + (.11 * b_curr)
        bright = max(lum, min=dark)
        c1 = where(lum eq bright)
        c2 = where(lum eq dark)
        bright=c1(0) & dark=c2(0)
	;------- Setup for color = -2  ---------------
	if clr eq -2 then begin
	  hor2 = bright+((indgen(!d.x_size) mod 6) lt 3)*(dark-bright)
	  ver2 = bright+((transpose(indgen(!d.y_size)) mod 6) lt 3)*$
	    (dark-bright)
	endif
 
	;-------  Deal with mag window  --------------
	win1 = !d.window				; Current window.
	if n_elements(mag0) eq 0 then mag0=0		; Force defined.
	if (n_elements(msize0) ne 0) and (mag0 eq 0) then mag0=1
	if mag0 ne 0 then begin
	  if n_elements(msize0) eq 0 then msize0 = 200	; Def mag win size.
	  msize = round(msize0)				; Rounded size.
	  mag = round(mag0)				; Rounded mag.
	  if mag eq 1 then mag = 10			; Def is 10.
	  rdsz = round(float(msize)/mag)		; Read size.
	  rdsz2 = rdsz/2				; Offset.
	  xmid = rdsz2*mag				; Mag win midpoint.
	  ymid = rdsz2*mag
	  wsz = rdsz*mag				; True mag win size.
	endif
 
        ;------  Find ranges and start in device coordinates  ----
        if keyword_set(device) then begin           ;----  DEVICE  -----
          xxdv=[0,!d.x_size-1]                        ; Device range.
          yydv=[0,!d.y_size-1]
          if n_elements(x) eq 0 then x=!d.x_size/2
	  x = x>0<(!d.x_size-1)
          if n_elements(y) eq 0 then y=!d.y_size/2
	  y = y>0<(!d.y_size-1)
        endif else if keyword_set(norm) then begin  ;---  NORMAL  -----
          xxdv=[0,!d.x_size-1]                        ; Normal range.
          yydv=[0,!d.y_size-1]
          if n_elements(x) eq 0 then x=.5
	  x = x>0<1.
          if n_elements(y) eq 0 then y=.5
	  y = y>0<1.
        endif else begin
          if !x.type eq 2 then begin                ;----  MAPS  ------
            xxdv = [0,!d.x_size-1]
            yydv = [0,!d.y_size-1]
            if n_elements(x) eq 0 then x = !map.out(9)*!radeg
            if n_elements(y) eq 0 then y = !map.out(8)*!radeg
          endif else begin                          ;----  DATA  ------
            xx = [min(!x.crange), max(!x.crange)]   ; Data range in x. 
            if !x.type eq 1 then xx=10^xx           ; Handle log x axis. 
            yy = [min(!y.crange), max(!y.crange)]   ; Data range in y. 
            if !y.type eq 1 then yy=10^yy           ; Handle log y axis. 
            tmp = convert_coord(xx,yy,/to_dev)      ; Convert to device coord. 
            xxdv = tmp(0,0:1)                       ; Device coord. range. 
            yydv = tmp(1,0:1)
	    xxdv = xxdv(sort(xxdv))		    ; Allow for reversed axes.
	    yydv = yydv(sort(yydv))
            if n_elements(x) eq 0 then x = total(xx)/2.
	    x = x>xx(0)<xx(1)
            if n_elements(y) eq 0 then y = total(yy)/2.
	    y = y>yy(0)<yy(1)
	  endelse
        endelse
 
	tmp = convert_coord(x,y,dev=device,norm=norm,data=data,/to_dev)
	xdv = tmp(0)<xxdv(1)  & ydv = tmp(1)<yydv(1)
 
        ;--------  Handle starting line  ---------- 
        tvcrs, xdv, ydv                         ; Place cursor.
        if not keyword_set(xmode) then begin
	  tsx=tvrd(xdv,0,1,!d.y_size) ; 1st col.
	  tsy=tvrd(0,ydv,!d.x_size,1) ; 1st row.
	endif
	if clr eq -2 then begin	      ; Dotted lines.
	  tv,ver2,xdv,0
	  tv,hor2,0,ydv
	endif else begin	      ; Normal lines.
          plots, [xdv,xdv],yydv,color=clr,linestyle=linestyle,/dev 
          plots, xxdv,[ydv,ydv],color=clr,linestyle=linestyle,/dev 
	endelse
        xl = xdv                                ; Last column. 
        yl = ydv                                ; Last row. 
        !mouse.button = 0                       ; Clear button flag. 
	tmp=convert_coord(xdv,ydv,/dev,to_dev=device,to_norm=norm,to_dat=data)
	xx0=tmp(0)  &  yy0=tmp(1)
 
	if mag0 ne 0 then begin
	  window, /free, xs=msize, ys=msize, title='Mag: '+strtrim(mag,2)
	  win2 = !d.window		; Mag window.
	  wset,win1			; Set back to starting window.
	endif
 
	;--------  Initialize status routine  ----------
	if n_elements(statpro) ne 0 then call_procedure,statpro,/init
 
	;===========================================================
        ;-------  Cursor loop  -----------
	xcl = -2  & ycl = -2
        while !mouse.button eq 0 do begin 
          ;------  Get mouse input  ----------
          cursor, xdv, ydv, 0, /dev               ; Read cursor. 
          if ((xdv eq xcl) and (ydv eq ycl)) or $ ; Not moved, or
             ((xdv eq -1) and (ydv eq -1)) then $ ; moved out of window:
            cursor,xdv,ydv,2,/device              ; wait for a change.
          ;------  Erase old line  --------------
          xdv = xdv > xxdv(0) < xxdv(1)           ; Keep in bounds.
          ydv = ydv > yydv(0) < yydv(1)           ; Keep in bounds.
	  xcl = xdv  & ycl = ydv
          if not keyword_set(xmode) then begin
            tv, tsx, xl, 0                        ; Replace last column. 
            tv, tsy, 0, yl                        ; Replace last row. 
            tsx = tvrd(xdv,0,1,!d.y_size)         ; Read new column.
            tsy = tvrd(0,ydv,!d.x_size,1)         ; Read new row.
          endif else begin
            plots, [xl,xl],yydv,color=clr,linestyle=linestyle,/dev
            plots, xxdv,[yl,yl],color=clr,linestyle=linestyle,/dev
	    empty			          ; Flush graphics.
          endelse
          xl = xdv                                ; Last column. 
          yl = ydv                                ; Last column. 
	  ;----------  Update mag window if any  --------------
	  if mag0 ne 0 then begin
	    t=tvrd2(xdv-rdsz2,ydv-rdsz2,rdsz,rdsz)  ; Read patch.
	    t = rebin(t,wsz,wsz,/samp)		    ; Magnify.
	    it = t(xmid,ymid)			    ; Mid pixel.
	    if lum(it) lt 128 then cc=bright $
	       else cc=dark  			    ; Outline color.
	    t(xmid:xmid+mag,ymid)=cc		    ; Draw mid pixel outline.
	    t(xmid:xmid+mag,ymid+mag)=cc
	    t(xmid,ymid:ymid+mag)=cc
	    t(xmid+mag,ymid:ymid+mag)=cc
	    win = win2
	    if n_elements(st) ne 0 then win=st.win2
	    wset, win				    ; Set to mag window.
	    tv, t				    ; Display mag view.
	    wset, win1				    ; Set back to original win.
	  endif
 
	  ;----------  Draw new cross-hairs  -----------------------
	  if clr eq -2 then begin
	    tv,ver2,xdv,0
	    tv,hor2,0,ydv
	  endif else begin
            plots, [xdv,xdv],yydv,color=clr,linestyle=linestyle,/dev 
            plots, xxdv,[ydv,ydv],color=clr,linestyle=linestyle,/dev 
	  endelse
	  empty				          ; Flush graphics.
	  ;-------  Update status routine  ----------
	  if n_elements(statpro) ne 0 then $
	    call_procedure,statpro,xdv,ydv,out=out
          ;-------  Handle button press  ----------
          if !mouse.button ne 0 then begin
            button = !mouse.button
            if keyword_set(dialog) then begin
              exitcode = xoption([menu,'Continue'],def=def)
              if exitcode eq n_elements(menu) then begin
                !mouse.button = 0
                tvcrs, xdv, ydv
              endif
            endif else begin
              exitcode = 0
            endelse
          endif
        endwhile 
	;===========================================================
 
	;--------  Erase last line  --------
        if keyword_set(xmode) then begin
          plots, [xdv,xdv],yydv,color=clr,linestyle=linestyle,/dev 
          plots, xxdv,[ydv,ydv],color=clr,linestyle=linestyle,/dev 
	  device,set_graph=old
	endif else begin
          tv, tsx, xl, 0                     ; Replace last column. 
          tv, tsy, 0, yl                     ; Replace last row.. 
	endelse
 
	;--------  return correct coordinate  --------
	tmp=convert_coord(xdv,ydv,/dev,to_dev=device,to_norm=norm,to_dat=data)
	x = tmp(0)
        if keyword_set(js) then x = x + jsoff
	y = tmp(1)
	;-----  Handle y reversal  --------
	if (ctyp eq 0) and keyword_set(order) then y=(!d.y_size-1)-y
 
	;-------  Remove mag window  --------------
	if not keyword_set(keep) then begin
	  if mag0 ne 0 then begin
	    win = win2
	    if n_elements(st) ne 0 then win=st.win2
	    wdelete, win
	  endif
	endif
 
	;-------  Terminate status routine  --------------
	if n_elements(statpro) ne 0 then call_procedure,statpro,/term
 
        return
        end 
