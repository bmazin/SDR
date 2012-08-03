;-------------------------------------------------------------
;+
; NAME:
;       XDATE
; PURPOSE:
;       Widget based date selection tool.
; CATEGORY:
; CALLING SEQUENCE:
;       xdate
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=tt   Widget title (def="Select date").
;         YLIST=ylist  Allowed list of years.
;           Default is +/- 5 years from default year.
;         MLIST=mlist  Allowed list of months.
;           Default is all months.
;         YDEF=ydef  Default year.
;         MDEF=mdef  Default month.
;         DDEF=ddef  Default day.
;           Defaults are current.  If negative lock selection.
;         YOUT=yout  Returned year.
;         MOUT=mout  Returned month.
;         DOUT=dout  Returned day.
;           These are null strings for CANCEL.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 10 Nov, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xdate_event, ev
 
	widget_control, ev.id, get_uval=uval
	name = strupcase(strmid(uval,0,1))
	val = strmid(uval,1,99)
	widget_control, ev.top, get_uval=d
 
	if name eq 'D' then return
 
	if name eq 'O' then begin
	  widget_control, d.id_y, get_val=ytxt
	  widget_control, d.id_m, get_val=mtxt
	  mtxt = getwrd(mtxt)
	  widget_control, d.id_d, get_val=dtxt
	  widget_control, d.res, set_uval=ytxt+' '+mtxt+' '+strtrim(dtxt,2)
	  widget_control, ev.top, /dest
	  return
	endif
 
	if name eq 'C' then begin
	  widget_control, ev.top, /dest
	  widget_control, d.res, set_uval=' '
	  return
	endif
 
	if name eq 'Y' then begin
	  widget_control, d.id_y, set_val=val
	endif
 
	if name eq 'M' then begin
	  widget_control, d.id_m, set_val=val
	endif
 
	;------  Update day slider  ---------
	widget_control, d.id_y, get_val=ytxt
	widget_control, d.id_m, get_val=mtxt
	widget_control, d.id_d, get_val=dtxt
	mmax = monthdays(ytxt+0,mtxt+0)
	widget_control, /dest, d.id_d
	id = widget_slider(d.b_day, xsize=200, min=1, max=mmax, uval='DAY')
	widget_control, id, set_val=(dtxt+0)<mmax
	d.id_d = id
	widget_control, ev.top, set_uval=d
 
	return
	end
 
;=====================================================================
;	xdate.pro = Widget date selection tool
;	R. Sterner, 10 Nov, 1993
;=====================================================================
 
	pro xdate, title=title, mlist=mlist, ylist=ylist, $
	  mdef=mdef, ddef=ddef, ydef=ydef, number=number, $
	  mout=mout, dout=dout, yout=yout, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Widget based date selection tool.'
	  print,' xdate'
	  print,' Keywords:'
	  print,'   TITLE=tt   Widget title (def="Select date").'
	  print,'   YLIST=ylist  Allowed list of years.'
	  print,'     Default is +/- 5 years from default year.'
	  print,'   MLIST=mlist  Allowed list of months.'
	  print,'     Default is all months.'
	  print,'   YDEF=ydef  Default year.'
	  print,'   MDEF=mdef  Default month.'
	  print,'   DDEF=ddef  Default day.'
	  print,'     Defaults are current.  If negative lock selection.'
	  print,'   YOUT=yout  Returned year.'
	  print,'   MOUT=mout  Returned month.'
	  print,'   DOUT=dout  Returned day.'
	  print,'     These are null strings for CANCEL.'
	  return
	endif
 
	date2ymd,systime(),y0,m0,d0
	if n_elements(ydef) eq 0 then ydef = y0
	if n_elements(mdef) eq 0 then mdef = m0
	if n_elements(ddef) eq 0 then ddef = d0
	ydef=fix(ydef) & mdef=fix(mdef)
	if n_elements(ylist) eq 0 then ylist = abs(ydef)+indgen(10)-5
	if n_elements(mlist) eq 0 then mlist = indgen(12)+1
	if n_elements(title) eq 0 then title='Select date'
 
	;------  Lay out widget  ----------
	top = widget_base(/column,title=' ')
	id = widget_label(top,val=title)
	but = widget_base(top, /row)
	b = widget_button(but, val='OK',uval='OK')
	b = widget_button(but, val='Cancel',uval='CANCEL')
	;-------  Year  ---------
	id = widget_base(top,/row)
	b0 = widget_button(id,val='Year',menu=2)
	for i=0,n_elements(ylist)-1 do begin
	  ytxt = strtrim(ylist(i),2)
	  b = widget_button(b0,value=ytxt,uval='Y'+ytxt)
	endfor
	id_y = widget_label(id,val=strtrim(abs(ydef),2))
	if ydef lt 0 then widget_control, b0, sens=0	; Lock.
	;-------  Month  ---------
	mname = monthnames()
	id = widget_base(top,/row)
	b0 = widget_button(id,val='Month',menu=2)
	for i=0,n_elements(mlist)-1 do begin
	  mtxt = strtrim(mlist(i),2)+'  '+mname(mlist(i))
	  b = widget_button(b0,value=mtxt,uval='M'+mtxt)
	endfor
	mtxt = strtrim(abs(mdef)<12>0,2)+'  '+mname(abs(mdef)<12>0)
	id_m = widget_label(id,val=mtxt)
	if mdef lt 0 then widget_control, b0, sens=0	; Lock.
	;-------  Day  ---------
	mmax = monthdays(abs(ydef), abs(mdef))
	b_day = widget_base(top,/row)
	b0 = widget_label(b_day,val='Day')
	id_d = widget_slider(b_day, xsize=200, min=1, max=mmax, uval='DAY')
	widget_control, id_d, set_val=abs(ddef)<mmax>1
	if ddef lt 0 then widget_control, id_d, sens=0	; Lock.
 
	;------  Package and store needed info  ------------
	res = widget_base()
	data = {id_y:id_y, id_m:id_m, id_d:id_d, b_day:b_day, res:res}
	widget_control, top, set_uval=data
 
	;------  realize widget  -----------
	widget_control, top, /real
 
	;------  Event loop  ---------------
	xmanager, 'xdate', top
 
	;------  Get result  ---------------
	widget_control, res, get_uval=out
	yout = getwrd(out,0)
	mout = getwrd('',1)
	dout = getwrd('',2)
 
	return
	end
