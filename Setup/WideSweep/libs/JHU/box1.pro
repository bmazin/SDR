;-------------------------------------------------------------
;+
; NAME:
;       BOX1
; PURPOSE:
;       Single mouse button interactive box on image display.
; CATEGORY:
; CALLING SEQUENCE:
;       box1, x, y, dx, dy
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE         Work in device coordinates (default).
;         /NORMAL         Work in normalized coordinates.
;         /DATA           Work in data coordinates.
;         COLOR=clr       Box color.  -2 for dotted box.
;         DXRANGE=dxr     X size range [min, max].
;         DYRANGE=dyr     Y size range [min, max].
;         SHAPE=shp       If given box shape is locked: Shape=dy/dx.
;         /NOSTATUS       Inhibits status display widget.
;         TEXT=txt        Text array to display in status widget.
;         MENU=txtarr     Text array with exit menu options.
;           Def=['OK','Abort','Continue'].  'Continue is added.
;         /NOMENU         Inhibits exit menu.
;         EXITCODE=code.  0=normal exit, 1=alternate exit.
;           If MENU is given then code is option index.
;         SETSTAT=st      May use the same status display widget on
;           each call to box1 (stays in same position).
;           On first call: the status widget structure is returned.
;           Following calls: send st.  Must use with /KEEP.
;           To delete status display widget after last box1 call: 
;             widget_control,st.top,/dest (or drop /KEEP)
;         /KEEP           Do not delete status widget on exit.
;         ECHO=win2       Echo same box in second window.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Jan 10
;       R. Sterner, 1995 Mar 22 --- Added /NOMENU option.
;       R. Sterner, 2005 Jun 24 --- Added ECHO=win2 keyword.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro boxcon, x, y, dx, dy, x2, y2, dx2, dy2, xmx=xmx, ymx=ymx, $
	  device=dev, normal=norm, data=dat, $
	  to_device=to, from_device=from
 
	;------  Make sure keywords are defined  -------
	if n_elements(dev)  eq 0 then  dev=0
	if n_elements(norm) eq 0 then norm=0
	if n_elements(dat)  eq 0 then  dat=0
	if (dev+norm+dat) eq 0 then begin
	  print,' Error in boxcon: must give one of the keywords'
	  print,'   /device, /normal, or /data.'
	  bell
	  stop
	endif
	if n_elements(to)  eq 0 then  to=0
	if n_elements(from) eq 0 then from=0
	if (to+from) eq 0 then begin
	  print,' Error in boxcon: must give one of the keywords'
	  print,'   /to_device or /from_device.'
	  bell
	  stop
	endif
 
	;-------------  From device coordinates  ----------
	if keyword_set(from) then begin
	  if keyword_set(dev) then begin	; To Device.
	    x2 =fix(x)   &   y2=fix(y)
	    dx2=fix(dx)  &  dy2=fix(dy)
	    xmx=x2+dx2-1 &  ymx=y2+dy2-1
	  endif
	  if keyword_set(norm) then begin	; To Normal.
            out=convert_coord([x,x+dx-1],[y,y+dy-1],/device,/to_norm) 
            x2=out(0,0) & dx2=out(0,1)-x2 
            y2=out(1,0) & dy2=out(1,1)-y2 
	    xmx=x2+dx2  & ymx=y2+dy2
	  endif
	  if keyword_set(dat) then begin	; To Data.
            out=convert_coord([x,x+dx-1],[y,y+dy-1],/device,/to_data) 
            x2=out(0,0) & dx2=out(0,1)-x2 
            y2=out(1,0) & dy2=out(1,1)-y2 
	    xmx=x2+dx2  & ymx=y2+dy2
	  endif
	endif
 
	;-------------  To device coordinates  ----------
	if keyword_set(to) then begin
	  if keyword_set(dev) then begin	; From Device.
	    x2 =fix(x)   &   y2=fix(y)
	    dx2=fix(dx)  &  dy2=fix(dy)
	  endif
	  if keyword_set(norm) then begin	; From Normal.
            out=convert_coord([x,x+dx],[y,y+dy],/to_device,/norm) 
            x2=fix(out(0,0))  & dx2=fix(out(0,1)-x2+1) 
            y2=fix(out(1,0))  & dy2=fix(out(1,1)-y2)+1 
	  endif
	  if keyword_set(dat) then begin	; From Data.
            out=convert_coord([x,x+dx],[y,y+dy],/to_device,/data) 
            x2=fix(out(0,0)) & dx2=fix(out(0,1)-x2)+1
            y2=fix(out(1,0)) & dy2=fix(out(1,1)-y2)+1 
	    x2 = x2>0<(!d.x_size-1)
	    y2 = y2>0<(!d.y_size-1)
	  endif
	  xmx=x2+dx2-1 &  ymx=y2+dy2-1
	endif
 
	return
	end
 
;========================================================================
;	box1.pro = Single mouse button interactive box on image display.
;       R. Sterner, 1994 Jan 6 
;========================================================================
  
        pro box1, x0, y0, dx0, dy0, exitcode=exit, text=text, help=hlp, $ 
          color=clr, dxrange=dxran0, dyrange=dyran0, shape=shape, $ 
          device=dev, normal=norm, data=data, nostatus=nostat, $
	  setstat=st, keep=keep, menu=menu, nomenu=nomenu, echo=win2 
  
        if keyword_set(hlp) then begin 
          print,' Single mouse button interactive box on image display.' 
          print,' box1, x, y, dx, dy' 
          print,'   x,y =   Coordinates of box lower left corner.  in,out' 
          print,'   dx,dy = Box X and Y size.                      in,out' 
          print,' Keywords:' 
          print,'   /DEVICE         Work in device coordinates (default).' 
          print,'   /NORMAL         Work in normalized coordinates.' 
          print,'   /DATA           Work in data coordinates.' 
          print,'   COLOR=clr       Box color.  -2 for dotted box.' 
          print,'   DXRANGE=dxr     X size range [min, max].' 
          print,'   DYRANGE=dyr     Y size range [min, max].' 
          print,'   SHAPE=shp       If given box shape is locked: Shape=dy/dx.' 
          print,'   /NOSTATUS       Inhibits status display widget.' 
          print,'   TEXT=txt        Text array to display in status widget.' 
	  print,'   MENU=txtarr     Text array with exit menu options.'
	  print,"     Def=['OK','Abort','Continue'].  'Continue is added."
	  print,'   /NOMENU         Inhibits exit menu.'
          print,'   EXITCODE=code.  0=normal exit, 1=alternate exit.' 
	  print,'     If MENU is given then code is option index.'
	  print,'   SETSTAT=st      May use the same status display widget on'
	  print,'     each call to box1 (stays in same position).'
 	  print,'     On first call: the status widget structure is returned.'
	  print,'     Following calls: send st.  Must use with /KEEP.'
	  print,'     To delete status display widget after last box1 call: '
	  print,'       widget_control,st.top,/dest (or drop /KEEP)'
	  print,'   /KEEP           Do not delete status widget on exit.'
	  print,'   ECHO=win2       Echo same box in second window.'
          return 
        endif 
  
;================  Box setup  ================== 
        ;------  Set initial values  --------- 
        if n_elements(clr) eq 0 then clr=!p.color               ; Color. 
        sflag=0                                                 ; Shape. 
        if n_elements(shape) ne 0 then sflag=1 
        xran = [0,0]                            ; Output range. 
        yran = [0,0] 
        if n_elements(dev) eq 0 then dev=0      ; Coordinates. 
        if n_elements(norm) eq 0 then norm=0 
        if n_elements(data) eq 0 then data=0 
        if (dev+norm+data) eq 0 then dev=1      ; Default coord. 
        if dev  eq 1 then ctyp = 0              ; Coordinate flag. 
        if norm eq 1 then ctyp = 1 
        if data eq 1 then ctyp = 2 
        x_flag = 0                              ; Assume defined. 
        y_flag = 0 
        dx_flag = 0 
        dy_flag = 0 
        dxr_flag = 0 
        dyr_flag = 0 
        if n_elements(x0)  eq 0 then  x_flag = 1        ; Set not defined. 
        if n_elements(y0)  eq 0 then  y_flag = 1 
        if n_elements(dx0) eq 0 then dx_flag = 1 
        if n_elements(dy0) eq 0 then dy_flag = 1 
        if n_elements(dxran0) eq 0 then dxr_flag = 1   	; Size range. 
        if n_elements(dyran0) eq 0 then dyr_flag = 1
        wx = !d.x_size                          	; Window size. 
        wy = !d.y_size 
        stat = keyword_set(nostat) eq 0 
 
        ;----------  Handle coordinate systems  ---------------- 
        if keyword_set(dev) then begin          ; Device. 
          if x_flag  then  x=100 else x=x0      ; Defaults. 
          if y_flag  then y =100 else y=y0 
          if dx_flag then dx=100 else dx=dx0 
          if dy_flag then dy=100 else dy=dy0 
          if dxr_flag then dxran=[1,!d.x_size] else dxran=dxran0
          if dyr_flag then dyran=[1,!d.y_size] else dyran=dyran0
        endif 
        if keyword_set(norm) then begin         ; Normalized.. 
          if  x_flag then  x=0.1 else x=x0      ; Defaults. 
          if  y_flag then  y=0.1 else y=y0 
          if dx_flag then dx=0.1 else dx=dx0 
          if dy_flag then dy=0.1 else dy=dy0 
	  boxcon,x,y,dx,dy,x,y,dx,dy,/norm,/to_dev
          if dxr_flag then dxran=[0.,1.] else dxran=dxran0
          if dyr_flag then dyran=[0.,1.] else dyran=dyran0
	  out = convert_coord([0.,dxran(0),dxran(1)],[0.,dyran(0),dyran(1)],$
	    /norm,/to_dev)
	  dxran = (1+[out(0,1)-out(0,0),out(0,2)-out(0,0)])>1
	  dyran = (1+[out(1,1)-out(1,0),out(1,2)-out(1,0)])>1
        endif 
        if keyword_set(data) then begin         ; Data. 
          if total(abs(!x.crange)) eq 0 then begin 
            print,' Error in box: Cannot use data coordinates, not established' 
            return 
          endif 
          xdef = (!x.crange(1)-!x.crange(0))/10.  ; Only linear, non-reversed. 
          ydef = (!y.crange(1)-!y.crange(0))/10. 
          if  x_flag then  x=!x.crange(0) else x=x0     ; Defaults. 
          if  y_flag then  y=!y.crange(0) else y=y0 
          if dx_flag then dx=xdef else dx=dx0 
          if dy_flag then dy=ydef else dy=dy0 
	  boxcon,x,y,dx,dy,x,y,dx,dy,/data,/to_dev
	  xcr = !x.crange  &  ycr = !y.crange
          if dxr_flag then dxran=[0,xcr(1)-xcr(0)] else dxran=dxran0
          if dyr_flag then dyran=[0,ycr(1)-ycr(0)] else dyran=dyran0
	  out = convert_coord([0.,dxran(0),dxran(1)],[0.,dyran(0),dyran(1)],$
	    /data,/to_dev)
	  dxran = (1+[out(0,1)-out(0,0),out(0,2)-out(0,0)])>1
	  dyran = (1+[out(1,1)-out(1,0),out(1,2)-out(1,0)])>1
        endif 
	dxran = fix(dxran)
	dyran = fix(dyran)
  
        ;-------  Handle size, shape, and position contraints  ---- 
        dx = dx>dxran(0)<dxran(1)                       ; Force x in size range. 
        if sflag then dy = fix(.5 + dx*shape)           ; Do shape. 
        dy = dy>dyran(0)<dyran(1)                       ; Force y in size range. 
        if sflag then dx = fix(.5 + dy/shape)           ; Fix shape. 
        if (x+dx) gt wx then x=(wx-dx)>0                ; Position and size. 
        if (y+dy) gt wy then y=(wy-dy)>0 
        if (x+dx) gt wx then dx=(wx-x) 
        if (y+dy) gt wy then dy=(wy-y) 
  
        tvcrs, x, y                     ; Put corner at given loc. 
        tvbox,x,y,dx,dy,clr,/noerase,echo=win2    ; Draw new box. 
 
        mode = 1                        ; Start in Move mode. 
        exit = -1                       ; No exit code. 
	top = -1L
	if n_elements(st) ne 0 then top=st.top
  
        ;--------  Status display widget  ------------- 
        if stat then begin 
	  if not widget_info(top,/valid_id) then begin
            top = widget_base(/column,title='') 
            ;-------  Help text  -------- 
            sx = 30 
            if n_elements(text) ne 0 then begin 
              sy = n_elements(text) 
              sx = max(strlen(text)) 
              id = widget_text(top, xsize=sx,ysize=sy,val=text) 
            endif 
            ;-------  Position and size  ---------- 
            b = widget_base(top,/column,/frame) 
            id_typ = widget_label(b,val= ' ',/dynamic) 
            bb = widget_base(b,/row)              ;--- X range and size. 
            id = widget_label(bb,val='Xmin  ') 
            tx1 = widget_text(bb,xsize=12) 
            id = widget_label(bb,val='DX  ') 
            tdx = widget_text(bb,xsize=12) 
            bb = widget_base(b,/row) 
            id = widget_label(bb,val='Xmax  ') 
            tx2 = widget_text(bb,xsize=12) 
            bb = widget_base(b,/row)              ;--- Y range and size. 
            id = widget_label(bb,val='Ymin  ') 
            ty1 = widget_text(bb,xsize=12) 
            id = widget_label(bb,val='DY  ') 
            tdy = widget_text(bb,xsize=12) 
            bb = widget_base(b,/row) 
            id = widget_label(bb,val='Ymax  ') 
            ty2 = widget_text(bb,xsize=12) 
            ;--------  Mode info  ----------- 
            b = widget_base(top,/column,/frame) 
            id_m = widget_label(b,val='Move box mode',/dynamic) 
            mhelp = widget_text(b,xsize=38,ysize=2,val=$ 
              ['Click for change size mode.','']) 
            cur = widget_label(b,val=' ',/dynamic) 
            cmode = widget_label(b, val=' ',/dynamic) 
	    ;-------  Save widget IDs in a structure  --------
	    st = {top:top, typ:id_typ, tx1:tx1, tdx:tdx, tx2:tx2, ty1:ty1, $
	      tdy:tdy, ty2:ty2, mode:id_m, help:mhelp, cur:cur, cmode:cmode} 
	  endif  ; st not defined.
 
          ;--------  Initialize Stat widget   ------- 
          widget_control,st.typ,set_va=(['Device','Normalized','Data'])(ctyp)+$ 
            ' Coordinates'
	  boxcon,x,y,dx,dy,xx0,yy0,dxx0,dyy0,xmx=xx1,ymx=yy1,/from_dev,$
	    dev=dev,norm=norm,data=data
          widget_control, st.tx1, set_val=strtrim(xx0,2) 
          widget_control, st.ty1, set_val=strtrim(yy0,2) 
          widget_control, st.tx2, set_val=strtrim(xx1,2) 
          widget_control, st.ty2, set_val=strtrim(yy1,2) 
          widget_control, st.tdx, set_val=strtrim(dxx0,2) 
          widget_control, st.tdy, set_val=strtrim(dyy0,2) 
          widget_control, st.mode,set_val='Move box mode'
          widget_control,st.help, set_val= ['Click for change size mode.','']
          ;--------  Create  --------- 
          widget_control, st.top, /real 
        endif 
 
;=============  Interactive Box  ===================== 
        xcl = -2  &  ycl = -2		; Last position.
	;----  Make sure exit menu is setup   ---------
	if n_elements(menu) eq 0 then menu=['OK','Abort']
	mvals = indgen(n_elements(menu))
 
        while exit lt 0 do begin
          cursor, xc, yc, 0, /device		; Look for new values.
          if ((xc eq xcl) and (yc eq ycl)) or $	; Not moved, or
	     ((xc eq -1) and (yc eq -1)) then $ ; moved out of window:
	    cursor,xc,yc,2,/device		; wait for a change.
          if !mouse.button eq 1 then wait,.2    ; Debounce. 
 
          case mode of 
            ;-------  Process Move Mode  ----------- 
1:          begin 
	      ;----------  Move box  ---------------
              if !mouse.button ne 1 then begin	; Just move, no button.
                x = xc < (wx - dx) > 0  ; Restrict box to window. 
                y = yc < (wy - dy) > 0 
		if (x ne xc) or (y ne yc) then tvcrs, x, y
                xcl = x  & ycl=y	; Save last position.
                tvbox, x,y, dx,dy, clr,echo=win2  ; Draw new box. 
	      ;----------  Move mode button  -----------
              endif else begin          ; Button, switch to Size change mode. 
                mode = 2 
		xc=x+dx-1 & yc=y+dy-1	; New cursor position.
                tvcrs, xc, yc		; Put cursor at upper-right corner. 
                xcl = xc  & ycl=yc	; Save last position.
                if stat then begin 
                  widget_control, st.mode, set_val='Change box size mode' 
                  widget_control, st.help, set_val=$ 
                    'Click for cursor mode.' 
                endif 
              endelse 
            end 
            ;-------  Process Change Size Mode  ----------- 
2:          begin 
	      ;-----------  Change box size  ------------
              if !mouse.button ne 1 then begin 		; Just move, no button.
                dx = ((xc-x)>0)+1			; New size. 
                dy = ((yc-y)>0)+1 
                dx = dx>dxran(0)<dxran(1)               ; Force x in size range.
                if sflag then dy = fix(.5 + dx*shape)   ; Do shape. 
                dy = dy>dyran(0)<dyran(1)               ; Force y in size range.
                if sflag then dx = fix(.5 + dy/shape)   ; Fix shape. 
                if (x+dx) gt wx then x=(wx-dx)>0        ; Position and size. 
                if (y+dy) gt wy then y=(wy-dy)>0 
                if (x+dx) gt wx then dx=(wx-x) 
                if (y+dy) gt wy then dy=(wy-y) 
		xc=x+dx-1 & yc=y+dy-1	; New cursor position.
                tvcrs, xc, yc		; Put cursor at upper-right corner. 
                tvbox, x,y, dx,dy, clr,echo=win2  ; Draw new box. 
                xcl = xc  & ycl=yc	; Save last position.
	      ;-----------  Change size mode button  -------
              endif else begin          ; Button, switch to Free cursor mode. 
                mode = 3 
		xc=x & yc=y+dy-1	; New cursor position.
                tvcrs, xc, yc		; Put cursor at upper-right corner. 
                if stat then begin 
                  widget_control, st.mode, set_val='Cursor mode' 
                  widget_control, st.help, set_val=$ 
                    ['Click above box center for Move Mode.',$ 
                     'Click below box center to exit.'] 
                  widget_control, st.cmode, set_val='Click for Move mode.' 
                endif 
              endelse 
            end 
            ;-------  Process Free Cursor Mode  ----------- 
3:          begin 
	      xcl=xc  &  ycl=yc				; Save cursor position.
	      ;---------  Free cursor button  -------------
              if !mouse.button eq 1 then begin 		; Button.
		;--------  Below center, exit options  -------
                if yc lt (y+dy/2) then begin 
                  ;----  Exit options: OK, Abort, Continue. 
		  if keyword_set(nomenu) then begin
		    exit = 0
		  endif else begin
		    exit = xoption([menu,'Continue'],val=[mvals,-1],def=0)
		  endelse
		  if exit lt 0 then begin
                    mode = 1              ; Switch to Move mode. 
                    tvcrs, x, y           ; Put cursor at lower-left corner. 
	            xcl=x  &  ycl=y	; Save cursor position.
                    if stat then begin 
                      widget_control, st.mode, set_val='Move mode' 
                      widget_control, st.help, set_val=$ 
                        ['Click for change size mode.',''] 
                      widget_control, st.cmode, set_val=' ' 
                      widget_control, st.cur, set_val=' ' 
                    endif 
		  endif
		;-------  Above center, return to Move Mode.  -----
                endif else begin 
                  mode = 1              ; Switch to Move mode. 
                  tvcrs, x, y           ; Put cursor at lower-left corner. 
	          xcl=x  &  ycl=y	; Save cursor position.
                  if stat then begin 
                    widget_control, st.mode, set_val='Move mode' 
                    widget_control, st.help, set_val=$ 
                      ['Click for change size mode.',''] 
                    widget_control, st.cmode, set_val=' ' 
                    widget_control, st.cur, set_val=' ' 
                  endif 
                endelse 
	      ;--------  Free cursor mode, no button  ----------
              endif else begin          ; No button. 
                if stat then begin 
                  if yc lt (y+dy/2) then begin 
                    widget_control, st.cmode, set_val='Click to Exit.' 
                  endif else begin 
                    widget_control, st.cmode, set_val='Click for Move mode.' 
                  endelse 
                endif 
              endelse 
            end  ; mode 3.
          endcase   ; case mode of.
          ;----------  Update position and size status  ---------- 
          if stat then begin 
	    boxcon,x,y,dx,dy,xx0,yy0,dxx0,dyy0,xmx=xx1, ymx=yy1, /from_dev,$
	      dev=dev,norm=norm,data=data
	    boxcon,xc,yc,dx,dy,xxc,yyc, /from_dev,$
	      dev=dev,norm=norm,data=data
            if mode eq 3 then begin 
              widget_control, st.cur, set_val='Cursor   x: '+$ 
                strtrim(xxc,2)+'   y: '+strtrim(yyc,2) 
            endif else begin 
              widget_control, st.tx1, set_val=strtrim(xx0,2) 
              widget_control, st.ty1, set_val=strtrim(yy0,2) 
              widget_control, st.tx2, set_val=strtrim(xx1,2) 
              widget_control, st.ty2, set_val=strtrim(yy1,2) 
              widget_control, st.tdx, set_val=strtrim(dxx0,2) 
              widget_control, st.tdy, set_val=strtrim(dyy0,2) 
            endelse 
          endif   ; stat.
        endwhile 
 
        ;-------  Convert box to desired coordinates  --------------- 
	boxcon,x,y,dx,dy,x0,y0,dx0,dy0, /from_dev,$
	  dev=dev,norm=norm,data=data
 
        ;--------  Remove status display widget  ------- 
        if (not keyword_set(nostat)) and (not keyword_set(keep)) then begin 
          widget_control, st.top, /dest 
        endif
 
        ;--------  Erase box  -----------
        tvbox, x, y, dx, dy, -1,echo=win2
 
        return 
  
        end
