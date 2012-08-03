;-------------------------------------------------------------
;+
; NAME:
;       CROSSI
; PURPOSE:
;       Interactive cross-hair cursor on screen or plot.
; CATEGORY:
; CALLING SEQUENCE:
;       crossi, [x, y, z]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA   Causes data coordinates to be used (default).
;         /DEVICE Causes window device coordinates to be used.
;         /NORMAL Causes normalized coordinates to be used.
;         /ORDER  Reverse device y coordinate (0 at window top).
;         /PIXEL  Show pixel value: R G B.
;         /HSV    Use with /PIXEL to list pixel value as H S V.
;         ARRAY=arr Give a data array same size and shape as image.
;           If given array values will be listed in display widget.
;         IZOOM=iz Display data values. iz is a structure:
;            iz = {x:x, y:y, z:z} where x and y are arrays of
;            x and y coordinates, and z is the data array.  The
;            sizes of x, y, and z must match. Very similar to izoom.
;         COLOR=c Set color of line (ignored for /XOR).
;           Use -2 for dotted line.
;         LINESTYLE=s Line style.
;         MAG=m   Magnification for an optional magnified window.
;           Setting MAG turns window on. /MAG gives magnification 10.
;         SIZE=sz Mag window approx. size in pixels (def=200).
;         XFORMAT=xfn  These keywords are given names of functions
;         YFORMAT=yfn  that accept the numeric value of x or y
;           and return a corresponding string which is displayed
;           in place of the actual value.  For example, Julian
;           days could be displayed as a date with jd2date.
;         XSIZE=xs, YSIZE=ys  Coordinate display widths.
;         /JS  Means X axis is time in Julian seconds. Example:
;           x=maken(-2e8,-1.9e8,200) & y=maken(20,30,200)
;           z=bytscl(makez(200,200))
;           izoom,x,y,z,/js
;           crossi,/js
;         /NOSTATUS   Inhibits status display widget.
;         SETSTAT=st  May use the same status display widget on
;           each call to crossi (stays in same position).
;           On first call: the status widget structure is returned.
;           Following calls: send st.  Must use with /KEEP.
;           To delete status display widget after last box1 call:
;             widget_control,st.top,/dest (or drop /KEEP)
;         /KEEP   Do not delete status widget or mag window on exit.
;         /XMODE  Means use XOR plot mode instead of tvrd mode.
;         XYPRO=xypro Name of optional procedure that accepts the
;           X,Y values and does something (like translate a position
;           into a name).  Must do any display itself.  May design
;           to be initialized before calling crossi.
;         INSTRUCTIONS=t  String array with exit instructions.
;           Default: Press any button to exit.
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
;       z = optionally returned pixel value.  out
;         Only if /PIXEL is specified.
; COMMON BLOCKS:
;       js_com
; NOTES:
;       Note: data coordinates are default.
;         X and Y may be set to starting position in entry.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 May 16
;       R. Sterner, 1994 May 19 --- Added mag window.
;       R. Sterner, 1995 May 12 --- Added exit menu default.
;       R. Sterner, 1995 Jun 30 --- Added /ORDER.
;       R. Sterner, 1995 Oct 17 --- Added /PIXEL and RGB display.
;       R. Sterner, 1995 Nov 30 --- Added color=-2 option.
;       R. Sterner, 1998 Jan 15 --- Dropped the use of !d.n_colors.
;       R. Sterner, 1999 Oct 05 --- Upgraded for true color.
;       R. Sterner, 1999 Dec 07 --- Fixed /PIXEL for 24-bit color & mag bug.
;       R. Sterner, 2001 Jan 12 --- Fixed for maps.
;       R. Sterner, 2002 Sep 05 --- Added data array option.
;       R. Sterner, 2003 May 16 --- Added izoom option.
;       R. Sterner, 2003 Oct 09 --- Fixed startup non-erased line (rounded).
;       R. Sterner, 2003 Oct 09 --- Added XYPRO.
;       R. Sterner, 2004 Jan 13 --- Added /HSV.
;       R. Sterner, 2004 May 17 --- Fixed XOR mode for mag window.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
        pro crossi, x, y, zdv, color=color, linestyle=linestyle, $ 
          help=hlp, exitcode=exitcode, nostatus=nostat, nooptions=noop, $
          device=device, normal=norm, data=data, xmode=xmode,$
	  setstat=st, keep=keep, xformat=xfn, yformat=yfn, button=button, $
	  xsize=xsize, ysize=ysize, dialog=dialog,menu=menu,default=def, $
          instructions=instr, js=js, mag=mag0, size=msize0, order=order, $
	  pixel=pixel, hsv=hsv, array=array, izoom=iz, xypro=xypro
 
	common js_com, jsoff
  
        if keyword_set(hlp) then begin 
          print,' Interactive cross-hair cursor on screen or plot.' 
          print,' crossi, [x, y, z]' 
          print,'   x = X coordinate of line.             in, out' 
          print,'   y = Y coordinate of line.             in, out' 
	  print,'   z = optionally returned pixel value.  out'
	  print,'     Only if /PIXEL is specified.'
          print,' Keywords:' 
          print,'   /DATA   Causes data coordinates to be used (default).'
          print,'   /DEVICE Causes window device coordinates to be used.'
          print,'   /NORMAL Causes normalized coordinates to be used.'
	  print,'   /ORDER  Reverse device y coordinate (0 at window top).'
	  print,'   /PIXEL  Show pixel value: R G B.'
	  print,'   /HSV    Use with /PIXEL to list pixel value as H S V.'
	  print,'   ARRAY=arr Give a data array same size and shape as image.'
	  print,'     If given array values will be listed in display widget.'
	  print,'   IZOOM=iz Display data values. iz is a structure:'
	  print,'      iz = {x:x, y:y, z:z} where x and y are arrays of'
	  print,'      x and y coordinates, and z is the data array.  The'
	  print,'      sizes of x, y, and z must match. Very similar to izoom.'
          print,'   COLOR=c Set color of line (ignored for /XOR).' 
	  print,'     Use -2 for dotted line.'
          print,'   LINESTYLE=s Line style.'
	  print,'   MAG=m   Magnification for an optional magnified window.'
	  print,'     Setting MAG turns window on. /MAG gives magnification 10.'
	  print,'   SIZE=sz Mag window approx. size in pixels (def=200).'
	  print,'   XFORMAT=xfn  These keywords are given names of functions'
	  print,'   YFORMAT=yfn  that accept the numeric value of x or y'
	  print,'     and return a corresponding string which is displayed'
	  print,'     in place of the actual value.  For example, Julian'
	  print,'     days could be displayed as a date with jd2date.'
          print,'   XSIZE=xs, YSIZE=ys  Coordinate display widths.'
          print,'   /JS  Means X axis is time in Julian seconds. Example:'
	  print,'     x=maken(-2e8,-1.9e8,200) & y=maken(20,30,200)'
	  print,'     z=bytscl(makez(200,200))'
	  print,'     izoom,x,y,z,/js'
	  print,"     crossi,/js"
	  print,'   /NOSTATUS   Inhibits status display widget.'
	  print,'   SETSTAT=st  May use the same status display widget on'
	  print,'     each call to crossi (stays in same position).'
	  print,'     On first call: the status widget structure is returned.'
	  print,'     Following calls: send st.  Must use with /KEEP.'
	  print,'     To delete status display widget after last box1 call:'
	  print,'       widget_control,st.top,/dest (or drop /KEEP)'
	  print,'   /KEEP   Do not delete status widget or mag window on exit.'
          print,'   /XMODE  Means use XOR plot mode instead of tvrd mode.'
	  print,'   XYPRO=xypro Name of optional procedure that accepts the'
	  print,'     X,Y values and does something (like translate a position'
	  print,'     into a name).  Must do any display itself.  May design'
	  print,'     to be initialized before calling crossi.'
          print,'   INSTRUCTIONS=t  String array with exit instructions.'
          print,'     Default: Press any button to exit.'
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
 
        ;---------------------------------------------------------
        ;  Deal with True Color
        ;  If not PseudoColor then assume using true color or
        ;  something close.  It turns out that using true=3 on
        ;  tv and tvrd is harmless for 8-bit displays.  The only
        ;  step needing changed is to reload the image line using
        ;  the standard BW color table, then restore original table.
        ;  The original table is read once at start.
        ;---------------------------------------------------------
        device, get_visual_name=vis             ; Get visual type.
        vflag = vis ne 'PseudoColor'            ; 0 if PseudoColor.
        tvtr = 0
        if vflag eq 1 then tvtr=3               ; True color flag.
        tvlct,/get,rr0,gg0,bb0                  ; Get color table.
        ii0 = bindgen(256)                      ; B&W table.
 
        ;-------  If /JS make sure jsoff defined  ----------
        if keyword_set(js) then begin
          if n_elements(jsoff) eq 0 then begin
            print,' Error in crossi: cannot use /JS until a time series'
            print,'   plot has been made (by izoom,/js,... or jsplot).'
            bell
            return
          endif
          if n_elements(xsize) eq 0 then xsize=25
          if n_elements(xfn) eq 0 then xfn='dt_tm_fromjs'
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
          print,'  Must make a plot before calling crossi or use /DEVICE'
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
2:	    begin				; Data coord.
	      if !x.type eq 3 then begin	; Map.
	        if n_elements(x) eq 0 then x=(!map.ll_box(1)+!map.ll_box(3))/2.
	        if n_elements(y) eq 0 then y=(!map.ll_box(0)+!map.ll_box(2))/2.
	      endif else begin
	        x = midv(!x.crange)
	        y = midv(!y.crange)
	      endelse
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
	  if vflag eq 1 then clr=tarclr(255,255,255) else clr=255
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
	;-------  Deal with data array  ---------------
	arrflag = 0
	if n_elements(array) ne 0 then begin
	  if ctyp ne 0 then begin
	    print,' Error in crossi: ARRAY=arr was used.  Must use'
	    print,'   /DEVICE coordinates only in this case.'
	    return
	  endif
	  sz = size(array)
	  if sz(0) ne 2 then begin
	    print,' Error in crossi: ARRAY=arr was used. Array must be 2-D.'
	    return
	  endif
	  if (sz(1) ne !d.x_size) or (sz(2) ne !d.y_size) then begin
	    print,' Error in crossi: ARRAY=arr was used. Array size must'
	    print,'   match current screen window: '+strtrim(!d.x_size,2)+$
	      ' X '+strtrim(!d.y_size,2)
	    return
	  endif
	  arrflag = 1
	endif
	;------  Deal with izoom data structure  ---------
	izflag = 0
	if n_elements(iz) ne 0 then begin
	  if ctyp ne 2 then begin
	    print,' Error in crossi: IZOOM=iz was used.  Must use'
	    print,'   /DATA coordinates only in this case.'
	    return
	  endif
	  t = tag_names(iz)
	  if min([where(t eq 'X'),where(t eq 'Y'),where(t eq 'Z')]) $
	    lt 0 then begin
		print,' Error in crossi: IZOOM=iz was used.  iz must be a'
	        print,' a structure with tags x, y, and z.'
		return
	  endif
	  nx = n_elements(iz.x)
	  ny = n_elements(iz.y)
	  s = size(iz.z,/dim)
	  if (nx ne s(0)) or (ny ne s(1)) then begin
	    print,' Error in crossi: IZOOM=iz was used.  Sizes of x and y'
	    print,'   in structure iz must match size of z.'
	    return
	  endif
	  izflag = 1
	  izxmn = min(iz.x, max=izxmx)	; Find range of x and y arrays.
	  izymn = min(iz.y, max=izymx)
	endif
 
	;-------  Find brightest and darkest colors  --------------
	tvlct,/get,r_curr,g_curr,b_curr
	;-----  4 lines lifted from ct_luminance (userslib)  ----
        lum = (.3 * r_curr) + (.59 * g_curr) + (.11 * b_curr)
	bright = tarclr(255,255,255)
	dark = tarclr(0,0,0)
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
          if !x.type eq 3 then begin                ;----  MAPS  ------
            xxdv = [0,!d.x_size-1]
            yydv = [0,!d.y_size-1]
	    if n_elements(x) eq 0 then x=(!map.ll_box(1)+!map.ll_box(3))/2.
	    if n_elements(y) eq 0 then y=(!map.ll_box(0)+!map.ll_box(2))/2.
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
	tmp = round(tmp)			; RES 2003 Oct 09.
	xdv = tmp(0)<xxdv(1)  & ydv = tmp(1)<yydv(1)
 
        ;--------  Handle starting line  ---------- 
        tvcrs, xdv, ydv                         ; Place cursor.
        if not keyword_set(xmode) then begin
	  tsx=tvrd(xdv,0,1,!d.y_size,true=tvtr) ; 1st col.
	  tsy=tvrd(0,ydv,!d.x_size,1,true=tvtr) ; 1st row.
	endif
	if clr eq -2 then begin	      		; Dotted lines.
	  tv,ver2,xdv,0
	  tv,hor2,0,ydv
	endif else begin	      		; Normal lines.
          plots, [xdv,xdv],yydv,color=clr,linestyle=linestyle,/dev 
          plots, xxdv,[ydv,ydv],color=clr,linestyle=linestyle,/dev 
	endelse
        xl = xdv                                ; Last column. 
        yl = ydv                                ; Last row. 
        !mouse.button = 0                       ; Clear button flag. 
	tmp=convert_coord(xdv,ydv,/dev,to_dev=device,to_norm=norm,to_dat=data)
	xx0=tmp(0)  &  yy0=tmp(1)
 
	if mag0 ne 0 then begin
	  if n_elements(st) ne 0 then begin
	    device,window_state=state		; Check if window exists.
	    if state(st.win2) eq 1 then win2=st.win2 else begin $
	      window, /free, xs=msize, ys=msize, title='Mag: '+strtrim(mag,2)
	      win2 = !d.window		 	; Mag window.
	    endelse
	  endif else begin
	    window, /free, xs=msize, ys=msize, title='Mag: '+strtrim(mag,2)
	    win2 = !d.window		 	; Mag window.
	  endelse
	  wset,win1				; Set back to starting window.
	endif
 
	;---------  Set up status widget  -------------
        if stat then begin
          if not widget_info(top,/valid_id) then begin
	    ;-------  Mag window creation  ------
	    if mag0 ne 0 then begin
	      wset, win1				 ; Return to first win.
	    endif else begin
	      win2 = 0
	    endelse
	    ;------  Widget setup  ------------
            top = widget_base(/column,title='Cross-hair cursor')
            id_typ = widget_label(top,val= ' ')
            b = widget_base(top,/row)              	; Position.
            id = widget_label(b,val='X')
            tx = widget_text(b,xsize=xsize)
            b = widget_base(top,/row)              	; Position.
            id = widget_label(b,val='Y')
            ty = widget_text(b,xsize=ysize)
	    tz = 0
	    trgb = 0
	    if keyword_set(pixel) then begin
              b = widget_base(top,/row)              	; Pixel value.
              id = widget_label(b,val='Z')
              tz = widget_text(b,xsize=5)
	      if keyword_set(hsv) then begin
                id = widget_label(b,val='HSV')
                trgb = widget_text(b,xsize=15)
	      endif else begin
                id = widget_label(b,val='RGB')
                trgb = widget_text(b,xsize=12)
	      endelse
	      tvlct,rr,gg,bb,/get			; Get color table
	    endif
	    tarr = 0
	    if arrflag then begin
	      b = widget_base(top,/row) 		; Array value.
              id = widget_label(b,val='Array')
              tarr = widget_text(b,xsize=12)
	    endif
	    if izflag then begin
	      b = widget_base(top,/row) 		; izoom value.
              id = widget_label(b,val='Value')
              tarr = widget_text(b,xsize=12)
	    endif
            xsz = max(strlen(instr))
            ysz = n_elements(instr)
            id = widget_text(top,xsize=xsz,ysize=ysz,val=instr)
            ;-------  Save widget IDs in a structure  --------
            st = {top:top, typ:id_typ, tx:tx, ty:ty, tz:tz, trgb:trgb,$
	      tarr:tarr, win2:win2}
          endif  ; st not defined.
 
          ;--------  Initialize Stat widget   -------
          widget_control,st.typ,set_va=(['Device','Normalized','Data'])(ctyp)+$
            ' Coordinates'
          widget_control, st.tx, set_val=strtrim(xx0,2)
          widget_control, st.ty, set_val=strtrim(yy0,2)
	  if keyword_set(pixel) then begin
	    zdv = tvrd(xdv,ydv,1,1,true=tvtr)
	    if vflag eq 0 then begin	; 8 bit color.
	      indx = strtrim(zdv(0)+0,2)
	      red=rr(zdv) & grn=gg(zdv) & blu=bb(zdv)
	    endif else begin
	      indx = '24BIT'
	      red=zdv(0) & grn=zdv(1) & blu=zdv(2)
	    endelse
            widget_control, st.tz, set_val=indx
	    rgb = string(/print,form='(3I4)',red,grn,blu)
            widget_control, st.trgb, set_val=rgb
	  endif
	  if arrflag then begin
	    widget_control, st.tarr, set_val=strtrim(array(xdv,ydv),2)
	  endif
          ;--------  Create  ---------
          widget_control, st.top, /real
        endif
 
 
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
	    if vflag then tvlct,ii0,ii0,ii0       ; Need B&W table.
            tv, tsx, xl, 0, true=tvtr             ; Replace last column. 
            tv, tsy, 0, yl, true=tvtr             ; Replace last row. 
	    if vflag then tvlct,rr0,gg0,bb0       ; Original table.
            tsx = tvrd(xdv,0,1,!d.y_size,true=tvtr)  ; Read new column.
            tsy = tvrd(0,ydv,!d.x_size,1,true=tvtr)  ; Read new row.
          endif else begin
            plots, [xl,xl],yydv,color=clr,linestyle=linestyle,/dev
            plots, xxdv,[yl,yl],color=clr,linestyle=linestyle,/dev
	    empty			          ; Flush graphics.
          endelse
          xl = xdv                                ; Last column. 
          yl = ydv                                ; Last row. 
	  if keyword_set(pixel) then $
	    zdv=tvrd(xdv,ydv,1,1,true=tvtr)	    ; Read pix.
	  ;----------  Update mag window if any  --------------
	  if mag0 ne 0 then begin
	    t=tvrd2(xdv-rdsz2,ydv-rdsz2,rdsz,rdsz,true=tvtr)  ; Read patch.
	    t = rebin(t,wsz,wsz,tvtr>1,/samp)	    ; Magnify.
	    it = t(xmid,ymid,*)			    ; Mid pixel.
	    if n_elements(it) lt 3 then tst=lum(it(0)) else tst=it(1)
	    if tst lt 128 then cc=bright else cc=dark   ; Outline color.
	    t(xmid:xmid+mag,ymid,*)=cc		    ; Draw mid pixel outline.
	    t(xmid:xmid+mag,ymid+mag,*)=cc
	    t(xmid,ymid:ymid+mag,*)=cc
	    t(xmid+mag,ymid:ymid+mag,*)=cc
	    win = win2
	    if n_elements(st) ne 0 then win=st.win2
	    wset, win				    ; Set to mag window.
	    if keyword_set(xmode) then device,set_graph=3  ; Copy source.
	    tv, t, true=tvtr			    ; Display mag view.
	    if keyword_set(xmode) then device,set_graph=6  ; Back to XOR.
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
          ;-------  Update status display  ------------
	  if stat then begin
	    tmp = convert_coord(xdv, ydv, /dev, $
	      to_dev=device, to_norm=norm, to_dat=data)
	    x0=tmp(0) & y0=tmp(1)
	    x=x0 & y=y0
	    ;-----  Handle y reversal  --------
	    if (ctyp eq 0) and keyword_set(order) then y=(!d.y_size-1)-y
	    ;-----  Format values  ------------
            if keyword_set(js) then x = x + jsoff
	    if n_elements(xfn) eq 0 then x=strtrim(x,2) $
	      else x=call_function(xfn, x)
	    if n_elements(yfn) eq 0 then y=strtrim(y,2) $
	      else y=call_function(yfn, y)
	    ;-----  Display values in status area  -----
	    widget_control, st.tx, set_val=x
	    widget_control, st.ty, set_val=y
	    if keyword_set(pixel) then begin
	      if vflag eq 0 then begin	; 8 bit color.
	        indx = strtrim(zdv(0)+0,2)
	        red=rr(zdv) & grn=gg(zdv) & blu=bb(zdv)
	      endif else begin
	        indx = '24BIT'
	        red=zdv(0) & grn=zdv(1) & blu=zdv(2)
	      endelse
              widget_control, st.tz, set_val=indx
	      if keyword_set(hsv) then begin
	        color_convert, red,grn,blu,/rgb_hsv,hue,sat,val 
	        hue = round(hue)
	        rgb = string(/print,form='(I3,F6.3,F6.3)',hue,sat,val)
	      endif else begin
	        rgb = string(/print,form='(3I4)',red,grn,blu)
	      endelse
              widget_control, st.trgb, set_val=rgb
	    endif
	    if arrflag then begin
	      widget_control, st.tarr, set_val=strtrim(array(xdv,ydv),2)
	    endif
	    if izflag then begin
	      txt = '?'
	      if (x0 ge izxmn) and (x0 le izxmx) and $
	         (y0 ge izymn) and (y0 le izymx) then begin
		    dx = abs(iz.x - x0)
		    dy = abs(iz.y - y0)
		    ix = where(dx eq min(dx))
		    iy = where(dy eq min(dy))
		    txt = strtrim(iz.z(ix(0),iy(0)),2)
	      endif
	      widget_control, st.tarr, set_val=txt
	    endif
	  endif
	  ;-------  Handle function of (X,Y)  -----
	  if n_elements(xypro)ne 0 then begin
	    tmp = convert_coord(xdv, ydv, /dev, $
	      to_dev=device, to_norm=norm, to_dat=data)
	    x=tmp(0) & y=tmp(1)
	    call_procedure, xypro, x, y
	  endif
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
	  if vflag then tvlct,ii0,ii0,ii0       ; Need B&W table.
          tv, tsx, xl, 0, true=tvtr             ; Replace last column. 
          tv, tsy, 0, yl, true=tvtr             ; Replace last row. 
	  if vflag then tvlct,rr0,gg0,bb0       ; Original table.
	endelse
 
	;--------  return correct coordinate  --------
	tmp=convert_coord(xdv,ydv,/dev,to_dev=device,to_norm=norm,to_dat=data)
	x = tmp(0)
        if keyword_set(js) then x = x + jsoff
	y = tmp(1)
	;-----  Handle y reversal  --------
	if (ctyp eq 0) and keyword_set(order) then y=(!d.y_size-1)-y
 
        ;--------  Remove status display widget  -------
        if (not keyword_set(nostat)) and (not keyword_set(keep)) then begin
          widget_control, st.top, /dest
        endif
	;-------  Remove mag window  --------------
	if not keyword_set(keep) then begin
	  if mag0 ne 0 then begin
	    win = win2
	    if n_elements(st) ne 0 then win=st.win2
	    wdelete, win
	  endif
	endif
 
        return
        end 
