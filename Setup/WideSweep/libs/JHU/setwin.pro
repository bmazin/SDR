;-------------------------------------------------------------
;+
; NAME:
;       SETWIN
; PURPOSE:
;       Set which window should be currently active window.
; CATEGORY:
; CALLING SEQUENCE:
;       setwin
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  Error flag: 0=ok, 1=abort.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 May 22
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro setwin_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=m
 
	orig = m.orig
 
	if strtrim(uval,2) eq 'OK' then begin
	  widget_control, m.res, set_uval=0	; Err=0.
	  widget_control, ev.top, /dest
	  return
	endif
 
	if strtrim(uval,2) eq 'ORIG' then begin
	  wset, orig
	  widget_control, m.res, set_uval=0	; Err=0.
	  widget_control, ev.top, /dest
	  return
	endif
 
	if strtrim(uval,2) eq 'ABORT' then begin
	  wset, orig
	  widget_control, m.res, set_uval=1	; Err=1.
	  widget_control, ev.top, /dest
	  return
	endif
 
	wset, uval
	wshow
	wait,.5
	wshow,uval,0
	wait,.5
	wshow,uval,1
 
	return
	end
 
 
;====================================================================
;	setwin.pro = set window to became current window.
;	R. Sterner, 1995 May 22
;====================================================================
 
	pro setwin, error=err, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Set which window should be currently active window.'
	  print,' setwin'
	  print,'   No args.  Gives a widget.'
	  print,' Keywords:'
	  print,'   ERROR=err  Error flag: 0=ok, 1=abort.'
	  return
	endif
 
	device, window=win
	w = where(win eq 1, cnt)
 
	;------  No windows  -----------
	if cnt eq 0 then begin
	  xmess,'No windows to make active'
	  err = 1
	  return
	endif
 
	;-------  One window  ------------
	if cnt eq 1 then begin
	  wset, w(0)
	  err = 0
	  return
	endif
	
	;-------  Multiple windows  -----------
	;-------  Find sizes  -----------------
	xs = lonarr(cnt)
	ys = lonarr(cnt)
	curr = !d.window		; Current window.
	for i=0,cnt-1 do begin		; Find sizes
	  wset, w(i)
	  xs(i) = !d.x_size
	  ys(i) = !d.y_size
	endfor
	wset, curr			; Reset to entry window.
	;-------  Layout widget  --------------
	top = widget_base(title=' ',/column)
 
	id = widget_label(top,val='Choose window',/dynamic)
	;------  Buttons  -------
	for i=0,cnt-1 do begin
	  b = widget_base(top,/row)
	 id = widget_button(b, val=strtrim(w(i),2),uval=w(i))
	 id = widget_label(b,val=strtrim(xs(i),2)+' x '+$
	   strtrim(ys(i),2),/dynamic)
	endfor
	;------  Commands  --------
	b = widget_base(top,/frame,/row)
	id = widget_button(b,val='OK',uval='OK')
	id = widget_button(b,val='No change',uval='ORIG')
	id = widget_button(b,val='Abort',uval='ABORT')
 
	;-------  Results  --------------------
	res = widget_base()
	map = {orig:curr, res:res}
	widget_control, top, set_uval=map
 
	;-------  Realize widget  -------------
	widget_control, top, /real
 
	;-------  Register widget  ---------------
	xmanager, 'setwin', top, /modal
 
	;-------  Get flag  ----------------------
	widget_control, res, get_uval=err
 
	return
	end
