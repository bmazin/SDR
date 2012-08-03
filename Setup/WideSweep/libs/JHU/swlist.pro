;-------------------------------------------------------------
;+
; NAME:
;       SWLIST
; PURPOSE:
;       Display info for all scrolling windows, set new active one.
; CATEGORY:
; CALLING SEQUENCE:
;       swlist
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       swlist_com
;       swlist_com
;       swindow_com
; NOTES:
;       Notes: Scrolling windows are useful for images larger than
;         the screen can display.
;         To create a scrolling window: use swindow.
;         To delete a scrolling window: use swdelete.
;         To display info on all scrolling windows: use swlist.
; MODIFICATION HISTORY:
;       R. Sterner, 29 Sep, 1993
;       R. Sterner, 2002 Jun 05 --- Fixed to deal with non-existent windows.
;       R. Sterner, 2002 Nov 12 --- Fixed to weed out non-existent windows.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro swmenu_event, ev
 
	common swlist_com, w, it, wa, b		; Needed to pass info from main.
 
	widget_control, ev.id, get_uval=uval	; Get event uval.
 
	if strtrim(uval) eq 'QUIT' then begin	; If QUIT destroy heirarchy.
	  widget_control, ev.top, /dest		; Destroy root.
	  return				; All done.
	endif
 
	if strtrim(uval) eq 'HELP' then begin	; Add help widget.
	  txt = ['Scrolling windows are useful for displaying images larger',$
	    'than can fit on the screen.  There are 4 routines of interest:',$
	    '   swindow:  used to create a scrolling window.',$
	    '   swdelete: used to delete a scrolling window.',$
	    '   swlist:   used to list information for all scrolling windows',$
	    '             and activate one of them.',$
	    '   swinfo:   function to return requested values for a scrolling window.',$
	    'The routine swindow numbers scrolling windows starting at 100.',$
	    'Swlist lists these numbers on the buttons for each window, they',$
	    'are also used in the default window titles.  IDL also assigns',$
	    'an internal index to each window.  This index is listed by',$
	    'swlist as Index and is the number needed by wset to make the',$
	    'window active (swlist does this for you).  Also displayed are',$
	    'the full window size, the visble size, and the window title.',$
	    'Pressing a window button activates that window.  The button for',$
	    'the active window is dimmed and cannot be pressed (that window',$ 
	    'is already active).']
	  xhelp, txt, title='swlist help'
	  return
	endif
 
	if wa(0) ge 0 then begin
	  widget_control, b(wa), sens=1		; Brighten old window.
	endif
 
	wset, it(w(uval))			; Set new window to active.
	wshow					; Show it.
	act = !d.window				; New active window.
	wa = (where(act eq it, acnt))(0)	; Find new active window.
	if acnt gt 0 then widget_control,b(wa), /set_butt, sens=0  ; Dim it.
	return
	end
 
 
;---------  swlist.pro = list scroll windows and parameters  ---------
;	R. Sterner, 29 Sep, 1993
 
	pro swlist, help=hlp
 
	common swlist_com, w, it, wa, b
 
        common swindow_com, index_table, base_table, sw_ind, swcnt, $
          sw_titl, sw_fx, sw_fy, sw_vx, sw_vy, drw_wid
        ;-------------------------------------------------------------
        ;  Scrolling windows common (only for scrolling windows):
        ;    index_table = array of window numbers to be used by wset.
        ;    base_table = array of window widget base numbers.
        ;    swcnt = Current count of scrolling windows.
        ;    sw_titl = array of window titles.
        ;    sw_ind = array of window numbers as seen by user (100+).
        ;    sw_fx = array of window full x sizes.
        ;    sw_fy = array of window full y sizes.
        ;    sw_vx = array of window visible x sizes.
        ;    sw_vy = array of window visible y sizes.
        ;    drw_wid = array of draw widget IDs.
        ;--------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Display info for all scrolling windows, set new active one.'
	  print,' swlist'
	  print,'   No args.  Uses widgets for control.'
	  print,' Notes: Scrolling windows are useful for images larger than'
	  print,'   the screen can display.'
	  print,'   To create a scrolling window: use swindow.'
	  print,'   To delete a scrolling window: use swdelete.'
	  print,'   To display info on all scrolling windows: use swlist.'
	  return
	endif
 
	;-----------  Weed out non-existant windows  ------------
	if n_elements(index_table) ne 0 then begin
	  n = n_elements(index_table)
	  flag = intarr(n)
	  for i=0,n-1 do flag(i)=widget_info(base_table(i),/valid_id)
	  wflag = where(flag,fcnt)
	  if fcnt gt 0 then begin
            index_table = index_table(wflag)
	    base_table = base_table(wflag)
	    sw_ind = sw_ind(wflag)
            sw_titl = sw_titl(wflag)
	    sw_fx = sw_fx(wflag)
	    sw_fy = sw_fy(wflag)
	    sw_vx = sw_vx(wflag)
	    sw_vy = sw_vy(wflag)
	    drw_wid = drw_wid(wflag)
	    swcnt = fcnt
	  endif else begin
	    index_table = lonarr(1) - 2
	  endelse
	endif
 
	;-------  Force an initial list if none  -----------
	if n_elements(index_table) eq 0 then begin
	  index_table = lonarr(1) - 2
	endif
 
	;-------  Find possible windows  ----------
	w = where(index_table gt 0, cnt)
 
	;----------  Set up menu lines  ------------
	it = index_table		; Move index_table into transfer com.
	if cnt gt 0 then begin
	  num = n_elements(w)
	  blab = strarr(num)
	endif else num = 0
	for i = 0, num-1 do begin
	  j = w(i)
	  t = '     Index:'+string(index_table(j),form='(i4)')
	  b = base_table(j)
	  if widget_info(b,/valid_id) then begin
	    t = t + '      Full (' + string(sw_fx(j),form='(i6)')
	    t = t + ',' + string(sw_fy(j),form='(i6)') + ')'
	    t = t + '      Vis (' + string(sw_vx(j),form='(i5)')
	    t = t + ',' + string(sw_vy(j),form='(i5)') + ')'
	    t = t + '        "' + sw_titl(j) + '"'
	  endif else begin
	    t = t + '      Does not exist'
	  endelse
	  blab(i) = t
	endfor
 
	;--------  Find currently active window (if any)  ---------
	act = !d.window
	wa = (where(act eq index_table, acnt))(0)
 
	;--------  Set up widget  -----------
	b0 = widget_base(title='Scrolling Windows',/column)
	b1 = widget_base(b0,/row,space=20)
	t = widget_button(b1,val='Quit',uval='QUIT')
	t = widget_button(b1,val='Help',uval='HELP')
	if num gt 0 then begin
	  ttl = '       Press button to change active windows.'
	endif else begin
	  ttl = '       There are no scrolling windows.  Click help.'
	endelse
	t = widget_label(b1,val=ttl)
 
	if num gt 0 then b = lonarr(num)
	for i = 0, num-1 do begin
	  bt = widget_base(b0,/row)
	  if widget_info(base_table(w(i)),/valid_id) then $
	    sens=1 else sens=0
	  bt2 = widget_button(bt,value=strtrim(sw_ind(w(i)),2),sens=sens,uval=i)
	  b(i) = bt2
	  blb = widget_label(bt,value=blab(i))
	endfor
 
	if acnt gt 0 then widget_control,b(wa), /set_butt, sens=0
	widget_control,/real,b0
 
	;--------  Register widget  ----------
	xmanager, 'swmenu', b0
 
	return
	end
