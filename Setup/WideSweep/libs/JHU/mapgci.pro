;-------------------------------------------------------------
;+
; NAME:
;       MAPGCI
; PURPOSE:
;       Interactive great circle on a map.
; CATEGORY:
; CALLING SEQUENCE:
;       mapgci, a, b
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         UNITS=unt  Units of displayed length:
;           'kms'     Default.
;           'miles'   Statute miles.
;           'nmiles'  Nautical miles.
;           'feet'    Feet.
;           'yards'   Yards.
;           'degrees' Degrees.
;           'radians' Radians.
;         THICKNESS=thk  Line thickness.
;         LINESTYLE=sty  Line style.
;         /NOHELP means do not display help box.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       NOTES=notes_txt Extra text string or array to add
;         after help text (def=none).
;       Notes: XOR plot mode is used to display line.
;         Line parameters are displayed.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Mar 5
;       R. Sterner, 2002 Jun 28 --- Cleaned up a bit.
;       R. Sterner, 2002 Sep 03 --- Added NOTES=txt and moved from old lib.
;       R. Sterner, 2003 Dec 29 --- Fixed default line, added some help text.
;       R. Sterner, 2005 Jul 26 --- Step size fix.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro mapgci, a, b, thickness=thk, linestyle=sty, help=hlp, $
	  nohelp=nohelp, units=units, notes=notes_txt, title=ttl
 
	if keyword_set(hlp) then begin
	  print,' Interactive great circle on a map.'
	  print,' mapgci, a, b'
	  print,'   a = [long_A,lat_A] Great Circle start.  in,out'
	  print,'   b = [long_B,lat_B] Great Circle end.    in,out'
	  print,'      If not given defaults are used.'
	  print,' Keywords:'
          print,'   UNITS=unt  Units of displayed length:'
          print,"     'kms'     Default."
          print,"     'miles'   Statute miles."
          print,"     'nmiles'  Nautical miles."
          print,"     'feet'    Feet."
          print,"     'yards'   Yards."
          print,"     'degrees' Degrees."
          print,"     'radians' Radians."
	  print,'   THICKNESS=thk  Line thickness.'
	  print,'   LINESTYLE=sty  Line style.'
	  print,'   /NOHELP means do not display help box.'
	  print,'   NOTES=notes_txt Extra text string or array to add'
	  print,'     after help text (def=none).'
	  print,' Notes: XOR plot mode is used to display line.'
	  print,'   Line parameters are displayed.'
	  return
	endif
 
	;--------  Defaults  ----------------------------------
	if n_elements(thk) eq 0 then thk = !p.thick
	if n_elements(sty) eq 0 then sty = !p.linestyle
	flag = 1		; Active point is A (point 1).
	cflag = 1		; Set change flag.
	usersym,[1,1,-1,-1],[-1,1,1,-1],/fill
	ssz = 2			; Symbol size.
	magmode = 0		; Mag window mode: start off.
	magcrs,/init,state=magstate, mag=3
	if n_elements(notes_txt) eq 0 then notes_txt = ''
	if n_elements(ttl) eq 0 then ttl = 'Instructions'
 
	;---------  Default endpoints  ------------------------
	if !x.type ne 3 then begin
	  print,' Error in mapgci: invalid coordinate system for this routine.'
	  return
	endif
	dx = !map.ll_box(3)-!map.ll_box(1)
	dy = !map.ll_box(2)-!map.ll_box(0)
	axd = !map.ll_box(1) + .333*dx
	ayd = !map.ll_box(0) + .333*dy
	bxd = !map.ll_box(3) - .333*dx
	byd = !map.ll_box(2) - .333*dy
	if n_elements(a) ne 2 then a=[axd,ayd]
	if n_elements(b) ne 2 then b=[bxd,byd]
	ax=a(0) & ay=a(1)
	bx=b(0) & by=b(1)
 
        ;---------  Deal with units  ---------------
        if n_elements(units) eq 0 then units='kms'
        un = strlowcase(strmid(units,0,2))
        case un of      ; Convert distance on earth's surface to radians.
'km':   begin
          cf = 1.56956e-04      ; Km/radian.
          utxt = 'kms'
        end
'mi':   begin
          cf = 2.52595e-04      ; Miles/radian.
          utxt = 'miles'
        end
'nm':   begin
          cf = 2.90682e-04      ; Nautical mile/radian.
          utxt = 'nautical miles'
        end
'fe':   begin
          cf = 4.78401e-08      ; Feet/radian.
          utxt = 'feet'
        end
'ya':   begin
          cf = 1.43520e-07      ; Yards/radian.
          utxt = 'yards'
        end
'de':   begin
          cf = 0.0174532925     ; Degrees/radian.
          utxt = 'degrees'
        end
'ra':   begin
          cf = 1.0              ; Radians/radian.
          utxt = 'radians'
        end
else:   begin
          print,' Error in mapgci: Unknown units: '+units
          print,'   Aborting.'
          return
        end
        endcase
 
	;---------  Initial circle  ---------------------
	ll2rb,ax,ay,bx,by,rr,aa,/deg			; Find range & bearing.
	tmp = convert_coord([ax,bx],[ay,by],/data,/to_dev)
	ixtmp = tmp(0,*)
	iytmp = tmp(1,*)
	dix = ixtmp(1)-ixtmp(0)
	diy = iytmp(1)-iytmp(0)
	irr = sqrt(dix^2. + diy^2.)
	num = (irr/5.)<100
	step = rr/num
;stop
;	step = (rr/100.)>.1	; Step .1 deg or more.  Too small vanishes.
;	step = (rr/100.)>.01	; Step .1 deg or more.  Too small vanishes.
;	num = round(rr/step)	; Needed steps.
	rb2ll,ax,ay,maken(0,rr,num),aa,gcx,gcy,/deg	; Points along gc.
	xa=gcx(0)     & ya=gcy(0)			; Pt A.
	xb=gcx(num-1) & yb=gcy(num-1)			; Pt B.
	if sign(axd) ne sign(xa) then begin
	  xa = xa-360.
	  xb = xb-360.
	  gcx = gcx-360.
	endif
 
	;---------  Set up display board  ---------------
	atxt = strtrim(ax,2)+', '+strtrim(ay,2)
	btxt = strtrim(bx,2)+', '+strtrim(by,2)
	ltyp = 'Interactive Great Circle'
	txt = '___________________________________'
	lines = [ltyp,txt,'1','2','3','4']
	res = [2,3,4,5]
	xbb, lines=lines, res=res, nid=nid, wid=wid, title='Line parameters'
	g = widget_info(wid,/geom)
	xoff = g.xoffset
	yoff = g.yoffset+g.ysize+5
 
	;---------  Help widget  ------------------------
	if not keyword_set(nohelp) then begin
	  xhelp,wid=hwid,/nowait,xoff=xoff,yoff=yoff,title=ttl,$
		['Interactive Great Circle on a map',$
		' ',$
		'In the map window:',$
		' ',$
		'Move the cursor to one end of the great circle.',$
		'  * indicates the active endpoint in the Line',$
		'    parameters window.',$
	        ' ',$
		'Left button: drag endpoint to a new position.',$
	        ' ',$
		'Middle button: toggle mag window.', $
	        ' ',$
		'Right button: exit.',notes_txt]
	endif else hwid=-1
 
	;---------  Set graphics mode  ------------------
	device, get_graphics=gmode0	; Entry mode.
	device, set_graphics=6		; XOR mode.
	todev,xa,ya,ixa,iya
	tvcrs,ixa,iya
 
	;==========  Main loop  ==========================
	;-------  Plot line and active endpoint  -------------
loop:	plots, gcx,gcy,thick=thk, linestyl=sty
        case flag of                                    ; Plot active point.
1:        begin	;---- A
	    plots,xa,ya,psym=8,symsize=ssz
	    ast = '*'
	    bst = ' '
	  end
2:        begin ;---- B
	    plots,xb,yb,psym=8,symsize=ssz
	    ast = ' '
	    bst = '*'
	  end
	endcase
	empty
 
	;------  Update board with any changes  --------------
	if cflag then begin
	  atxt = strtrim(xa,2)+', '+strtrim(ya,2)
	  btxt = strtrim(xb,2)+', '+strtrim(yb,2)
	  ll2rb,xa,ya,xb,yb,r,a
	  r = r/cf
	  widget_control, nid(0), set_val=ast+' Ax, Ay = '+atxt
	  widget_control, nid(1), set_val=bst+' Bx, By = '+btxt
	  widget_control, nid(2), set_val='Length ('+utxt+') = '+strtrim(r,2)
	  widget_control, nid(3), set_val='Azimuth (A from B) = '+strtrim(a,2)
	  cflag = 0
	endif
 
        ;----------------  Cursor  -------------------------
	repeat begin
	  if magmode eq 0 then begin
            cursor, ix, iy, 2, /dat                      ; Read cursor position.
	  endif else begin
            magcrs, ix, iy, /dat, state=magstate         ; Use mag window.
	  endelse
	endrep until iy le 90
 
        ;---------------  Exit  --------------
        if !mouse.button gt 2 then goto, done           ; Done.
 
	;-------  Toggle mag mode  -------------
	if !mouse.button eq 2 then begin
	  if magmode eq 1 then wdelete,magstate.win
	  magmode = 1-magmode
	  wait, 0.1
	endif
 
	;-------  Erase line and active endpoint  -------------
	plots, gcx,gcy,thick=thk, linestyl=sty
        case flag of                                    ; Erase active point.
1:        plots,xa,ya,psym=8,symsize=ssz
2:        plots,xb,yb,psym=8,symsize=ssz
	endcase
	empty
 
	if !mouse.button eq 0 then begin
	  ;--------  Closest point  ------------
	  tmp = convert_coord([ix,xa,xb],[iy,ya,yb],/data,/to_dev)
	  tx=tmp(0,0) & ty=tmp(1,0)		; Cursor in dev.
	  xx=tmp(0,1:*) & yy=tmp(1,1:*)		; circle ends & mid in dev.
	  d2 = (tx-xx)^2+(ty-yy)^2
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
              xa = ix
              ya = iy
            end
2:          begin
              xb = ix
              yb = iy
            end
          endcase
          cflag = 1                                     ; Set change flag.
        endif ; !mouse
 
	;---------  update circle  ---------------------
	ll2rb,xa,ya,xb,yb,rr,aa,/deg			; Find range & bearing.
	step = (rr/100.)>.01	; Step .01 deg or more.
	num = round(rr/step)	; Needed steps.
	rb2ll,xa,ya,maken(0,rr,num),aa,gcx,gcy,/deg	; Points along gc.
	if sign(axd) ne sign(gcx(0)) then begin
	  gcx = gcx-360.
	endif
 
	goto, loop
	;====================================================
 
	;------------  Done  ---------------
done:	plots,gcx,gcy,thick=thk, linestyl=sty		; Erase line.
        case flag of                                    ; Erase active point.
1:        plots,xa,ya,psym=8,symsize=ssz
2:        plots,xb,yb,psym=8,symsize=ssz
	endcase
	device, set_graphics=gmode0			; Restore mode.
	a = [xa,ya]
	b = [xb,yb]
	widget_control,/dest,wid
	if magmode eq 1 then wdelete,magstate.win
	if hwid ne -1 then widget_control, hwid, /destroy	; Help widget.
 
	return
	end
