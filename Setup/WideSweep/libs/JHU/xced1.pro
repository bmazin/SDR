;-------------------------------------------------------------
;+
; NAME:
;       XCED1
; PURPOSE:
;       Simple widget to edit a single color table entry.
; CATEGORY:
; CALLING SEQUENCE:
;       xced1, index
; INPUTS:
;       index = color table index to edit.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=txt  Title text to display.
;         /HSV  means work in Hue, Saturation, and Value
;           coordinates (def=Red, Green, Blue).
;         GROUP_LEADER=grp  Assign a group leader to this
;           widget.  When the widget with ID grp is destroyed
;           this widget is also.
;         /WAIT  means wait for returned result.
;         EXIT_CODE=excode Exit code: 0=Done, 1=Cancel.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 29 Oct, 1993
;       R. Sterner, 1995 Mar 2 --- Added /WAIT.
;       R. Sterner, 1995 Mar 16 --- Added EXIT_CODE.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xced1_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=d
 
	if uval eq 'DONE' then begin
	  widget_control, d.res, set_uval=0	; Set exit code.
	  widget_control, ev.top, /dest
	  return
	end
 
	if uval eq 'CANCEL' then begin
	  widget_control, d.res, set_uval=1	; Set exit code.
	  tvlct, d.r, d.g, d.b, d.index		; Restore original color.
	  widget_control, ev.top, /dest
	  return
	end
 
	if uval eq 'SLIDER' then begin		; Handle sliders.
	  widget_control, d.wid(0), get_val=s1	; Get current slider values.
	  widget_control, d.wid(1), get_val=s2
	  widget_control, d.wid(2), get_val=s3
	  if d.mode eq 0 then begin		; RGB mode.
	    tvlct, s1, s2, s3, d.index
	  endif else begin			; HSV mode.
	    tvlct, s1, s2/100., s3/100., d.index, /hsv
	  endelse
	  return
	endif
 
	end
 
;========================================================
;	xced1.pro = single entry color editor.
;	R. Sterner, 29 Oct, 1993
;========================================================
 
	pro xced1, index, title=title, hsv=hsv, help=hlp, $
	  group_leader=grp, wait=wait, exit_code=code
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Simple widget to edit a single color table entry.'
	  print,' xced1, index'
	  print,'   index = color table index to edit.   in'
	  print,' Keywords:'
	  print,'   TITLE=txt  Title text to display.'
	  print,'   /HSV  means work in Hue, Saturation, and Value'
	  print,'     coordinates (def=Red, Green, Blue).'
          print,'   GROUP_LEADER=grp  Assign a group leader to this'
          print,'     widget.  When the widget with ID grp is destroyed'
          print,'     this widget is also.'
          print,'   /WAIT  means wait for returned result.'
	  print,'   EXIT_CODE=excode Exit code: 0=Done, 1=Cancel.'
	  return
	endif
 
	;-------  Check that color index is in range  ----------
	if (index lt 0) or (index ge !d.table_size) then begin
	  xmess,['Requested color table index, '+strtrim(index,2)+$
	    ', is out of the range','0 to '+strtrim(!d.table_size-1,2)]
	  return
	endif
 
	;-------  Get intial color  -----------
	tvlct,rr,gg,bb,/get,index
	rr=rr(0)  &  gg=gg(0)  &  bb=bb(0)
	init = [rr,gg,bb]
 
	;-------  Get set up for chosen color system  ----------
	if keyword_set(hsv) then begin
	  lb = ['Hue (0 to 360)','Saturation (0 to 100%)','Value (0 to 100%)']
	  mx = [360,100,100]
	  mode = 1
	  rgb_to_hsv, rr, gg, bb, h, s, v
	  val = [h,s*100,v*100]
	endif else begin
	  lb = ['Red (0 to 255)','Green (0 to 255)','Blue (0 to 255)']
	  mx = [255,255,255]
	  mode = 0
	  val = init
	endelse
 
 
	;--------  Widget layout  ---------------
	tt = 'Modify color index '+strtrim(index,2)
	top = widget_base(/column, title=tt)
	if n_elements(grp) ne 0 then widget_control, top, group=grp
	if n_elements(title) ne 0 then b = widget_label(top, val=title)
 
	wid = lonarr(3)
 
	for i = 0, 2 do begin
	  id_s = widget_slider(top, xsize=400, max=mx(i), val=val(i), $
	    uval='SLIDER', /drag)
	  wid(i) = id_s
	  id = widget_label(top, val=lb(i))
	endfor
 
	b = widget_base(top, /row)
	id = widget_button(b, value='Done', uval='DONE')
	id = widget_button(b, value='Cancel', uval='CANCEL')
 
	;--------  Set up and store needed global data  ---------
	res = widget_base()
	data = {index:index, r:rr, g:gg, b:bb, wid:wid, mode:mode, res:res}
	widget_control, top, set_uval=data
 
	;------  realize widget  -----------
	widget_control, /real, top
 
        ;------  Event loop  ---------------
        if n_elements(wait) eq 0 then wait = 0
	xmanager, 'xced1', top, modal=wait
 
	;------  Get exit value  -----------
	widget_control, res, get_uval=code
 
	return
	end
