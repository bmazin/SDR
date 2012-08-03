;-------------------------------------------------------------
;+
; NAME:
;       XGET_IMGDSC
; PURPOSE:
;       Get image description: type and size
; CATEGORY:
; CALLING SEQUENCE:
;       xget_imgdsc, out
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=tt Title text.
;         OFFSET=off Byte offset into file to start of image (def=0).
;         NX=nx, NY=ny Dimensions of image in pixels (def=512,512).
;         TYPE=typ Text array of allowed data types.
;           Def = ['BYT','INT','LONG']
; OUTPUTS:
;       out = returned image description in a structure.  out
; COMMON BLOCKS:
; NOTES:
;       Note: If Cancel was clicked then the returned structure
;       contains only the exit code and it is -1.  If OK is clicked
;       then the exit code is 0 and the structure also
;       contains offset, nx, ny, and type.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jan 09
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xget_imgdsc_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=s
 
	if uval eq 'OK' then begin
	  widget_control, s.id_off, get_val=off
	  widget_control, s.id_nx, get_val=nx
	  widget_control, s.id_ny, get_val=ny
	  out = {off:off(0), nx:nx(0), ny:ny(0), typ:s.typ, ex:0}
	  widget_control, s.res, set_uval=out
	  widget_control, ev.top, /dest
	  return
	endif
 
	if uval eq 'CAN' then begin
	  out = {ex:-1}
	  widget_control, s.res, set_uval=out
	  widget_control, ev.top, /dest
	  return
	endif
 
	if ev.select eq 0 then return
	s.typ = strmid(uval,4,99)
	widget_control, ev.top, set_uval=s
 
	end
 
 
	;--------------------------------------------------------
	;  Widget layout
	;--------------------------------------------------------
	pro xget_imgdsc, out, offset=off, nx=nx, $
	  ny=ny, title=tt, type=typ, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Get image description: type and size'
	  print,' xget_imgdsc, out'
	  print,'   out = returned image description in a structure.  out'
	  print,' Keywords:'
	  print,'   TITLE=tt Title text.'
	  print,'   OFFSET=off Byte offset into file to start of image (def=0).'
	  print,'   NX=nx, NY=ny Dimensions of image in pixels (def=512,512).'
	  print,'   TYPE=typ Text array of allowed data types.'
	  print,"     Def = ['BYT','INT','LONG']"
	  print,' Note: If Cancel was clicked then the returned structure'
	  print,' contains only the exit code and it is -1.  If OK is clicked'
	  print,' then the exit code is 0 and the structure also'
	  print,' contains offset, nx, ny, and type.'
	  return
	endif
 
	;------  Defaults  ----------
	if n_elements(tt) eq 0 then tt='Enter image description'
	if n_elements(off) eq 0 then off=0
	if n_elements(nx) eq 0 then nx=512
	if n_elements(ny) eq 0 then ny=512
	if n_elements(typ) eq 0 then typ=['BYT','INT','LONG']
 
	;------  Widget layout  ---------
	top = widget_base(/col,title='')
 
	for i=0,n_elements(tt)-1 do id=widget_label(top,val=tt(i),/align_left)
 
	b = widget_base(top,/row)
	id = widget_label(b,val='Image byte offset:')
	id_off = widget_text(b,xsize=10,val=strtrim(off,2),uval='',/edit)
 
	b = widget_base(top,/row)
	id = widget_label(b,val='NX:')
	id_nx = widget_text(b,xsize=5,val=strtrim(nx,2),uval='',/edit)
	id = widget_label(b,val='NY:')
	id_ny = widget_text(b,xsize=5,val=strtrim(ny,2),uval='',/edit)
 
	b = widget_base(top,/col, /exclusive)
	id_ex = lonarr(n_elements(typ))
	for i=0,n_elements(typ)-1 do begin
	  id_ex(i) = widget_button(b,val=typ(i),uval='TYP '+typ(i))
	endfor
	widget_control, id_ex(0), /set_button
 
	b = widget_base(top,/row)
	id = widget_button(b,val='OK',uval='OK')
	id = widget_button(b,val='Cancel',uval='CAN')
 
	;------  Save info  --------------
	res = widget_base()
	s = {id_off:id_off, id_nx:id_nx, id_ny:id_ny, typ:typ(0), res:res}
	widget_control, top, set_uval=s
 
	;------  Activate widget  --------
	widget_control, top, /realize
	xmanager, 'xget_imgdsc', top, /modal
 
	;------  Get returned values  -----
	widget_control, res, get_uval=out
	widget_control, res, /dest
 
	end
