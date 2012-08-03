;-------------------------------------------------------------
;+
; NAME:
;       CW_DROPLIST2
; PURPOSE:
;       A pop up list from which to select an item.
; CATEGORY:
; CALLING SEQUENCE:
;       wid = cw_droplist2( parent)
; INPUTS:
;       parent = Widget ID of parent widget.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         VALUE=list  Given text array with list of items.
;         NUM=num  Number to display before breaking list (def=15).
;         UVALUE=uval  User value that may be set.
;         /UPDATE means update button with selected item.
;            Otherwise button not updated except using
;            cw_droplist2_select, id, indx
; OUTPUTS:
;       wid = Widget ID of opo up list.        out
; COMMON BLOCKS:
; NOTES:
;       Note: You can set a new droplist using
;         widget_control, id, set_value=list
;         and get the current list using
;         widget_control, id, get_value=list
;         but to set the value displayed on the button you must do
;         cw_droplist2_select, id, indx
;         where indx is the index in the list to display.
;         Use /UPDATE to avoid this extra call.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Dec 07
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;----------------------------------------------------------------------
;	Select displayed item for cw_droplist2.
;----------------------------------------------------------------------
 
	pro cw_droplist2_select, id, indx
 
	chld = widget_info(id, /child)		; First child widget.
	widget_control, chld, get_uval=s	; Grab state info from child.
 
	value = *s.p_value
	mx = n_elements(value)-1
	widget_control, chld, set_value=value(indx<mx)	; Set new button label.
 
	end
 
;----------------------------------------------------------------------
;	Set up cascading droplist.
;----------------------------------------------------------------------
	pro cw_droplist2_make, base, value, num, dynamic_resize=dyn, bb0=bb0
 
	;------  Destroy any existing droplist  -----------
	chld = widget_info(base,/child)
	if chld ne 0 then begin
	  widget_control, chld, get_uval=s
	  ptr_free, s.p_value			; Free ptr to old values.
	  s.p_value = ptr_new(value)		; Ptr to new value list.
	  widget_control, chld, /destroy
	endif
 
	if n_elements(num) eq 0 then num=s.num
 
	;------  Loop through all list values  ----------
	bb = base				; Parent of first button.
	for i=0, n_elements(value)-1 do begin
	  if (i mod num) eq 0 then begin		; Handle list breaks.
	    if i eq 0 then txt=value(0) else txt='More'	; Handle first button.
	    bb = widget_button(bb,value=txt, menu=2, dynamic=dyn) ; List break.
	    if i eq 0 then bb0=bb			; Save top button.
	  endif
	  id = widget_button(bb,val=value(i),uval=i, dynamic=dyn)  ; List item. 
	endfor
 
	;-----  If there was a uval update it  ----------------
	if n_elements(s) ne 0 then widget_control, bb0, set_uval=s
 
	end
 
;----------------------------------------------------------------------
;	Get value for cw_droplist2.
;----------------------------------------------------------------------
 
	function cw_droplist2_get_value, id
 
	chld = widget_info(id, /child)		; First child widget.
	widget_control, chld, get_uval=s	; Grab state info from child.
 
	return, *s.p_value				; Return list.
 
	end
 
;----------------------------------------------------------------------
;	Set value routine for cw_droplist2.
;----------------------------------------------------------------------
 
	pro cw_droplist2_set_value, id, val
	cw_droplist2_make, id, val, dynamic_resize=dyn, bb0=bb0
 
	chld = widget_info(id, /child)		; First child widget.
	widget_control, chld, get_uval=s	; Grab state info from child.
 
	ptr_free, s.p_value
	s.p_value = ptr_new(val)
	widget_control, bb0, set_uvalue=s	; Set new button label.
 
	end
	
 
;----------------------------------------------------------------------
;	Event handler for cw_droplist2.
;----------------------------------------------------------------------
 
	function cw_droplist2_event, ev
 
	;-------  Get info needed to display list  -------------
	base = ev.handler			; Top base for this widget.
	chld = widget_info(base, /child)	; First child widget.
	widget_control, chld, get_uval=s	; Grab state info from child.
	value = *s.p_value			; Extract list.
	bb0 = s.bb0				; Main button ID.
	update = s.update			; Update flag.
	widget_control, ev.id, get_uval=in	; List item index.
	out = value(in)				; List item.
 
	;-------  Update button  -------------
	if update then widget_control, bb0, set_val=out
 
	;-------  Return result through an event structure  --------
	ret = { CW_DROPLIST2, ID:base, TOP:ev.top, HANDLER:0L, $
	  INDEX:in, ITEM:out}			; Return an event.
 
	return, ret
 
	end
 
 
;----------------------------------------------------------------------
;	cw_droplist2.pro = Like widget_droplist but with larger capacity
;	R. Sterner, 2001 Dec 07
;----------------------------------------------------------------------
 
	function cw_droplist2, parent, value=value, uvalue=uvalue, $
	  list=list, update=update, num=num, dynamic_resize=dyn, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' A pop up list from which to select an item.'
	  print,' wid = cw_droplist2( parent)'
	  print,'   parent = Widget ID of parent widget.   in'
	  print,'   wid = Widget ID of opo up list.        out'
	  print,' Keywords:'
 	  print,'   VALUE=list  Given text array with list of items.'
	  print,'   NUM=num  Number to display before breaking list (def=15).'
	  print,'   UVALUE=uval  User value that may be set.'
	  print,'   /UPDATE means update button with selected item.'
	  print,'      Otherwise button not updated except using'
	  print,'      cw_droplist2_select, id, indx'
	  print,' Note: You can set a new droplist using'
	  print,'   widget_control, id, set_value=list'
	  print,'   and get the current list using'
	  print,'   widget_control, id, get_value=list'
	  print,'   but to set the value displayed on the button you must do'
	  print,'   cw_droplist2_select, id, indx'
	  print,'   where indx is the index in the list to display.'
	  print,'   Use /UPDATE to avoid this extra call.'
	  return, ''
	endif
 
	;-------  Defaults  ----------------------
	if n_elements(num) eq 0 then num=15	  ; Number in list before break.
	if n_elements(uvalue) eq 0 then uvalue=0  ; User value.
	if n_elements(value) eq 0 then value=' '  ; Initial button label.
	if n_elements(update) eq 0 then update=0  ; Update flag.
 
	on_error, 2		; Return to caller on any error.
 
	;-------  Top base for compound widget  ----------
	base = widget_base(parent, uvalue=uvalue,  $
	  event_func='cw_droplist2_event',         $
	  func_get_value='cw_droplist2_get_value', $
	  pro_set_val='cw_droplist2_set_value')
 
	;------  Loop through all list values  ----------
	cw_droplist2_make, base, value, num, dynamic_resize=dyn, bb0=bb0
 
	;------  Pack up info and store in first child  ---------
	info = {p_value:ptr_new(value), bb0:bb0, update:update, num:num}
	chld = widget_info(base, /child)
	widget_control, chld, set_uval=info
 
	return, base
 
	end
