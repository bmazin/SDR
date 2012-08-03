;-------------------------------------------------------------
;+
; NAME:
;       XAUTOHELP_EXAMPLE
; PURPOSE:
;       This routine shows how to use xautohelp.
; CATEGORY:
; CALLING SEQUENCE:
;       xautohelp_example
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /TEXT use text widget for help, else label widget.
;           This example uses multiple label widgets for help.
;         /DETACHED means use detached help area, else attached.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1998 May 1
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xautohelp_example_event, ev
 
	;------------------------------------------
	;  Deal with autohelp text events
	;------------------------------------------
	widget_control, ev.top, get_uval=lab	; Get text display area ID.
	xautohelp, ev, display=lab		; Send event into xautohelp.
	if (size(ev))(2) ne 8 then return	; Check if still a structure.
 
	
	;------------------------------------------
	;  Deal with timer events
	;------------------------------------------
	if tag_names(ev,/structure_name) eq 'WIDGET_TIMER' then begin
	  ;-------------------------------------------------------
	  ;  Read and check first line in help text area.
	  ;  If not help text then display time.
	  ;-------------------------------------------------------
	  widget_control, lab(0), get_val=tmp
	  tmp = tmp(0)				; Check only 1st line.
	  if (tmp eq ' ') or (strmid(tmp,0,3) eq strmid(systime(),0,3)) then $
	    widget_control, lab(0), set_val=systime()
	  widget_control, ev.top, timer=1.		; Next timer event.
	  return
	endif
 
	;------------------------------------------
	;  Deal with other events
	;------------------------------------------
	widget_control, ev.id, get_uval=nam	; Get name of event from uval.
 
	;-----  QUIT is the only event that does anything here  --------
	if nam eq 'QUIT' then begin		; The event was the QUIT button.
	  widget_control, ev.top, /dest		; Destroy widget.
	  return
	endif
 
	print,' Widget accessed was '+nam
 
	return
	end
 
;---------------------------------------------------------------
;	Main routine (widget setup)
;---------------------------------------------------------------
 
	pro xautohelp_example, help=hlp, text=text, detached=det
 
	if keyword_set(hlp) then begin
	  print,' This routine shows how to use xautohelp.'
	  print,' xautohelp_example'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   /TEXT use text widget for help, else label widget.'
	  print,'     This example uses multiple label widgets for help.'
	  print,'   /DETACHED means use detached help area, else attached.'
	  return
	endif
 
	;---------------------------------------------------
	;  Layout a simple widget.
	;  Each widget tha thas autohelp text has tracking
	;  turned on and help text saved.
	;---------------------------------------------------
	top = widget_base(/col)			; Top base.
	bb = widget_base(top, /row)		; A base for the buttons.
 
	b = widget_button(bb,val='Button 1', /track, uval='Button 1')
	xautohelp,b, $
	  'This is button # 1/'+$
	  'This button does not do anything in this example,/'+$
	  'but this text could give useful information in a real application.'
 
	b = widget_button(bb,val='Button 2',/track, uval='Button 2')
	xautohelp,b, $
	  'Button # 2 also does not do anything here./ /Line 3 of text.'
 
	b = widget_button(bb,val='Button 3',/track, uval='QUIT')
	xautohelp,b,'Click to QUIT.'
 
	b = widget_button(bb,val='Button 4',/track, uval='Button 4')
	xautohelp,b,'Button # 4, another no-op.'
 
	b = widget_label(bb,val='    Enter a value: ')
	b = widget_text(bb,val='Default value',/track, uval='TEXT',/edit)
	xautohelp,b, $
	  'To change the current value here, first click to position cursor,'+$
	  '/then either add or delete text.  Can highlight text to replace,'+$
	  '/then enter new text.  Press RETURN when entry is complete.'
 
	s = widget_slider(top,/track,uval='Slider')
	xautohelp,s,'Slider.  Drag to desired value./Nothing will happen.'
 
 
	;---------------------------------------------------
	;  Set up the autohelp text display area.  Normally only one
	;  of the following 4 cases will be used.  Multiple options
	;  (keyword selectable) are given here as examples.
	;  In this example a 3 line help text area is used.
	;  In the real case the keywords used to select which of the
	;  4 example cases is used would not be needed.
	;---------------------------------------------------
 
	;---------------------------------------------------
	;  DETACHED autotext window
	;---------------------------------------------------
	if keyword_set(det) then begin
	  loc = widget_info(top,/geom)	; Get top base size and position.
	  tmp = widget_base(/col, group_leader=top, title=' ', $
	    xoffset=loc.xoffset,yoffset=loc.yoffset+loc.ysize+8)
	  ;---------------------------------------------------------
	  ; (1) DETACHED autohelp text display using a TEXT widget
	  ;---------------------------------------------------------
	  if keyword_set(text) then begin
	    lab = widget_text(tmp,xsize=70,ysize=3)
	  ;---------------------------------------------------------
	  ; (2) DETACHED autohelp text display using LABEL widgets
	  ;---------------------------------------------------------
	  endif else begin
	    lab1 = widget_label(tmp,/align_left,val=spc(80,char='a'))
	    lab2 = widget_label(tmp,/align_left,val=spc(80,char='a'))
	    lab3 = widget_label(tmp,/align_left,val=spc(80,char='a'))
	    lab = [lab1,lab2,lab3]
	  endelse
	  widget_control,tmp,/real			; Activate.
	endif
 
	;---------------------------------------------------
	;  ATTACHED autotext window
	;  An optional frame sets off this area.
	;---------------------------------------------------
	if not keyword_set(det) then begin
	  ;---------------------------------------------------------
	  ; (3) ATTACHED autohelp text display using a TEXT widget
	  ;---------------------------------------------------------
	  if keyword_set(text) then begin
	    lab = widget_text(top,xsize=70,ysize=3, /frame)
	  ;---------------------------------------------------------
	  ; (4) ATTACHED autohelp text display using LABEL widgets
	  ;---------------------------------------------------------
	  endif else begin
	    tmp = widget_base(top,/col,/frame)  ; Just to get a frame.
	    lab1 = widget_label(tmp,/align_left,val=spc(80,char='a'))
	    lab2 = widget_label(tmp,/align_left,val=spc(80,char='a'))
	    lab3 = widget_label(tmp,/align_left,val=spc(80,char='a'))
	    lab = [lab1,lab2,lab3]
	  endelse
	endif
 
	;---------------------------------------------------------------
	;  Realize widget, clear help area, start timer.
	;---------------------------------------------------------------
	widget_control, top, /real, set_uval=lab
	for i=0,n_elements(lab)-1 do widget_control,lab(i),set_val=' '
	widget_control, top, timer=1.		; Set a timer (for 1 sec).
 
	;---------------------------------------------------------------
	;  Set initial help text here.
	;  This is optional.  If first line of multiple label widget
	;  help area is not used the timer will be displayed there
	;  along with the inital help text.  This is not so easy if a
	;  text widget is used, the timer wipes out the initial help
	;  text (so the top line is not left blank for text widgets
	;  and the timer will not start until the area is clear).
	;---------------------------------------------------------------
	if n_elements(lab) ge 2 then begin
	  widget_control,lab(1),set_val='One of the buttons quits'
	  widget_control,lab(2),set_val='Move cursor over buttons to find which'
	endif else begin
	  widget_control,lab,set_val=['One of the buttons quits',$
	    'Move cursor over buttons to find which']
	endelse
 
	;---------------------------------------------------------------
	;  Register widget with xmanager.
	;---------------------------------------------------------------
	xmanager,'xautohelp_example',top, /no_block
 
	end
