;-------------------------------------------------------------
;+
; NAME:
;       XLINE
; PURPOSE:
;       Interactive line on image display.
; CATEGORY:
; CALLING SEQUENCE:
;       xline
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA   display data coordinates (default).
;         /DEVICE display device coordinates.
;         /NORMAL display normalized coordinates.
;         START=[x1,y1] Specified line start point (def=[0,0]).
;         STOP=p2  Returned line stop point ([x,y]).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Feb 21
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xline, help=hlp, data=data, normal=norm, device=dev, $
	  start=p1, stop=p2
 
	if keyword_set(hlp) then begin
	  print,' Interactive line on image display.'
	  print,' xline'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   /DATA   display data coordinates (default).'
	  print,'   /DEVICE display device coordinates.'
	  print,'   /NORMAL display normalized coordinates.'
	  print,'   START=[x1,y1] Specified line start point (def=[0,0]).'
	  print,'   STOP=p2  Returned line stop point ([x,y]).'
	  return
	endif
 
	typ = 'Data'
	if keyword_set(norm) then typ = 'Normalized'
	if keyword_set(dev) then typ = 'Device'
	if strupcase(strmid(typ,0,2)) eq 'DA' then begin
	  if !x.s(1) eq 0 then begin
	    print,' Data coordinate system not established.'
	    return
	  endif
	endif
	if n_elements(p1) eq 0 then p1 = [0.,0.]
	x0 = p1(0)	; Initial last point.
	y0 = p1(1)
	x1 = x0		; Start point.
	y1 = y0
 
	top = widget_base(/column,title=' ')
	id = widget_label(top,val=typ+' coordinates')
	id = widget_label(top,val='    Press any button to exit    ')
	id = widget_label(top,val=' ')
 
	widget_control, top, /real
	!err = 0
	device,set_graph=6
 
	while !err eq 0 do begin
	  cursor, x, y, data=data, norm=norm, dev=dev, /change
	  plots, [x1,x0],[y1,y0],data=data, norm=norm, dev=dev	; Erase old.
	  plots, [x1,x],[y1,y],data=data, norm=norm, dev=dev	; Plot new.
	  x0 = x	; Remember old.
	  y0 = y
	  widget_control, id, set_val=strtrim(string(x,y),2)
	endwhile
 
	plots, [x1,x0],[y1,y0],data=data, norm=norm, dev=dev	; Erase old.
	widget_control, top, /dest
	p2 = [x,y]
	device,set_graph=3
 
	return
	end
