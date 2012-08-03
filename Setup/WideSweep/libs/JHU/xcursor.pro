;-------------------------------------------------------------
;+
; NAME:
;       XCURSOR
; PURPOSE:
;       Cursor coordinate display in a pop-up widget window.
; CATEGORY:
; CALLING SEQUENCE:
;       xcursor, x, y
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA   display data coordinates (default).
;         /DEVICE display device coordinates.
;         /NORMAL display normalized coordinates.
;         /ORDER  Reverse device y coordinate (0 at window top).
;         XOFFSET=xoff, YOFFSET=yoff Widget position.
;         TEXT=txt text to display (def=Press any button to exit).
;           May be a text array.
;         ECHO=win Index of window (same size) to echo cursor in.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1 Nov, 1993
;       R. Sterner, 1995 Jun 30 --- Added x,y and /ORDER.
;       R. Sterner, 2000 Aug 17 --- Added XOFFSET, YOFFSET
;       R. Sterner, 2000 Aug 18 --- Added TEXT, handled changed !map.
;       R. Sterner, 2001 Jan 12 --- Corrected map case.
;       R. Sterner, 2005 May 02 --- Added ECHO cursor.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xcursor, x, y, data=data, normal=norm, device=dev, $
	  order=order, xoffset=xoff, yoffset=yoff, $
	  text=txt, echo=ewin, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Cursor coordinate display in a pop-up widget window.'
	  print,' xcursor, x, y'
	  print,'   x, y = Cursor coordinates.            in,out'
	  print,' Keywords:'
	  print,'   /DATA   display data coordinates (default).'
	  print,'   /DEVICE display device coordinates.'
	  print,'   /NORMAL display normalized coordinates.'
          print,'   /ORDER  Reverse device y coordinate (0 at window top).'
	  print,'   XOFFSET=xoff, YOFFSET=yoff Widget position.'
	  print,'   TEXT=txt text to display (def=Press any button to exit).'
	  print,'     May be a text array.'
	  print,'   ECHO=win Index of window (same size) to echo cursor in.'
	  return
	endif
 
	if n_elements(txt) eq 0 then txt='Press any button to exit'
 
	;-------  Determine coordinate system  ---------
	typ = 'Data'
	ctyp = 2
	if keyword_set(norm) then begin
	  typ = 'Normalized'
	  ctyp = 1
	endif
	if keyword_set(dev) then begin
	  typ = 'Device'
	  ctyp = 0
	endif
	if strupcase(strmid(typ,0,2)) eq 'DA' then begin
	  if !x.s(1) eq 0 then begin
	    print,' Data coordinate system not established.'
	    return
	  endif
	endif
 
	win = !d.window		; Current window.
 
        ;------  Find ranges and start in device coordinates  ----
        if keyword_set(dev) then begin              ;----  DEVICE  -----
          xxdv=[0,!d.x_size-1]                      ; Device range.
          yydv=[0,!d.y_size-1]
          if n_elements(x) eq 0 then x=!d.x_size/2
          x = x>0<(!d.x_size-1)
          if n_elements(y) eq 0 then y=!d.y_size/2
          y = y>0<(!d.y_size-1)
        endif else if keyword_set(norm) then begin  ;---  NORMAL  -----
          xxdv=[0,!d.x_size-1]                      ; Normal range.
          yydv=[0,!d.y_size-1]
          if n_elements(x) eq 0 then x=.5
          x = x>0<1.
          if n_elements(y) eq 0 then y=.5
          y = y>0<1.
        endif else begin
	  if !x.type eq 3 then begin		    ;----  MAPS  ------
	    xxdv = [0,!d.x_size-1]
	    yydv = [0,!d.y_size-1]
            if n_elements(x) eq 0 then x=(!map.ll_box(1)+!map.ll_box(3))/2.
            if n_elements(y) eq 0 then y=(!map.ll_box(0)+!map.ll_box(2))/2.
	  endif else begin			    ;----  DATA  ------
            xx = [min(!x.crange), max(!x.crange)]     ; Data range in x.
            if !x.type eq 1 then xx=10^xx             ; Handle log x axis.
            yy = [min(!y.crange), max(!y.crange)]     ; Data range in y.
            if !y.type eq 1 then yy=10^yy             ; Handle log y axis.
            tmp = convert_coord(xx,yy,/to_dev)        ; Convert to device coord.
            xxdv = tmp(0,0:1)                         ; Device coord. range.
            yydv = tmp(1,0:1)
            xxdv = xxdv(sort(xxdv))                   ; Allow for reversed axes.
            yydv = yydv(sort(yydv))
            if n_elements(x) eq 0 then x = total(xx)/2.
            x = x>xx(0)<xx(1)
            if n_elements(y) eq 0 then y = total(yy)/2.
            y = y>yy(0)<yy(1)
	    endelse
        endelse
        ;-----  Handle y reversal  --------
	y0 = y			; Initial y.
        if (ctyp eq 0) and keyword_set(order) then y=(!d.y_size-1)-y
 
	;-------  Set cursor initial position  ----------
        tmp = convert_coord(x,y,dev=dev,norm=norm,data=data,/to_dev)
        xdv = tmp(0)<xxdv(1)  & ydv = tmp(1)<yydv(1)
        tvcrs, xdv, ydv                         ; Place cursor.
 
	;-----  Echo cursor  --------------
	if n_elements(ewin) eq 0 then ewin=-1	; Force defined.
	if ewin ge 0 then begin			; Check if window valid.
	  winlist,list,/quiet			; List of windows in use.
	  w = where(ewin eq list, cnt)		; Is ewin in list?
	  if cnt eq 0 then begin		; No, flag to ignore.
	    ewin = -1
	    print,' Error in xcursor: echo window not valid.  Ignored.'
	  endif
	endif
	if ewin ge 0 then begin			; Echo cursor mode?.
	  lex = xdv				; Echoed cursor point.
	  ley = ydv
	  device,set_graphics=6			; XOR mode.
	  wset, ewin				; Set to echo window.
	  plots,/dev,lex,ley,psym=1		; Plot first point.
	  empty
	  device,set_graphics=3			; Back to COPY mode.
	  wset, win				; Set to working window.
	endif
	;----------------------------------
 
	;-------  Set up display widget  ----------
	top = widget_base(/column,title=' ',xoff=xoff,yoff=yoff)
	for i=0,n_elements(txt)-1 do id=widget_label(top,val=txt(i))
	id = widget_label(top,val='       '+typ+' coordinates       ')
	id = widget_label(top,val=' ',/dynamic_resize)
	widget_control, top, /real
	widget_control, id, set_val=strtrim(string(x,y0),2)
 
	;---------  Cursor loop  ------------
	!err = 0
	while !err eq 0 do begin
	  cursor, x, y, data=data, norm=norm, dev=dev, /change
	  ;-----  Echo cursor  --------------
	  if ewin ge 0 then begin		; Echo cursor mode?.
	    device,set_graphics=6			; XOR mode.
	    wset, ewin					; Set to echo window.
	    plots,/dev,lex,ley,psym=1			; Erase last point.
	    empty
	    tmp = convert_coord(x,y,data=data,norm=norm,dev=dev,/to_dev)
	    lex = tmp(0)				; Want cursor position
	    ley = tmp(1)				; in device coords.
	    plots,/dev,lex,ley,psym=1			; Plot cursor location.
	    empty
	    device,set_graphics=3			; Back to COPY mode.
	    wset, win					; Set to working window.
	  endif
	  ;----------------------------------
	  empty
          ;-----  Handle y reversal  --------
          if (ctyp eq 0) and keyword_set(order) then y=(!d.y_size-1)-y
	  widget_control, id, set_val=strtrim(string(x,y),2)
	endwhile
 
	;-----  Echo cursor  --------------
	if ewin ge 0 then begin	; Echo cursor mode?.
	  device,set_graphics=6			; XOR mode.
	  wset, ewin				; Set to echo window.
	  plots,/dev,lex,ley,psym=1		; Erase last point.
	  empty
	  device,set_graphics=3			; Back to COPY mode.
	  wset, win				; Set to working window.
	endif
	;----------------------------------
 
	widget_control, top, /dest
 
	return
	end
