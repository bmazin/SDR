;-------------------------------------------------------------
;+
; NAME:
;       XGETVALS_DEMO
; PURPOSE:
;       Demonstration of the xgetvals routine.
; CATEGORY:
; CALLING SEQUENCE:
;       xgetvals_demo
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         DEFAULTS=def Initial values.  String array just like val.
;         VALUES=val  All xgetvals values returned in a string array.
;         STRUCT=s  All xgetvals values returned in a structure.
;         EXIT=ex  Exit code: 0=OK, -1=Cancel.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: See the source of this demo routine for an example
;         of how to use xgetvals.  Not all options are used here.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Sep 01
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xgetvals_demo_mresize, s, wid
 
	tt = ['Left-Click to move nearest master area corner.',$
	      'Right-click when done.']
	flag = 0		; Change flag.
	xmess,tt,wid=id,/nowait
	t = convert_coord(s.mlonc-s.mwid/2.,s.mlatc-s.mhgt/2.,/to_dev)
	tvcrs,t(0),t(1)
 
	while 1 do begin
	cursor,xx,yy
	if !mouse.button ne 1 then begin
	  widget_control,id,/dest
	  if not flag then $
	    print,' Master area not changed.' $
	  else print,' Master area updated.'
	  return
	endif
	flag = 1
	xc = s.mlonc + 0.	; Master center.
	yc = s.mlatc + 0.
	dx2 = s.mwid/2.		; Master half size.
	dy2 = s.mhgt/2.
	x0 = xc - dx2		; SW corner.
	y0 = yc - dy2
	x1 = xc - dx2		; NW corner.
	y1 = yc + dy2
	x2 = xc + dx2		; NE corner.
	y2 = yc + dy2
	x3 = xc + dx2		; SE corner.
	y3 = yc - dy2
	x = [x0,x1,x2,x3]	; All corners.
	y = [y0,y1,y2,y3]
	d2 = (x-xx)^2 + (y-yy)^2 ; Click dist^2.
	w = where(d2 eq min(d2)) ; Closest corner.
	iw = w(0)		 ; Index of closest corner.
	case iw of		 ; Update closest corner coordinates.
0:	begin	; SW.
	  xc = 0.5*(xx+x3)	; New center.
	  yc = 0.5*(yy+y1)
	  dx = x3 - xx		; New size.
	  dy = y1 - yy
	end
1:	begin	; NW.
	  xc = 0.5*(xx+x2)	; New center.
	  yc = 0.5*(yy+y0)
	  dx = x2 - xx		; New size.
	  dy = yy - y0
	end
2:	begin	; NE.
	  xc = 0.5*(xx+x1)	; New center.
	  yc = 0.5*(yy+y3)
	  dx = xx - x1		; New size.
	  dy = yy - y3
	end
3:	begin	; SE.
	  xc = 0.5*(xx+x0)	; New center.
	  yc = 0.5*(yy+y2)
	  dx = xx - x0		; New size.
	  dy = y2 - yy
	end
	endcase
	s.mlonc = strtrim(string(xc,form='(F9.4)'),2)
	s.mlatc = strtrim(string(yc,form='(F9.4)'),2)
	s.mwid = strtrim(string(dx,form='(F9.4)'),2)
	s.mhgt = strtrim(string(dy,form='(F9.4)'),2)
	xgetvals_demo_refr, s, wid
	win_redirect
	xgetvals_demo_updat, s, wid
	win_copy
	endwhile
 
	end
 
 
	;-----------------------------------------------
	;  xgetvals_demo_mrecen = Recenter master.
	;-----------------------------------------------
	pro xgetvals_demo_mrecen, s, wid
 
	tt = ['Left-Click on new master area center.',$
	      'Right-click when done.']
	flag = 0		; Change flag.
	xmess,tt,wid=id,/nowait
	t = convert_coord(s.mlonc,s.mlatc,/to_dev)
	tvcrs,t(0),t(1)
 
	while 1 do begin
	cursor,xx,yy
	if !mouse.button ne 1 then begin
	  widget_control,id,/dest
	  if not flag then $
	    print,' Master center not changed.' $
	  else print,' Master center updated.'
	  return
	endif
	flag = 1
	mlonc = strtrim(string(xx,form='(F9.4)'),2)
	mlatc = strtrim(string(yy,form='(F9.4)'),2)
	s.mlonc = mlonc
	s.mlatc = mlatc
	xgetvals_demo_refr, s, wid
	win_redirect
	xgetvals_demo_updat, s, wid
	win_copy
	endwhile
 
	end
 
 
	;-----------------------------------------------
	;  xgetvals_demo_zin = Zoom In.
	;-----------------------------------------------
	pro xgetvals_demo_zin, s, wid
 
	scl = s.scl/1.25
	scl = strtrim(string(scl,form='(G9.4)'),2)
	s.scl = scl
	xgetvals_demo_refr, s, wid
	win_redirect
	xgetvals_demo_updat, s, wid
	win_copy
 
	end
 
	;-----------------------------------------------
	;  xgetvals_demo_zout = Zoom Out.
	;-----------------------------------------------
	pro xgetvals_demo_zout, s, wid
 
	scl = s.scl*1.25
	scl = strtrim(string(scl,form='(G9.4)'),2)
	s.scl = scl
	xgetvals_demo_refr, s, wid
	win_redirect
	xgetvals_demo_updat, s, wid
	win_copy
 
	end
 
	;-----------------------------------------------
	;  xgetvals_demo_refr = Refresh text areas
	;    from updated structure.
	;-----------------------------------------------
	pro xgetvals_demo_refr, s, wid
	  tags = tag_names(s)
	  n = n_elements(tags)
	  for i=0,n-1 do begin
	    widget_control, wid(i),set_val=s.(i)
	  endfor
	end
 
	;-----------------------------------------------
	;  xgetvals_demo_recen = Recenter map.
	;-----------------------------------------------
	pro xgetvals_demo_recen, s, wid
 
	tt = ['Left-Click to move map center.',$
	      'Right-click when done.']
	flag = 0		; Change flag.
	xmess,tt,wid=id,/nowait
	t = convert_coord(s.lonc,s.latc,/to_dev)
	tvcrs,t(0),t(1)
 
	while 1 do begin
	cursor,xx,yy
	if !mouse.button ne 1 then begin
	  widget_control,id,/dest
	  if not flag then $
	    print,' Map center not changed.' $
	  else print,' Map center updated.'
	  return
	endif
	flag = 1		; Change flag.
	lonc = strtrim(string(xx,form='(F9.4)'),2)
	latc = strtrim(string(yy,form='(F9.4)'),2)
	s.lonc = lonc
	s.latc = latc
	xgetvals_demo_refr, s, wid
	win_redirect
	xgetvals_demo_updat, s, wid
	win_copy
	endwhile
 
	end
 
	;-----------------------------------------------
	;  xgetvals_demo_updat2 = Display map with latest values.
	;  Needed just to wrap the call in the
	;  win_redirect, win_copy pair to avoid
	;  screen flicker.
	;-----------------------------------------------
	pro xgetvals_demo_updat2, s, wid
 
	win_redirect
	xgetvals_demo_updat, s, wid
	win_copy
 
	end
 
	;-----------------------------------------------
	;  xgetvals_demo_updat = Display map with latest values.
	;-----------------------------------------------
	pro xgetvals_demo_updat, s, wid
 
	erase,-1
	wshow
	mlon1 = s.mlonc - s.mwid/2.
	mlon2 = s.mlonc + s.mwid/2.
	mlat1 = s.mlatc - s.mhgt/2.
	mlat2 = s.mlatc + s.mhgt/2.
	map_set,s.latc,s.lonc,scale=s.scl,/cont,/usa, $
	  col=0,/noerase,/lambert,/horizon
	map_latlng_rect,mlon1,mlon2,mlat1,mlat2,col=255,thick=2
	plots,s.mlonc,s.mlatc,psym=1,col=255
 
	end
 
	;-----------------------------------------------
	;  xgetvals_demo = Demo of xgetvals.
	;-----------------------------------------------
	pro xgetvals_demo, values=val, struct=s, exit=ex, $
	  defaults=def, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Demonstration of the xgetvals routine.'
	  print,' xgetvals_demo'
	  print,'   All args are optional keywords.'
	  print,' Keywords:'
	  print,'   DEFAULTS=def Initial values.  String array just like val.'
	  print,'   VALUES=val  All xgetvals values returned in a string array.'
	  print,'   STRUCT=s  All xgetvals values returned in a structure.'
	  print,'   EXIT=ex  Exit code: 0=OK, -1=Cancel.'
	  print,' Note: See the source of this demo routine for an example'
	  print,'   of how to use xgetvals.  Not all options are used here.'
	  return
	endif
 
	lab = ['Lon center:','Lat center:', 'Scale:', $
	       'Master name:', $
	       'Lon center:','Lon center:', $
	       'Width (deg):','Height (deg):']
	tag = ['lonc','latc','scl', $
	       'mst', $
	       'mlonc','mlatc', $
	       'mwid','mhgt']
	if n_elements(def) eq 0 then begin
	  def = ['-98','37','4E7', $
	         'AREA_1', $
	         '-98','37',$
	         '10','10']
	endif
	row = [1,1,2,3,4,4,5,5]
	hd = ['1 / Map controls:','3 / Master Area:']
	actlab = ['Update Map','Recenter Map','Zoom In','Zoom Out', $
	  'Recenter Master','Resize Master']
	actpro = ['xgetvals_demo_updat2','xgetvals_demo_recen', $
	  'xgetvals_demo_zin','xgetvals_demo_zout', $
	  'xgetvals_demo_mrecen','xgetvals_demo_mresize']
	tt = ['Use the entry areas and buttons below', $
	      'to select a Master Area',' ']
 
	xgetvals, title=tt, $
	  lab=lab,def=def,row=row, head=hd, $
	  val=val, tags=tag, struct=s, $
	  act_pro=actpro, act_lab=actlab,act_col=3, $
	  exit=ex, init_pro='xgetvals_demo_updat'
 
	end
