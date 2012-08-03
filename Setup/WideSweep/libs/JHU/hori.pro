;-------------------------------------------------------------
;+
; NAME:
;       HORI
; PURPOSE:
;       Interactive horizontal line on screen or plot.
; CATEGORY:
; CALLING SEQUENCE:
;       hori, [y]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA   Causes data coordinates to be used (default).
;         /DEVICE Causes window device coordinates to be used.
;         /NORMAL Causes normalized coordinates to be used.
;         COLOR=c Set color of line (ignored for /XOR).
;         LINESTYLE=s Line style.
;         XFORMAT=xfn  These kywords are given names of functions
;         YFORMAT=yfn  that accept the numeric value of x or y
;           and return a corresponding string which is displayed
;           in place of the actual value.  For example, Julian
;           days could be displayed as a date with jd2date.
;         XSIZE=xs, YSIZE=ys  Coordinate display widths.
;         /JS  Means X axis is time in Julian seconds.
;         /NOSTATUS   Inhibits status display widget.
;         SETSTAT=st  May use the same status display widget on
;           each call to hori (stays in same position).
;           On first call: the status widget structure is returned.
;           Following calls: send st.  Must use with /KEEP.
;           To delete status display widget after last box1 call:
;             widget_control,st.top,/dest (or drop /KEEP)
;         /KEEP   Do not delete status widget on exit.
;         /XMODE means use XOR plot mode instead of tvrd mode.
;         INSTRUCTIONS=t  String array with exit instructions.
;           Default: Press any button to exit.
;         /DIALOG Means give an exit dialog box.
;         MENU=m  A string array with exit dialog box options.
;           Def=Exit. An option labeled Continue is always added.
;         EXITCODE=x Returns exit code.  Always 0 unless a dialog
;           box is requested, then is selected exit option number.
;         BUTTON=b   Returned button code: 1=left, 2=middle, 4=right.
; OUTPUTS:
;       y = Y coordinate of line.      in, out
; COMMON BLOCKS:
;       js_com
; NOTES:
;       Note: data coordinates are default.
;         Y may be set to starting position in entry.
; MODIFICATION HISTORY:
;       R. Sterner, 11 Sep, 1990
;       R. Sterner, 21 Oct, 1991 --- added /NOCOMMANDS, EXITCODE=x
;       R. Sterner,  6 Nov, 1991 --- added EXITCODE=0.
;       R. Sterner, 23 Dec, 1991 --- made x be both in and out.
;       R. Sterner, 23 Dec, 1991 --- Added wait,.2 for HP workstation.
;       R. Sterner, 21 May, 1992 --- fixed for log axes.
;       R. Sterner, 1994 Jan 20 --- One mouse button,/NORMAL,/DATA.
;       R. Sterner, 1994 jan 21 --- Added /NOSTATUS, SETSTAT, /KEEP.
;       R. Sterner, 1994 Feb 16 --- Fixed a few minor bugs.
;       R. Sterner, 1994 Mar  4 --- Added XFORMAT, YFORMAT, & BUTTON keywords.
;       R. Sterner, 1994 May 17 --- Added XSIZE,YSIZE,/DIALOG,INSTRUCTIONS,
;       MENU, and rearranged display.
;       R. Sterner, 1995 Jan 11 --- Added /JS for time in JS.
;       R. Sterner, 1995 Aug 17 --- Was not using initial y.  Fixed.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;       R. Sterner, 1998 Mar 11 --- Attempt to deal with true color.
;       R. Sterner, 2003 Oct 27 --- Fixed startup non-erased line (rounded).
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
        pro hori, y, color=color, linestyle=linestyle, $ 
          help=hlp, exitcode=exitcode, nostatus=nostat, $
          device=device, normal=norm, data=data, xmode=xmode,$
	  setstat=st, keep=keep, xformat=xfn, yformat=yfn, button=button, $
	  xsize=xsize, ysize=ysize, dialog=dialog,menu=menu,$
          instructions=instr, js=js
 
	common js_com, jsoff
  
        if keyword_set(hlp) then begin 
          print,' Interactive horizontal line on screen or plot.' 
          print,' hori, [y]' 
          print,'   y = Y coordinate of line.      in, out' 
          print,' Keywords:' 
          print,'   /DATA   Causes data coordinates to be used (default).'
          print,'   /DEVICE Causes window device coordinates to be used.'
          print,'   /NORMAL Causes normalized coordinates to be used.'
          print,'   COLOR=c Set color of line (ignored for /XOR).' 
          print,'   LINESTYLE=s Line style.'
          print,'   XFORMAT=xfn  These kywords are given names of functions'
          print,'   YFORMAT=yfn  that accept the numeric value of x or y'
          print,'     and return a corresponding string which is displayed'
          print,'     in place of the actual value.  For example, Julian'
          print,'     days could be displayed as a date with jd2date.'
	  print,'   XSIZE=xs, YSIZE=ys  Coordinate display widths.'
	  print,'   /JS  Means X axis is time in Julian seconds.'
	  print,'   /NOSTATUS   Inhibits status display widget.'
	  print,'   SETSTAT=st  May use the same status display widget on'
	  print,'     each call to hori (stays in same position).'
	  print,'     On first call: the status widget structure is returned.'
	  print,'     Following calls: send st.  Must use with /KEEP.'
	  print,'     To delete status display widget after last box1 call:'
	  print,'       widget_control,st.top,/dest (or drop /KEEP)'
	  print,'   /KEEP   Do not delete status widget on exit.'
          print,'   /XMODE means use XOR plot mode instead of tvrd mode.'
          print,'   INSTRUCTIONS=t  String array with exit instructions.'
          print,'     Default: Press any button to exit.'
          print,'   /DIALOG Means give an exit dialog box.'
          print,'   MENU=m  A string array with exit dialog box options.'
          print,'     Def=Exit. An option labeled Continue is always added.'
          print,'   EXITCODE=x Returns exit code.  Always 0 unless a dialog' 
          print,'     box is requested, then is selected exit option number.'
          print,'   BUTTON=b   Returned button code: 1=left, 2=middle, 4=right.'
          print,' Note: data coordinates are default.' 
          print,'   Y may be set to starting position in entry.' 
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
            print,' Error in veri: cannot use /JS until a time series'
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
        if (total(abs(!y.crange)) eq 0.0) and $ 
           (not keyword_set(device)) and $
           (not keyword_set(norm)) then begin 
          print,' Error in hori: data coordinates not yet established.' 
          print,'  Must make a plot before calling hori or use /DEVICE'
          print,'   or /NORMAL keyword.' 
          return 
        endif 
        if device  eq 1 then ctyp = 0              ; Coordinate flag.
        if norm eq 1 then ctyp = 1
        if data eq 1 then ctyp = 2
 
        ;---------  Set defaults  -------------
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
        if n_elements(instr) eq 0 then instr = ['Press any button to exit.']
        if n_elements(xsize) eq 0 then begin
          xsize=12
          if strupcase(!version.os) eq 'MACOS' then xsize=6
        endif
        if n_elements(ysize) eq 0 then begin
          ysize=12
          if strupcase(!version.os) eq 'MACOS' then ysize=6
        endif
 
        ;------  Find ranges and start in device coordinates  ----
        if keyword_set(device) then begin           ;----  DEVICE  -----
          xxdv=[0,!d.x_size-1]                        ; Device range.
          yydv=[0,!d.y_size-1]
          if n_elements(y) eq 0 then y=!d.y_size/2
	  y = y>0<(!d.y_size-1)
          x = !d.x_size/2                          ; X midrange.
        endif else if keyword_set(norm) then begin  ;---  NORMAL  -----
          xxdv=[0,!d.x_size-1]                        ; Normal range.
          yydv=[0,!d.y_size-1]
          if n_elements(y) eq 0 then y=.5
	  y = y>0<1.
          x = .5                                    ; X midrange.
        endif else begin                            ;----  DATA  ------
          xx = [min(!x.crange), max(!x.crange)]     ; Data range in x. 
          if !x.type eq 1 then xx=10^xx             ; Handle log x axis. 
          yy = [min(!y.crange), max(!y.crange)]     ; Data range in y. 
          if !y.type eq 1 then yy=10^yy             ; Handle log y axis. 
          tmp = convert_coord(xx,yy,/to_dev)        ; Convert to device coord. 
          xxdv = tmp(0,0:1)                         ; Device coord. range. 
          yydv = tmp(1,0:1)
          xxdv = xxdv(sort(xxdv))                   ; Allow for reversed axes.
          yydv = yydv(sort(yydv))
          if n_elements(y) eq 0 then y = total(yy)/2.
	  y = y>yy(0)<yy(1)
          x = total(xx)/2.
        endelse
 
	tmp = convert_coord(x,y,dev=device,norm=norm,data=data,/to_dev)
	tmp = round(tmp)			; RES 2003 Oct 27.
	xdv = tmp(0)<xxdv(1)  & ydv = tmp(1)<yydv(1)
 
        ;--------  Handle starting line  ---------- 
        tvcrs, xdv, ydv                         ; Place cursor.
        if not keyword_set(xmode) then t=tvrd(0,ydv,!d.x_size,1,true=3) ;1strow.
        plots, xxdv,[ydv,ydv],color=clr,linestyle=linestyle,/dev 
        yl = ydv                                ; Last row. 
        !mouse.button = 0                       ; Clear button flag. 
	tmp=convert_coord(xdv,ydv,/dev,to_dev=device,to_norm=norm,to_dat=data)
	xx0=tmp(0)  &  yy0=tmp(1)
 
	;---------  Set up status widget  -------------
        if stat then begin
          if not widget_info(top,/valid_id) then begin
            top = widget_base(/column,title='Interactive Horizontal Line')
            id_typ = widget_label(top,val= ' ')
            b = widget_base(top,/row)              		; Position.
            id = widget_label(b,val='X')
            tx = widget_text(b,xsize=xsize)
            b = widget_base(top,/row)              		; Position.
            id = widget_label(b,val='Y')
            ty = widget_text(b,xsize=ysize)
            xsz = max(strlen(instr))
            ysz = n_elements(instr)
            id = widget_text(top,xsize=xsz,ysize=ysz,val=instr)
            ;-------  Save widget IDs in a structure  --------
            st = {top:top, typ:id_typ, tx:tx, ty:ty}
          endif  ; st not defined.
 
          ;--------  Initialize Status widget   -------
          widget_control,st.typ,set_va=(['Device','Normalized','Data'])(ctyp)+$
            ' Coordinates'
          widget_control, st.tx, set_val=strtrim(xx0,2)
          widget_control, st.ty, set_val=strtrim(yy0,2)
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
	  ;------  Update line  --------------
          ydv = ydv > yydv(0) < yydv(1)           ; Keep in bounds.
          xcl = xdv  & ycl = ydv
          if not keyword_set(xmode) then begin
	    if vflag then tvlct,ii0,ii0,ii0       ; Need B&W table.
            tv, t, 0, yl, true=tvtr               ; Replace last row. 
	    if vflag then tvlct,rr0,gg0,bb0       ; Original table.
            t = tvrd(0,ydv,!d.x_size,1,true=tvtr) ; Read new column.
          endif else begin
            plots, xxdv,[yl,yl],color=clr,linestyle=linestyle,/dev
	    empty			          ; Flush graphics.
          endelse
          yl = ydv                                ; Last column. 
          plots, xxdv,[ydv,ydv],color=clr,linestyle=linestyle,/dev 
	  empty				          ; Flush graphics.
          ;-------  Update status display  ------------
	  if stat then begin
	    tmp = convert_coord(xdv, ydv, /dev, $
	      to_dev=device, to_norm=norm, to_dat=data)
	    x=tmp(0) & y=tmp(1)
            if keyword_set(js) then x = x + jsoff
            if n_elements(xfn) eq 0 then x=strtrim(x,2) $
              else x=call_function(xfn, x)
            if n_elements(yfn) eq 0 then y=strtrim(y,2) $
              else y=call_function(yfn, y)
	    widget_control, st.tx, set_val=x
	    widget_control, st.ty, set_val=y
	  endif
          ;-------  Handle button press  ----------
          if !mouse.button ne 0 then begin
            button = !mouse.button
            if keyword_set(dialog) then begin
              exitcode = xoption([menu,'Continue'],def=n_elements(menu))
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
          plots, xxdv,[ydv,ydv],color=clr,linestyle=linestyle,/dev 
	  device,set_graph=old
	endif else begin
	  if vflag then tvlct,ii0,ii0,ii0       ; Need B&W table.
          tv, t, 0, yl, true=tvtr               ; Replace last row. 
	  if vflag then tvlct,rr0,gg0,bb0       ; Original table.
	endelse
 
	;--------  return correct coordinate  --------
	tmp=convert_coord(xdv,ydv,/dev,to_dev=device,to_norm=norm,to_dat=data)
	y = tmp(1)
	if keyword_set(js) then x = x + jsoff
 
        ;--------  Remove status display widget  -------
        if (not keyword_set(nostat)) and (not keyword_set(keep)) then begin
          widget_control, st.top, /dest
        endif
 
        return
        end 
