;-------------------------------------------------------------
;+
; NAME:
;       MOVTXT
; PURPOSE:
;       Interactively position text and list xyouts statement.
; CATEGORY:
; CALLING SEQUENCE:
;       movtxt, txt
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA use data coordinates (def).
;         /DEVICE use device coordinates.
;         /NORMAL use normalized coordinates.
; OUTPUTS:
; COMMON BLOCKS:
;       movtxt_com
; NOTES:
;       Notes: click mouse button for options (right button exits).
;         May change text size and angle.
;         May list xyouts call to plot text in current position.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Nov 1.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro movtxt, txt, data=data,device=dev,normal=norm, help=hlp
 
	common movtxt_com, csz, ang, x, y, mx, my, clr, bld
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Interactively position text and list xyouts statement.'
	  print,' movtxt, txt'
	  print,'   txt = Text to position.'
	  print,' Keywords:'
	  print,'   /DATA use data coordinates (def).'
	  print,'   /DEVICE use device coordinates.'
 	  print,'   /NORMAL use normalized coordinates.'
	  print,' Notes: click mouse button for options (right button exits).'
	  print,'   May change text size and angle.'
	  print,'   May list xyouts call to plot text in current position.'
	  return
	endif
 
	device, set_graph=6
 
	;------  Set initial values  ---------
	if n_elements(data) eq 0 then data=0
	if n_elements(dev) eq 0 then dev=0
	if n_elements(norm) eq 0 then norm=0
	if (data+dev+norm) eq 0 then data=1
	if n_elements(csz) eq 0 then csz = 2.
	if n_elements(ang) eq 0 then ang = 0.
	if n_elements(mx) eq 0 then mx = 0
	if n_elements(my) eq 0 then my = 0
	if n_elements(clr) eq 0 then clr = -1
	if n_elements(bld) eq 0 then bld = -1
 
	;--------  Check for data coordinates  --------
	if keyword_set(data) then begin
	  if total(abs(!x.crange)) eq 0 then begin
	    print,' Error in movtxt: Data coordinates not established yet.'
	    return
	  endif
	endif
 
	!err = 0
	xlst = -1000
	ylst = -1000
	alst = 0.
	slst = 1.
	def = ' '
 
	tvcrs, mx, my
 
	while !err ne 4 do begin
 
	!err = 0
	while !err eq 0 do begin
	  cursor, x, y, data=data,dev=dev,norm=norm,/change
	  xyouts, xlst,ylst,data=data,dev=dev,norm=norm,txt,chars=slst, $
	    col=clr,ori=alst
	  xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz,  $
	    col=clr,ori=ang
	  xlst=x
	  ylst=y
	  alst = ang
	  slst = csz
	endwhile
	xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz,  $
	    col=clr,ori=ang
 
	if !err ne 4 then begin
	  xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz,  $
	    col=clr,ori=ang
	  xlst = x
	  ylst = y
	  alst = ang
	  slst = csz
	  !err = 0
	  opt = xoption(['Quit','Continue','Code','Size','Angle','Color',$
	    'Bold'],def=def,val=['Q',' ','CD','S','A','CL','B'])
	  if opt eq 'Q' then begin
	    xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz,  $
	    col=clr,ori=ang
	    goto, done
	  endif
	  if opt eq 'B' then begin
	    tmp = ''
	    defin = commalist(bld)
	    read,' Enter new text bold value(s) (def='+defin+'): ',tmp
	    if tmp eq '' then tmp = defin
	    wordarray,repchr(tmp,','),tmp2 & bld = tmp2+0
	    xyouts,xlst,ylst,data=data,dev=dev,norm=norm,txt,chars=slst, $
	      col=clr, ori=alst
	    xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz,  $
	      col=clr, ori=ang
	    def = opt
	  endif
	  if opt eq 'CL' then begin
	    tmp = ''
	    defin = commalist(clr)
	    read,' Enter new text color(s) (def='+defin+'): ',tmp
	    if tmp eq '' then tmp = defin
	    wordarray,repchr(tmp,','),tmp2 & clr = tmp2+0
	    xyouts,xlst,ylst,data=data,dev=dev,norm=norm,txt,chars=slst, $
	      col=clr, ori=alst
	    xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz,  $
	      col=clr, ori=ang
	    def = opt
	  endif
	  if opt eq 'S' then begin
	    tmp = ''
	    read,' Enter new text size (def='+strtrim(csz,2)+'): ',tmp
	    if tmp eq '' then tmp = csz
	    csz = tmp + 0.
	    xyouts,xlst,ylst,data=data,dev=dev,norm=norm,txt,chars=slst, $
	      col=clr, ori=alst
	    xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz,  $
	      col=clr, ori=ang
	    xlst=x
	    ylst=y
	    alst = ang
	    slst = csz
	    def = opt
	  endif
	  if opt eq 'A' then begin
	    tmp = ''
	    read,' Enter new text angle (def='+strtrim(ang,2)+'): ',tmp
	    if tmp eq '' then tmp = ang
	    ang = tmp + 0.
	    xyouts,xlst,ylst,data=data,dev=dev,norm=norm,txt,chars=slst, $
	      col=clr, ori=alst
	    xyouts, x, y, data=data,dev=dev,norm=norm, txt, chars=csz,  $
	      col=clr, ori=ang
	    xlst=x
	    ylst=y
	    alst = ang
	    slst = csz
	    def = opt
	  endif
	  ;-------  Generate IDL code  -------------
	  if opt eq 'CD' then begin
	    def = opt
	    ;------  Coordinate system: /data,/dev,/norm  ----------
	    if keyword_set(data) then begin
	      sys = ''
	      xy = ','+strtrim(x,2)+','+strtrim(y,2)
	    endif
	    if keyword_set(dev) then begin
	      sys=',/dev'
	      xy = ','+strtrim(fix(x),2)+','+strtrim(fix(y),2)
	    endif
	    if keyword_set(norm) then begin
	      sys=',/norm'
	      xy = ','+strtrim(x,2)+','+strtrim(y,2)
	    endif
	    ;-------  Size  ---------
	    tsz = ''
	    if csz ne 0 then tsz = ',chars='+strtrm2(csz,2,'0')
	    ;-------  Angle  ---------
	    tang = ''
	    if ang ne 0 then tang = ',orient='+strtrm2(ang,2,'0')
	    ;-------  Color and Bold  ---------
	    lstclr = n_elements(clr)-1
	    lstbld = n_elements(bld)-1
	    n = lstclr > lstbld
	    rout = 'xyouts'
	    if bld(0) gt 1 then rout = 'xyoutb'
	    print,' IDL code:'
	    for i=0,n do begin
	      tclr = ''
	      cc = clr(i<lstclr)
	      if cc ge 0 then tclr=',col='+strtrim(cc,2)
	      tbld = ''
	      bb = bld(i<lstbld)
	      if bb gt 1 then tbld=',bold='+strtrim(bb,2)
	      print,'	'+rout+sys+xy+",'"+txt+"'"+tsz+tang+tclr+tbld
	    endfor
	  endif
	  tvcrs, !mouse.x,!mouse.y
	endif
	endwhile  ; !err ne 4.
 
done:
	mx = !mouse.x
	my = !mouse.y
	device, set_graph=3
	return
	end
