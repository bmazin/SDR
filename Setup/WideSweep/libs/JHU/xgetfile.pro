;-------------------------------------------------------------
;+
; NAME:
;       XGETFILE
; PURPOSE:
;       Widget based file selection routine.
; CATEGORY:
; CALLING SEQUENCE:
;       f = xgetfile()
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         TEXT=txt  Text string or array to display at top
;           of widget (def=Select a file).
;         DEF_DIR=name  Name of default directory initialization
;           file.  Will read in list of directories when at start
;           and save updated list on exit.  Created if none exists.
;           If not given _def_dir.txt is used.
;         SET_PATH=p1  Set initial path (def=current).
;         GET_PATH=p2  Return final path.
;         SET_FILE=f1  Set initial file (def=none).
;         GET_FILE=f2  Return final file.
;         WILD_CARD=w  Set wildcard (filter, def=*).
; OUTPUTS:
;       f = return full file name (includes path).   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Feb 15
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro update_menu, map
 
	;-------  Drop old entries  -------
	widget_control, map.menu, get_uval=inwids
	n = n_elements(inwids)
	for i=0,n-1 do widget_control, inwids(i),/dest
	;-------  Add new entries  ---------
	widget_control, map.dir, get_val=dir & dir=dir(0)
	list = dirmem(dir,read=map.init,alias=2,write=map.init)
	n = n_elements(list)
	outwids = lonarr(n)
        for i=0,n-1 do begin
          d = getwrd(list(i),1,9)
          w = widget_button(map.menu,val=d,uval='MENU '+strtrim(list(i)))
          outwids(i) = w
        endfor
 
	widget_control, map.menu, set_uval=outwids
 
	return
	end
 
;==================================================================
;	update_list = Update file list.
;	R. Sterner, 1994 Feb 14
;==================================================================
 
	pro update_list, map
 
	widget_control, map.dir, get_val=dir
	dir = getwrd(dir(0))
	widget_control, map.wild, get_val=wild
	fp = filename(dir(0),wild(0),/nosym,delim=del)
	f = findfile(fp, count=cnt)
	if cnt eq 0 then begin
	  widget_control, map.list, set_val='No files found'
	endif else begin
          for i = 0, n_elements(f)-1 do f(i)=getwrd(f(i),/last,delim=del)
	  widget_control, map.list, set_val=f
	endelse
	widget_control, map.store, set_uval=f
	widget_control, map.found, set_val='Files found: '+ $
	  strtrim(n_elements(f),2)
 
	return
	end
 
;==================================================================
;	xgetfile_event = Event handler.
;	R. Sterner, 1994 Feb 14.
;==================================================================
 
	pro xgetfile_event, ev
 
	widget_control, ev.id, get_uval=uval
	cmd = getwrd(uval)
	widget_control, ev.top, get_uval=map
 
	if cmd eq 'DIR' then begin
	  update_menu, map
	  update_list, map
	  return
	endif
 
	if cmd eq 'LIST' then begin
	  widget_control, map.store, get_uval=list
	  widget_control, map.file, set_val=list(ev.index)
	  return
	endif
 
	if cmd eq 'MENU' then begin
	  widget_control, /hour
	  widget_control, map.dir, set_val=getwrd(uval,1,9)
	  update_list, map
 	  return
	endif
 
	if cmd eq 'WILD' then begin
	  widget_control, /hour
	  update_list, map
 	  return
	endif
 
	if cmd eq 'CANCEL' then begin
	  widget_control, map.res, set_uval=''
	  widget_control, ev.top, /dest
	  return
	endif
 
	if cmd eq 'OK' then begin
	  widget_control, map.dir, get_val=dir  & dir=getwrd(dir(0))
	  widget_control, map.file, get_val=file  & file=file(0)
	  f = filename(dir,file,/nosym)
	  widget_control, map.res, set_uval=f
	  widget_control, ev.top, /dest
	  return
	endif
 
	return
	end
 
;==================================================================
;	xgetfile.pro = Widget based file selection routine.
;	R. Sterner, 1994 Feb 14.
;==================================================================
 
	function xgetfile, text=text, def_dir=init, set_path=set_path, $
	  get_path=get_path, set_file=set_file, get_file=get_file, $
	  wild_card=wild, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Widget based file selection routine.'
	  print,' f = xgetfile()'
	  print,'   f = return full file name (includes path).   out'
	  print,' Keywords:'
	  print,'   TEXT=txt  Text string or array to display at top'
	  print,'     of widget (def=Select a file).'
	  print,'   DEF_DIR=name  Name of default directory initialization'
	  print,'     file.  Will read in list of directories when at start'
	  print,'     and save updated list on exit.  Created if none exists.'
	  print,'     If not given _def_dir.txt is used.'
	  print,'   SET_PATH=p1  Set initial path (def=current).'
	  print,'   GET_PATH=p2  Return final path.'
	  print,'   SET_FILE=f1  Set initial file (def=none).'
	  print,'   GET_FILE=f2  Return final file.'
	  print,'   WILD_CARD=w  Set wildcard (filter, def=*).'
	  return, ''
	endif
 
	;--------  Defaults  -------------
	if n_elements(init) eq 0 then init='_def_dir.txt'
	dlist = dirmem(read=init,list=list,max=8,/alias)
	if n_elements(set_path) eq 0 then set_path=list(0)
	if n_elements(set_file) eq 0 then set_file=''
	if n_elements(wild) eq 0 then wild='*'
	dsz = 50 & fsz = 50 & wsz = 20
	if strupcase(!version.os) eq 'MACOS' then begin
	  dsz = 20 & fsz = 20 & wsz = 10
	endif
 
	;--------  Build widget  -----------------------
	top = widget_base(/column)			; Top.
	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	if n_elements(text) ne 0 then begin		; Optional text.
	  for i=0,n_elements(text)-1 do begin
	    id = widget_label(top,val=text(i))
	  endfor
	endif
	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	bb = widget_base(top,/row)
	menu = widget_button(bb,val='Directory List',menu=2)  ; Dir list menu.
	n = n_elements(list)
	wids = lonarr(n)
	aliases = dlist
	for i=0,n-1 do begin
	  wids(i) = widget_button(menu,val=dlist(i),uval='MENU '+$
	    strtrim(list(i)))
	endfor
	id = widget_button(bb,val='OK',uval='OK')	  ; OK button.
	id = widget_button(bb,val='Cancel',uval='CANCEL')  ; Cancel button.
	id = widget_button(bb,val='Help',uval='HELP')      ; Help button.
	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	b = widget_base(top,/row)
	id = widget_label(b,val='Directory')
	id_dir = widget_text(b,/edit,xsize=dsz,uval='DIR',val=set_path) ; Dir.
	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	b = widget_base(top,/row)
	id = widget_label(b,val='File')
	id_file = widget_text(b,/edit,xsize=fsz,uval='FILE',val=set_file) ;File.
	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	b = widget_base(top,/row)
	id = widget_label(b,val='Wildcard')
	id_wild = widget_text(b,/edit,xsize=wsz,uval='WILD',val=wild) ;Wildcard.
	id_found = widget_label(b,val='Files found:      ')
	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	id_list = widget_list(top,xsize=dsz,ysize=8,uval='LIST')
 
	;----------  Package location information  ----------
	widget_control, menu, set_uval=wids
	res = widget_base()
	map = {dir:id_dir, file:id_file, wild:id_wild, list:id_list, res:res, $
	  menu:menu, init:init, store:bb, found:id_found}
	widget_control, top, set_uval=map
 
	;----------  Activate widget  ---------------
	widget_control, top, /real
	update_list, map
 
	;---------  register  ---------------
	xmanager, 'xgetfile', top
 
	widget_control, res, get_uval=f
 
	return,f
	end
