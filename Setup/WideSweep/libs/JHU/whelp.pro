;-------------------------------------------------------------
;+
; NAME:
;       WHELP
; PURPOSE:
;       Widget to display given help text.
; CATEGORY:
; CALLING SEQUENCE:
;       whelp, txt
; INPUTS:
;       txt = String array with help text to display.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=tt  Help window title text (def=none).
;         LINES=lns maximum number of lines to display
;           before added a scroll bar (def=30).
;         EXIT_TEXT=txt Exit button text (def=Quit help).
;         WID=id  returned widget ID of help widget.  This
;           allows the help widget to be automatically
;           destroyed after action occurs.
;         GROUP_LEADER=grp  Assign a group leader to this
;           widget.  When the widget with ID grp is destroyed
;           this widget is also.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 29 Sep, 1993
;       R. Sterner, 18 Oct, 1993 --- Added LINES and event handler.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro whelp_event, ev
 
	widget_control, /dest, ev.top
	return
	end
 
;=============================================================
 
	pro whelp, txt, title=title, lines=lines, exit_text=texit, $
	  wid=b0, group_leader=grp, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Widget to display given help text.'
	  print,' whelp, txt'
	  print,'   txt = String array with help text to display.  in'
	  print,' Keywords:'
	  print,'   TITLE=tt  Help window title text (def=none).'
	  print,'   LINES=lns maximum number of lines to display'
	  print,'     before added a scroll bar (def=30).'
	  print,'   EXIT_TEXT=txt Exit button text (def=Quit help).'
	  print,'   WID=id  returned widget ID of help widget.  This'
	  print,'     allows the help widget to be automatically'
	  print,'     destroyed after action occurs.'
	  print,'   GROUP_LEADER=grp  Assign a group leader to this'
	  print,'     widget.  When the widget with ID grp is destroyed'
	  print,'     this widget is also.'
	  return
	endif
 
	if n_elements(texit) eq 0 then texit = 'Quit help'
 
	if n_elements(title) eq 0 then title = ' '
	if n_elements(lines) eq 0 then lines = 30
	b0 = widget_base(title=title,/column)
	if n_elements(grp) ne 0 then widget_control, b0, group=grp
	nx = max(strlen(txt))
	ny = n_elements(txt)
	if ny gt lines then begin
	  ny = lines
	  scroll = 1
	endif else scroll=0
	b2 = widget_text(b0,value=txt,xsize=nx,ysize=ny,scroll=scroll)
	b1 = widget_base(b0,/row)
	b11 = widget_button(b1,value=texit)
	widget_control,/real,b0
 
	xmanager, 'whelp', b0
 
	return
	end
