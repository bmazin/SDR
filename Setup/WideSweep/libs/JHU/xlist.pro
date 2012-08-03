;-------------------------------------------------------------
;+
; NAME:
;       XLIST
; PURPOSE:
;       Pop-up list selection widget.
; CATEGORY:
; CALLING SEQUENCE:
;       out = xlist(list)
; INPUTS:
;       list = string array of possible selections.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=txt  title text or text array (def=Select item).
;         MAXSCROLL=n Max allowed lines before scrolling list used
;           (def=20).
;         HIGHLIGHT=i Line to highlight (def=none).
;         TOP=j       Line to make be the top of the list.
;         INDEX=indx  Returned index of selected item.
;         /MULTIPLE   Allow multiple selections.
;         /SEARCH     Add a search entry area.
;         ITXT=itxt  Initial search text (def=none).
;         SMODE=mode  Initial search mode:
;           1=Starts with (def), 2=Contains.
;         OUT=out     Returned structure with final search mode
;                     and search text: out={smode:smode,stxt:stxt}.
;         /WAIT  means wait for a selection before returning.
;           Needed if called from another widget routine.
; OUTPUTS:
;       out = selected element.                      out
;         Null if Cancel button pressed.
; COMMON BLOCKS:
;       xlist_init_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 11 Nov, 1993
;       R. Sterner, 2003 Dec 11 --- Added /MULTIPLE.
;       R. Sterner, 2004 Jun 24 --- Fixed OK with no selection.
;       Robert Mallozzi's dialog_list had some key clues.
;       R. Sterner, 2004 Aug 02 --- Added /SEARCH.
;       R. Sterner, 2004 Aug 30 --- Added search options: Starts with/Contains.
;       R. Sterner, 2004 Aug 31 --- Added list size label.
;       R. Sterner, 2004 Sep 27 --- Fixed a typo in list setup.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;---------------------------------------------------------------------------
;	Init procedure
;	Called when widget is realized.
;	Call before: xlist_init, init=s
;	where s is the info structure.
;---------------------------------------------------------------------------
	pro xlist_init, top, init=s0
 
	common xlist_init_com, s
 
	if n_elements(s0) gt 0 then begin
	  s = s0
	  return
	endif
 
	if s.id_srch eq 0 then return
	widget_control, s.id_srch, set_val=s.itxt
	ev = {ID:s.id_srch, TOP:top, HANDLER:top}
	xlist_srch, ev 
 
	end
 
 
;---------------------------------------------------------------------------
;	Event handler for search mode change.
;---------------------------------------------------------------------------
	function xlist_smode, ev
 
	if ev.select eq 0 then return,0		; Ignore unless release.
 
	widget_control, ev.top, get_uval=s	; Grab info structure.
	widget_control, ev.id, get_uval=uval	; Get button uval.
	if uval eq 'S1' then begin		; Was 'Starts with' button.
	  s.sflag = 1				; Set flag.
	  stxt = 'Starts with:'
	endif
	if uval eq 'S2' then begin		; Was 'Contains' button.
	  s.sflag = 2
	  stxt = 'Contains:'
	endif
	widget_control, s.id_slab, set_val=stxt	; Update search text label.
	widget_control, ev.top, set_uval=s	; Save info structure.
 
	;---------------------------------------------
	;  Build a new event to return.  Ends up in
	;  the search event handler because the parent
	;  base had an event handler set to the
	;  search event handler.
	;---------------------------------------------
	new_ev = {ID:s.id_srch, TOP:ev.top, HANDLER:ev.top}
	return, new_ev
 
	end
 
 
;---------------------------------------------------------------------------
;	Event handler for search
;	Only triggered when search text changed.
;---------------------------------------------------------------------------
	pro xlist_srch, ev
 
	;-----  Grab search text  -----
	widget_control, ev.id, get_val=stxt
	stxt = strlowcase(stxt(0))	; Case ignored.
	n = strlen(stxt)
 
	widget_control, ev.top, get_uval=s ; Grab info structure.
 
	;------  Grab list  -----------
	if stxt eq '' then begin		; Null string sets to top.
	  widget_control, s.id_list, set_val=s.list, set_list_top=0
	  n_list = n_elements(s.list)			; List size.
	  s.inlist = lindgen(n_list)			; Back to full
	  widget_control, s.id_num, set_val=strtrim(n_list,2) ; Update size.
	  widget_control, ev.top, set_uval=s		; list of indices.
	  return
	endif
 
	;------  Search list  ---------
	list = strlowcase(s.list)			; Ignore list case.
 
	if s.sflag eq 1 then begin			; Simple search.
	  widget_control, s.id_list, set_val=s.list	; Display full list.
	  n_list = n_elements(s.list)			; List size.
	  s.inlist = lindgen(n_list)			; Back to full
	  widget_control, s.id_num, set_val=strtrim(n_list,2) ; Update size.
	  widget_control, ev.top, set_uval=s		; list of indices.
	  w = where(stxt eq strmid(list,0,n), cnt)	; Find start text.
	  if cnt gt 0 then begin			; If found then ...
	    widget_control, s.id_list, set_list_top=w(0)  ; put first at top.
	  endif
	endif else begin				; Contains type search.
	  w = where(strpos(list,stxt) ge 0, cnt)	; Search for text.
	  if cnt gt 0 then begin			; If found then ...
	    widget_control, s.id_list, set_val=s.list(w)  ; Display where.
	    n_list = n_elements(s.list(w))		; List size.
	    ind = lindgen(n_elements(s.list))		; List of all indices.
	    s.inlist = ind(w)				; Indices of matches.
	    widget_control, s.id_num, set_val=strtrim(n_list,2)	; Update size.
	    widget_control, ev.top, set_uval=s		; Update.
	  endif
	  return
	endelse
 
	end 
 
 
;---------------------------------------------------------------------------
;	Event handler for single item
;---------------------------------------------------------------------------
	pro xlist_event, ev
 
	widget_control, ev.id, get_uval=cmd	; Get command.
	widget_control, ev.top, get_uval=s	; Get info.
 
	if cmd eq 'CANCEL' then begin		; CANCEL button.
	  out = {smode:0, stxt:''}
	  res = {t:'',i:0, out:out}		; Returned items.
	  widget_control, s.res, set_uval=res	; Return null string.
	  widget_control, ev.top, /dest		; Destroy widget.
	  return
	endif
 
	;-----  Returned selected item  ------
	in = s.inlist(ev.index)			; Convert to index in list.
	txt = s.list(in)			; Selected list entry.
	if s.id_srch ne 0 then begin
	  widget_control, s.id_srch, get_val=stxt  ; Final search text.
	endif else stxt=''
	out = {smode:s.sflag, stxt:stxt}		; Final search items.
	res = {t:txt,i:in, out:out}		; Returned items.
	widget_control, s.res, set_uval=res	; Return it.
	widget_control, ev.top, /dest		; Destroy widget.
	return
 
	end 
 
 
;---------------------------------------------------------------------------
;	Event handler for multiple items
;---------------------------------------------------------------------------
	pro xlist_m_event, ev
 
	widget_control, ev.id, get_uval=cmd		; Get command.
	widget_control, ev.top, get_uval=s		; Get info.
 
	if cmd eq 'OK' then begin			; OK button.
	  in0 = widget_info(s.id_list, /list_select)	; Get indices selected.
	  if in0(0) lt 0 then begin			; Same as cancel.
	    out = {smode:0, stxt:''}
	    res = {t:'',i:0, out:out}			; Returned items.
	    widget_control, s.res, set_uval=res		; Return null string.
	  endif else begin
	    if s.id_srch ne 0 then begin
	      widget_control, s.id_srch, get_val=stxt	; Final search text.
	    endif else stxt=''
	    out = {smode:s.sflag, stxt:stxt}		; Final search items.
	    in = s.inlist(in0)			        ; Convert to list index.
	    txt = s.list(in)				; Selected list items.
	    res = {t:txt,i:in, out:out}			; Returned items.
	    widget_control,s.res,set_uval=res		; Return them.
	  endelse
	  widget_control, ev.top, /dest			; Destroy widget.
	  return
	endif
 
	if cmd eq 'CANCEL' then begin			; CANCEL button.
	  out = {smode:0, stxt:''}
	  res = {t:'',i:0, out:out}			; Returned items.
	  widget_control, s.res, set_uval=res		; Return null string.
	  widget_control, ev.top, /dest			; Destroy widget.
	  return
	endif
 
	end 
 
 
;===================================================================
;	xlist.pro = Pop-up list selection widget.
;===================================================================
 
	function xlist, list, title=title, help=hlp, maxscroll=maxs, $
	  index=indx, wait=wait, highlight=hi, top=ltop, $
	  xoffset=xoff, yoffset=yoff,multiple=mult, $
	  search=search, itxt=itxt, smode=smode, out=out
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Pop-up list selection widget.'
	  print,' out = xlist(list)'
	  print,'   list = string array of possible selections.  in'
	  print,'   out = selected element.                      out' 
	  print,'     Null if Cancel button pressed.'
	  print,' Keywords:'
	  print,'   TITLE=txt  title text or text array (def=Select item).'
	  print,'   MAXSCROLL=n Max allowed lines before scrolling list used'
	  print,'     (def=20).'
	  print,'   HIGHLIGHT=i Line to highlight (def=none).'
	  print,'   TOP=j       Line to make be the top of the list.'
	  print,'   INDEX=indx  Returned index of selected item.'
	  print,'   /MULTIPLE   Allow multiple selections.'
	  print,'   /SEARCH     Add a search entry area.'
	  print,'   ITXT=itxt  Initial search text (def=none).'
	  print,'   SMODE=mode  Initial search mode:'
	  print,'     1=Starts with (def), 2=Contains.'
	  print,'   OUT=out     Returned structure with final search mode'
	  print,'               and search text: out={smode:smode,stxt:stxt}.'
	  print,'   /WAIT  means wait for a selection before returning.'
	  print,'     Needed if called from another widget routine.'
	  return,''
	endif
 
	;------------------------------------------------------
	;  Set defaults
	;------------------------------------------------------
	if n_elements(maxs) eq 0 then maxs=20
	if n_elements(title) eq 0 then title = 'Select item'
	if n_elements(itxt) eq 0 then itxt = ''
 
	;------------------------------------------------------
	;  Set up widget
	;------------------------------------------------------
	res = widget_base()		; Unused base for returned result.
	widget_control, res, set_uval=''
 
	top = widget_base(/column, title=' ',xoffset=xoff,yoffset=yoff, $
	  notify_realize='xlist_init')
 
	for i=0, n_elements(title)-1 do t = widget_label(top,val=title(i))
 
	;------------------------------------------------------
	;  Exit button(s)
	;------------------------------------------------------
	b = widget_base(top, /row)
	if keyword_set(mult) then t = widget_button(b, val='OK', uval='OK')
	t = widget_button(b, val='Cancel', uval='CANCEL')
	id = widget_label(b,val='Items in list: ')
	id_num = widget_label(b,val=strtrim(n_elements(list),2),/dynamic)
 
	;------------------------------------------------------
	;  Search area
	;
	;  Search mode buttons are in an exclusive base
	;  which has its event procedure set to the
	;  search event procedure, xlist_srch.  The mode
	;  buttons in this base have event functions that
	;  change the mode flag and search label and then
	;  build a new event structure and return it.
	;  This event is handled by the next handler up the
	;  hierarchy, which is the base's handler xlist_srch.
	;  Event functions return a value, and if it is a
	;  structure it will be passed to the next handler
	;  unless it does not have the items id, top, handler.
	;  If the return value is not a structure it is ignored.
	;------------------------------------------------------
	sflag = 0				; No search option.
	id_slab = 0
	id_srch = 0
	if keyword_set(search) then begin
	  if n_elements(smode) eq 0 then smode=1
	  if smode eq 1 then begin
	    sflag = 1				; 'Starts with' type search.
	    stxt = 'Starts with:'
	  endif else begin
	    sflag = 2				; 'Contains' type search.
	    stxt = 'Contains:'
	  endelse
	  b = widget_base(top, /row)
	  id_slab = widget_label(b,val=stxt,/dynamic)
	  id_srch = widget_text(b,xsize=10,/all_events,/editable, $
	    event_pro='xlist_srch')
	  bex = widget_base(b,/row,/exclusive, event_pro='xlist_srch')
	  id1 = widget_button(bex,val='Starts with',uval='S1', $
	    event_func='xlist_smode')
	  id2 = widget_button(bex,val='Contains',uval='S2', $
	    event_func='xlist_smode')
	  if smode eq 1 then begin
	    widget_control, id1, /set_button
	  endif else begin
	    widget_control, id2, /set_button
	  endelse
	endif
 
	;------------------------------------------------------
	;  List
	;------------------------------------------------------
	id_list = widget_list(top, val=list, uval='LIST', $
	  ysize=n_elements(list)<maxs, multiple=mult)
	inlist = lindgen(n_elements(list))		; List of indices.
 
	s = {res:res, id_list:id_list, list:list, inlist:inlist, $
	  id_slab:id_slab, sflag:sflag, id_srch:id_srch, itxt:itxt, $
	  id_num:id_num}
 
	xlist_init, init=s
 
	widget_control, top, /real, set_uval=s
 
;	if n_elements(hi) ne 0 then widget_control,lst,set_list_select=hi
;	if n_elements(ltop) ne 0 then widget_control,lst,set_list_top=ltop
	if n_elements(hi) ne 0 then widget_control,id_list,set_list_select=hi
	if n_elements(ltop) ne 0 then widget_control,id_list,set_list_top=ltop
 
	;------------------------------------------------------
	;  Register
	;------------------------------------------------------
	if n_elements(wait) eq 0 then wait=0
 
	if keyword_set(mult) then begin
	  xmanager, 'xlist_m', top, modal=wait	; Use multi-item event handler.
	endif else begin
	  xmanager, 'xlist', top, modal=wait	; Use single item event handler.
	endelse
 
	;------------------------------------------------------
	;  Get returned result
	;------------------------------------------------------
	widget_control, res, get_uvalue=out0
	indx = out0.i
	txt = out0.t
	out = out0.out
 
	return, txt
	end
