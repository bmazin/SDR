;-------------------------------------------------------------
;+
; NAME:
;       XSUBDIR
; PURPOSE:
;       Widget based subdirectory selection tool.
; CATEGORY:
; CALLING SEQUENCE:
;       xsubdir, out
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         START=dir  Starting directory (def=current).
;         TITLE=tt   Widget title (def="Select directory").
;         /WAIT  means wait for returned result.
; OUTPUTS:
;       out = name of selected directory.  out
;         Null string means no change.
; COMMON BLOCKS:
; NOTES:
;       Notes: May move up or down in directory tree.
; MODIFICATION HISTORY:
;       R. Sterner, 9 Nov, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xsubdir_event, ev
 
	widget_control, ev.id, get_uval=name
	widget_control, ev.top, get_uval=d
 
	if name eq 'OK' then begin
	  widget_control, d.id_dir, get_val=txt
	  txt = txt(0)
	  widget_control, d.res, set_uval=txt
	  widget_control, ev.top, /dest
	  return
	endif
 
	if name eq 'CANCEL' then begin
	  widget_control, ev.top, /dest
	  widget_control, d.res, set_uval=''
	  return
	endif
 
	if name eq 'START' then begin
	  widget_control, d.id_dir, set_val=d.start
	  xsubdir_list, d				; Update all.
	  return
	endif
 
	if name eq 'HELP' then begin
	  whelp,['Directory selection',' ',$
		 'A directory is displayed with its',$
		 'subdirectories in the lower window.',$
		 'Use the mouse to click on a subdirectory.',$
		 'It becomes the new directory and has its',$
		 'subdirectories listed.  Click on .. to move',$
		 'up a level. A new directory may be entered,',$
		 'press RETURN to update the subdirectories.',' ',$
		 'The OK button returns the displayed directory.',$
		 'The CANCEL button returns a null string.',$
		 'The Set entry directory resets to the directory',$
		 '  displayed at startup.']
	  return
	endif
 
	if name eq 'DIR' then begin
	  xsubdir_list, d				; Update all.
	  return
	endif
 
	if name eq 'LIST' then begin
	  widget_control, d.id_dir, get_val=curr	; Current directory.
	  curr = curr(0)
	  if curr eq '/' then curr = ''			; <===<< unix only.
	  widget_control, d.but, get_uval=txt		; Get subdirs list.
	  sub = txt(ev.index)				; Selected subdir.
	  if sub eq '..' then begin			; Go up a level.
	    sub = '/'+getwrd(curr,delim='/',/last,-99,-1) ; <===<<< unix only.
	  endif else begin
	    sub = curr+'/'+sub				; <===<< unix only.
	  endelse
	  widget_control, d.id_dir, set_val=sub		; New directory.
	  xsubdir_list, d				; Update all.
	  return
	endif
 
	return
	end
 
;=====================================================================
;	xsubdir_list = Find and display subdirectory list
;	R. Sterner, 9 Nov, 1993
;=====================================================================
 
	pro xsubdir_list, d
 
	widget_control, d.id_dir, get_val=dir		; Get directory.
	cmd = 'ls -F '+dir+' | grep / | cut -f 1 -d /'	; Subdirectory command.
	spawn, cmd, txt					; Find subdirectories.
	txt = ['..',txt]
	widget_control, d.id_list, set_val=txt		; Display.
	widget_control, d.but, set_uval=txt		; Remember.
 
	return
	end
 
;=====================================================================
;	xsubdir.pro = Widget subdirectory selection tool
;	R. Sterner, 9 Nov, 1993
;=====================================================================
 
	pro xsubdir, out, start=start, title=title, wait=wait, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Widget based subdirectory selection tool.'
	  print,' xsubdir, out'
	  print,'   out = name of selected directory.  out'
	  print,'     Null string means no change.'
	  print,' Keywords:'
	  print,'   START=dir  Starting directory (def=current).'
	  print,'   TITLE=tt   Widget title (def="Select directory").'
	  print,'   /WAIT  means wait for returned result.'
	  print,' Notes: May move up or down in directory tree.'
	  return
	endif
 
	if n_elements(start) eq 0 then cd, curr=start
	if n_elements(title) eq 0 then title='Select directory'
 
	;------  Lay out widget  ----------
	top = widget_base(/column,title=title)
	but = widget_base(top, /row)
	b = widget_button(but, val='OK',uval='OK')
	b = widget_button(but, val='Cancel',uval='CANCEL')
	b = widget_button(but, val='Set entry directory',uval='START')
	b = widget_button(but, val='Help',uval='HELP')
	id = widget_label(top,val='Current directory')
	id_dir = widget_text(top,/edit,xsize=60,val=start,uval='DIR')
	id = widget_label(top,val=' ')
	id = widget_label(top,val='Subdirectories')
	id_list = widget_list(top, ysize=10,uval='LIST')
 
	;------  Package and store needed info  ------------
	res = widget_base()
	data = {id_dir:id_dir, id_list:id_list, but:but, start:start, res:res}
	widget_control, top, set_uval=data
 
	;------  Find and display subdirectory list  ------
	xsubdir_list, data
 
	;------  realize widget  -----------
	widget_control, top, /real
 
	;------  Event loop  ---------------
	if n_elements(wait) eq 0 then wait = 0
	xmanager, 'xsubdir', top, modal=wait
 
	;------  Get result  ---------------
	widget_control, res, get_uval=out
 
	return
	end
