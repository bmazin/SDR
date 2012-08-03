;-------------------------------------------------------------
;+
; NAME:
;       XMESS
; PURPOSE:
;       Display a message using a widget.
; CATEGORY:
; CALLING SEQUENCE:
;       xmess, txt
; INPUTS:
;       txt = Message to display as a string or string array.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         WID=id  Returned widget ID of message widget.  May use
;           this to automatically destroy the message widget
;           when an action is completed.  To destroy widget do:
;           widget_control, /dest, id
;         /NOWAIT  means don't wait for OK button to be pressed.
;           Useful with WID to fill in long pauses, can display
;           what is happening, then destroy message.
;         /WAIT  means wait for OK button without using xmanager
;           to register xmess.  Will not drop through if button
;           is not pressed as in default case.
;         OKTEXT=txt  Set text for OK button (def=OK).
;         XOFFSET=xoff, YOFFSET=yoff Widget position.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 25 Oct, 1993
;       R. Sterner, 11 Nov, 1993 --- added /NOWAIT.
;       R. Sterner, 1994 Sep 6 --- Added /WAIT.
;       R. Sterner, 1998 Jun  3 --- Added xoff, yoff.
;       R. Sterner, 2002 Sep 10 --- fixed /WAIT.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xmess_event, ev
 
        widget_control, /dest, ev.top
        return
 
	end
 
;==============================================================
;	xmess = Widget message display
;	R. Sterner, 25 Oct, 1993
;==============================================================
 
	pro xmess, txt, wid=top, nowait=nowait, oktext=oktxt, $
	  wait=wait, help=hlp, xoffset=xoff, yoffset=yoff
 
	if keyword_set(hlp) then begin
	  print,' Display a message using a widget.'
	  print,' xmess, txt'
	  print,'   txt = Message to display as a string or string array.  in'
	  print,' Keywords:'
	  print,'   WID=id  Returned widget ID of message widget.  May use'
	  print,'     this to automatically destroy the message widget'
	  print,'     when an action is completed.  To destroy widget do:'
	  print,'     widget_control, /dest, id'
	  print,"   /NOWAIT  means don't wait for OK button to be pressed."
	  print,'     Useful with WID to fill in long pauses, can display'
	  print,'     what is happening, then destroy message.'
	  print,'   /WAIT  means wait for OK button without using xmanager'
	  print,'     to register xmess.  Will not drop through if button'
	  print,'     is not pressed as in default case.'
	  print,'   OKTEXT=txt  Set text for OK button (def=OK).'
	  print,'   XOFFSET=xoff, YOFFSET=yoff Widget position.'
	  return
	endif
 
	if n_elements(oktxt) eq 0 then oktxt = 'OK'
 
	top = widget_base(/column, title=' ',xoff=xoff,yoff=yoff)
 
	id = widget_label(top, val=' ')
	for i = 0, n_elements(txt)-1 do id = widget_label(top, val=txt(i))
	id = widget_label(top, val=' ')
 
	if not keyword_set(nowait) then begin
	  b2 = widget_base(top,/row,/align_center)
	  id = widget_label(b2, val='---==<')
	  idb = widget_button(b2, val=oktxt, uval='OK')
	  id = widget_label(b2, val='>==---')
	endif
 
	widget_control, top, /real
 
;	;-------  Forced wait  ----------
;	if keyword_set(wait) then begin
;	  widget_control, idb, /input_focus
;	  tmp = widget_event(top)
;          widget_control, /dest, top
;	  return
;	endif
 
	;--------  No wait  -----------
	if keyword_set(nowait) then return
	widget_control, idb, /input_focus
 
	if n_elements(wait) eq 0 then wait = 0
	xmanager, 'xmess', top, modal=wait
 
	return
	end
