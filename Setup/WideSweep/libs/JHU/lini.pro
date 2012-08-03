;-------------------------------------------------------------
;+
; NAME:
;       LINI
; PURPOSE:
;       Interactive line.
; CATEGORY:
; CALLING SEQUENCE:
;       lini, a, b
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA   Use data coordinates (default).
;         /DEVICE Use device coordinates.
;         /NORMAL Use normalized coordinates.
;         /MAP Coordinates are longitude, latitude.
;         THICKNESS=thk  Line thickness.
;         LINESTYLE=sty  Line style.
;         /AZIMUTH  display angle from Y axis clockwise,
;           else angle from X axis CCW.
;         /NOHELP means do not display help box.
;         /AXFIX means fix initial pt A x value.
;         /AYFIX means fix initial pt A y value.
;         /BXFIX means fix initial pt B x value.
;         /BYFIX means fix initial pt B y value.
;         MAG=mag  Magnification window mag value (def=4).
;         /FILL  means use filled symbol for active endpoint marker.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: XOR plot mode is used to display line.
;         Line parameters are displayed.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Feb 22
;       R. Sterner, 2003 May 13 --- added wait to mag window toggle.
;       R. Sterner, 2003 May 13 --- Also positioned help text better.
;       R. Sterner, 2006 Apr 09 --- Reversed Ang and Len in display.
;       R. Sterner, 2006 Apr 09 --- Added /MAP mode.
;       R. Sterner, 2006 Apr 10 --- Fixed default endpoints for /MAP mode..
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro lini, a, b, data=dat0, device=dev0, normal=nrm0, $
	  thickness=thk, linestyle=sty, azimuth=azi, help=hlp, $
	  nohelp=nohelp, axfix=axfix,ayfix=ayfix,bxfix=bxfix,byfix=byfix, $
	  mag=mag, fill=fill,map=map
 
	if keyword_set(hlp) then begin
	  print,' Interactive line.'
	  print,' lini, a, b'
	  print,'   a,b = Line endpoints.                in,out'
	  print,'      If not given defaults are used.'
	  print,' Keywords:'
	  print,'   /DATA   Use data coordinates (default).'
	  print,'   /DEVICE Use device coordinates.'
	  print,'   /NORMAL Use normalized coordinates.'
	  print,'   /MAP Coordinates are longitude, latitude.'
	  print,'   THICKNESS=thk  Line thickness.'
	  print,'   LINESTYLE=sty  Line style.'
	  print,'   /AZIMUTH  display angle from Y axis clockwise,'
	  print,'     else angle from X axis CCW.'
	  print,'   /NOHELP means do not display help box.'
	  print,'   /AXFIX means fix initial pt A x value.'
	  print,'   /AYFIX means fix initial pt A y value.'
	  print,'   /BXFIX means fix initial pt B x value.'
	  print,'   /BYFIX means fix initial pt B y value.'
	  print,'   MAG=mag  Magnification window mag value (def=4).'
	  print,'   /FILL  means use filled symbol for active endpoint marker.'
	  print,' Notes: XOR plot mode is used to display line.'
	  print,'   Line parameters are displayed.'
	  return
	endif
 
	;--------  Defaults  ----------------------------------
	if n_elements(mag) eq 0 then mag = 4
	if n_elements(thk) eq 0 then thk = !p.thick
	if n_elements(sty) eq 0 then sty = !p.linestyle
	flag = 1		; Active point is A (point 1).
	cflag = 1		; Set change flag.
	if keyword_set(fill) then usersym,[1,1,-1,-1,1],[-1,1,1,-1,-1],/fill $
	else usersym,[1,1,-1,-1,1],[-1,1,1,-1,-1]
	ssz = 2			; Symbol size.
	angtxt = 'Angle'
	if keyword_set(azi) then angtxt = 'Azimuth'
	if keyword_set(map) then angtxt = 'Azimuth'
	magmode = 0		; Mag window mode: start off.
	magcrs,/init,state=magstate, mag=mag
 
	;--------  Determine coordinate system  ---------------
	dat = keyword_set(dat0)
	dev = keyword_set(dev0)
	nrm = keyword_set(nrm0)
	if dat+dev+nrm gt 1 then begin
	  print,' Error in lini: set only one of /DATA, /DEVICE, or /NORMAL.'
	  return
	endif
	if dat eq 0 then dat=1-(dev>nrm)	; Def is /data.
 
	;---------  Default endpoints  ------------------------
	if dat then begin		; DATA coordinates.
	  if !x.s(1) eq 0 then begin
	    print,' Error in lini: Data coordinate system not established.'
	    return
	  endif
	  axd = .3*(!x.crange(1)-!x.crange(0))+!x.crange(0)
	  ayd = .3*(!y.crange(1)-!y.crange(0))+!y.crange(0)
	  bxd = .6*(!x.crange(1)-!x.crange(0))+!x.crange(0)
	  byd = .6*(!y.crange(1)-!y.crange(0))+!y.crange(0)
	  if !x.type eq 1 then begin
	    axd = 10^axd
	    bxd = 10^bxd
	  endif
	  if !y.type eq 1 then begin
	    ayd = 10^ayd
	    byd = 10^byd
	  endif
	  if !x.type eq 3 then begin	; Map.
	    tmp = convert_coord([axd,bxd],[ayd,byd],/norm,/data)
	    axd = tmp(0,0)
	    bxd = tmp(0,1)
	    ayd = tmp(1,0)
	    byd = tmp(1,1)
	  endif
	  ltyp = 'Data coordinates'
	endif
	if dev then begin		; DEVICE coordinates.
	  axd = round(.3*!d.x_size)
	  ayd = round(.3*!d.y_size)
	  bxd = round(.6*!d.x_size)
	  byd = round(.6*!d.y_size)
	  ltyp = 'Device coordinates'
	endif
	if nrm then begin		; NORMAL coordinates.
	  axd = .3
	  ayd = .3
	  bxd = .6
	  byd = .6
	  ltyp = 'Normal coordinates'
	endif
	if n_elements(a) ne 2 then a=[axd,ayd]
	if n_elements(b) ne 2 then b=[bxd,byd]
	ax=a(0) & ay=a(1)
	bx=b(0) & by=b(1)
	;---------  Convert to device coordinates  ------------
	if dat then begin
	  tmp = round(convert_coord([ax,bx],[ay,by],/data,/to_dev))
	  ixa=tmp(0,0) & iya=tmp(1,0)
	  ixb=tmp(0,1) & iyb=tmp(1,1)
	endif
	if dev then begin
	  ixa=round(ax) & iya=round(ay)
	  ixb=round(bx) & iyb=round(by)
	endif
	if nrm then begin
	  tmp = round(convert_coord([ax,bx],[ay,by],/norm,/to_dev))
	  ixa=tmp(0,0) & iya=tmp(1,0)
	  ixb=tmp(0,1) & iyb=tmp(1,1)
	endif
 
	;---------  Save initial coordinates  ---------------
	ixa0=ixa & iya0=iya	; Only needed for /*FIX keywords.
	ixb0=ixb & iyb0=iyb
 
	;---------  Set up display board  ---------------
	atxt = strtrim(ax,2)+', '+strtrim(ay,2)
	btxt = strtrim(bx,2)+', '+strtrim(by,2)
	txt = '___________________________________'
	if dat then begin
	  lines = [ltyp,txt,'1','2','3','4','5','6']
	  res = [2,3,4,5,6,7]
	endif
	if dev then begin
	  lines = [ltyp,txt,'1','2','3','4']
	  res = [2,3,4,5]
	endif
	if nrm then begin
	  lines = [ltyp,txt,'1','2','3','4']
	  res = [2,3,4,5]
	endif
	xbb, lines=lines, res=res, nid=nid, wid=wid, title='Line parameters'
	g = widget_info(wid,/geom)
	xoff = g.xoffset
	yoff = g.yoffset+g.ysize
 
	;---------  Help widget  ------------------------
	if not keyword_set(nohelp) then begin
	  xhelp,title='Instructions',$
		['Interactive line',$
		' ',$
		'Move the cursor to one end of the',$
		'   line segment or the middle.',$
	        ' ',$
		'Left button: drag endpoint or',$
		'   middle to a new position.',$
	        ' ',$
		'Middle button: toggle mag window.', $
	        ' ',$
		'Right button: exit.'],xoff=xoff,yoff=yoff, $
		group_leader=wid
	endif
 
	;---------  Set graphics mode  ------------------
	device, get_graphics=gmode0	; Entry mode.
	device, set_graphics=6		; XOR mode.
	tvcrs,ixa,iya
 
	;==========  Main loop  ==========================
	;-------  Plot line and active endpoint  -------------
loop:	plots, [ixa,ixb],[iya,iyb],/dev,thick=thk, linestyl=sty
        case flag of                                    ; Plot active point.
1:        begin
	    plots,ixa,iya,/dev,psym=8,symsize=ssz
	    ast = '*'
	    bst = ' '
	  end
2:        begin
	    plots,ixb,iyb,/dev,psym=8,symsize=ssz
	    ast = ' '
	    bst = '*'
	  end
3:        begin
	    plots,.5*(ixa+ixb),.5*(iya+iyb),/dev,psym=8,symsize=ssz
	    ast = ' '
	    bst = ' '
	  end
	endcase
	empty
 
	;------  Update board with any changes  --------------
	if cflag then begin
	  atxt = strtrim(ax,2)+', '+strtrim(ay,2)
	  btxt = strtrim(bx,2)+', '+strtrim(by,2)
	  dx=bx-ax & dy=by-ay
	  if keyword_set(azi) then $
	    recpol,dy,dx,rr,aa,/deg $
	    else recpol,dx,dy,rr,aa,/deg
	  widget_control, nid(0), set_val=ast+' Ax, Ay = '+atxt
	  widget_control, nid(1), set_val=bst+' Bx, By = '+btxt
	  widget_control, nid(2), set_val=angtxt+' (B from A) = '+strtrim(aa,2)
	  widget_control, nid(3), set_val='Length = '+strtrim(rr,2)
	  if keyword_set(map) then begin
	    if (ax eq bx) and (ay eq by) then begin
	      rr = 0.
	      a1 = 'Undefined'
	    endif else begin
	      ell_ll2rb,ax,ay,bx,by,rr,a1,a2
	    endelse
	    widget_control, nid(2), set_val=angtxt+' (A to B) = '+ $
	      strtrim(a1,2)
            widget_control, nid(3),set_val='Feet = '+ $
	      strtrim(rr*3.280839895D0,2)
	    widget_control, nid(4), set_val='Miles = '+ $
	      strtrim(rr*6.213711922D-4,2)
	    widget_control, nid(5), set_val='Naut miles = '+ $
	      strtrim(rr*5.399568035D-4,2)
	  endif else begin
	    if dat then begin
	      if dx eq 0 then begin
	        slp = 'undefined'
	        intr = 'undefined'
	      endif else begin
	        slp = float(dy)/dx
	        intr = ay-slp*ax
	      endelse
	      widget_control, nid(4), set_val='Slope = '+strtrim(slp,2)
	      widget_control, nid(5), set_val='Intercept = '+strtrim(intr,2)
	    endif
          endelse
	  cflag = 0
	endif
 
        ;----------------  Cursor  -------------------------
	if magmode eq 0 then begin
          cursor, ix, iy, 2, /dev                      ; Read cursor position.
	endif else begin
          magcrs, ix, iy, /dev, state=magstate         ; Use mag window.
	endelse
 
        ;---------------  Exit  --------------
        if !mouse.button gt 2 then goto, done           ; Done.
 
	;-------  Toggle mag mode  -------------
	if !mouse.button eq 2 then begin
	  if magmode eq 1 then wdelete,magstate.win
	  magmode = 1-magmode
	  wait, .1
	endif
 
	;-------  Erase line and active endpoint  -------------
	plots, [ixa,ixb],[iya,iyb],/dev,thick=thk, linestyl=sty
        case flag of                                    ; Erase active point.
1:        plots,ixa,iya,/dev,psym=8,symsize=ssz
2:        plots,ixb,iyb,/dev,psym=8,symsize=ssz
3:        plots,.5*(ixa+ixb),.5*(iya+iyb),/dev,psym=8,symsize=ssz
	endcase
	empty
 
	if !mouse.button eq 0 then begin
	  ;--------  Closest point  ------------
	  d2=long(ix-[ixa,ixb,(ixa+ixb)/2.])^2+long(iy-[iya,iyb,(iya+iyb)/2.])^2
	  w = where(d2 eq min(d2))
 
	  ;--------  Activate a point  ---------
          if d2(w(0)) le 400 then begin                   ; Activate point.
            flag2 = w(0)+1                                ; Set active flag.
            if flag2 ne flag then begin                   ; Did flag change?
              flag = flag2
              cflag = 1
            endif
          endif
	endif	; !mouse
 
	;--------  Move point  --------------
        if !mouse.button eq 1 then begin                ; Move point.
          case flag of
1:          begin
              ixa = ix
              iya = iy
            end
2:          begin
              ixb = ix
              iyb = iy
            end
3:	    begin
	      dx = round(ix-(ixa+ixb)/2.)
	      dy = round(iy-(iya+iyb)/2.)
	      ixa = ixa+dx
	      iya = iya+dy
	      ixb = ixb+dx
	      iyb = iyb+dy
	    end
          endcase
          cflag = 1                                     ; Set change flag.
        endif ; !mouse
 
	;-------  Handle fixed coordinates  ------------
	if keyword_set(axfix) then ixa=ixa0
	if keyword_set(ayfix) then iya=iya0
	if keyword_set(bxfix) then ixb=ixb0
	if keyword_set(byfix) then iyb=iyb0
 
	;--------  Convert back to requested coordinate system  ------
	if dat then begin
	  tmp = convert_coord([ixa,ixb],[iya,iyb],/dev,/to_data)
	  ax=tmp(0,0) & ay=tmp(1,0)
	  bx=tmp(0,1) & by=tmp(1,1)
	endif
	if dev then begin
	  ax=ixa & ay=iya
	  bx=ixb & by=iyb
	endif
	if nrm then begin
	  tmp = convert_coord([ixa,ixb],[iya,iyb],/dev,/to_norm)
	  ax=tmp(0,0) & ay=tmp(1,0)
	  bx=tmp(0,1) & by=tmp(1,1)
	endif
 
	goto, loop
	;====================================================
 
	;------------  Done  ---------------
done:	plots, [ixa,ixb],[iya,iyb],/dev,thick=thk, linestyl=sty	; Erase line.
        case flag of                                    ; Erase active point.
1:        plots,ixa,iya,/dev,psym=8,symsize=ssz
2:        plots,ixb,iyb,/dev,psym=8,symsize=ssz
3:        plots,.5*(ixa+ixb),.5*(iya+iyb),/dev,psym=8,symsize=ssz
	endcase
	device, set_graphics=gmode0				; Restore mode.
	a = [ax,ay]
	b = [bx,by]
	widget_control,/dest,wid
	if magmode eq 1 then wdelete,magstate.win
 
	return
	end
