;-------------------------------------------------------------
;+
; NAME:
;       XHOTLIST
; PURPOSE:
;       Widget based hotlist of items.
; CATEGORY:
; CALLING SEQUENCE:
;       xhotlist
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         FILE=f    Full name of hotlist file (format below).
;         OUT=t     Returned selected item (null for cancel).
;            This will be a directory if browse option used.
;         BROWSE=bfile  Returned file selected by browse if any.
;            If this is not null then it was the selected file.
;         TITLE=tt  Hotlist title (def=none).
;         VALUE=v   Current incoming value (def=none).
;         DESCRIPTION=d  Current incoming description (def=none).
;           Above two keywords used for Add Current. For example:
;           VALUE might be a subdirectory and DESCR its description.
;         /READONLY Suppress file modification buttons (no update).
;         XSIZE=xs  Max text window width in characters (def=30).
;         YSIZE=ys  Max text window height in characters (def=12).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: A hotlist is a good way to provide easy access to a
;         a number of frequently used items such as directories.
;         The hotlist resides in a text file of the following format.
;           Line 1:  Title line
;           Line 2:  Title line
;           Line 3:  Value_1
;           Line 5:  Description_1.
;           Line 6:  Value_2
;           Line 4:  Description_2.
;            . . .
;         First two lines (title lines) are ignored.
;         Values and descriptions are text strings.
;         Descriptions are what are actually displayed in the
;         hotlist.  The corresponding value is returned.
;       
;         The hotlist modification buttons (along widget bottom)
;         update the hotlist file.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Apr 28
;       R. Sterner, 1997 Sep 26 --- Added BROWSE button and keyword.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xhotlist_update, map
 
        w = where(map.flag eq 1,cnt)              ; Find ON items.
	if cnt gt 0 then begin			  ; Some items ON.
	  ;----  Collect scattered items flagged by 1s and squeeze  -----
	  ;----  them all to the front of the arrays.  ------------------
	  in = indgen(n_elements(w))		  ; Compressed indices.
	  map.item(in) = map.item(w)		  ; Compress.
	  map.text(in) = map.text(w)		  ; Compress.
	  map.flag = 0				  ; Clear flags.
	  map.flag(in) = 1			  ; Set ON flags.
	  ;------  Update display  ------------
          widget_control,map.list,set_val=map.text(in)  ; Display ON items.
	  ;-------  Rebuild contents of hotlist file and write it  --------
	  txt = [map.title]
	  for i = 0, n_elements(in)-1 do txt=[txt,map.item(i),map.text(i)]
	  putfile, map.file, txt
	endif else begin			  ; No items ON.
	  widget_control,map.list,set_val=''	  ; Display null.
	endelse
 
	return
	end
 
;=========================================================
;	xhotlist_event = Hotlist event handler.
;	R. Sterner, 1994 Apr 28
;=========================================================
 
	pro xhotlist_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=map
 
	if uval eq 'OK' then begin
	  widget_control, ev.top, /dest
	  if map.index ge 0 then begin
 	    widget_control, map.res, $
	      set_uval={outdir:map.item(map.index), bfile:''}
	  endif else begin
	    widget_control, map.res, set_uval={outdir:'',bfile:''}
	  endelse
	  return
	endif
 
	if uval eq 'BROWSE' then begin
;	  print,' Browse...'
	  ;----  Find starting directory for browse  -----
	  dir0 = map.start
	  if dir0 eq ' 'then cd,curr=dir0
	  if map.index ge 0 then dir0=map.item(map.index)
	  ;----  Make sure it exists  ------------
	  if (findfile(dir0))(0) eq '' then begin
	    xmess,['No such directory:',dir0]
	    return
	  endif
	  ;----  Browse using pickfile  ----------
	  out = pickfile(path=dir0,get_path=dir1,file=' ')
	  ;----  Determine browse results  -------
	  done_flag = 0			; Assume not done with hotlist.
	  pickpath = dir1		; Assume a file selected.
	  pickfile = out
	  if out eq ' ' then begin	; No file picked but OK clicked.
	    pickpath=dir1		; Just use new path.
	    pickfile=''			; No file.
	    done_flag = 1		; OK clicked, done with hotlist.
	  endif
	  if out eq '' then begin	; No file picked but Cancel clicked.
	    pickpath=dir0		; Use old path.
	    pickfile=''			; No file.
	  endif
	  ;-----  At this point path is ok, file may or may not exist  -----
	  ;-----  If done_flag set then clean up and return from hotlist.
	  if pickfile ne '' then done_flag=1  ; Picked a file, done with htlist.
;help,done_flag,pickpath,pickfile
	  if done_flag eq 1 then begin
;	    print,' *****  Exit with bpath = '+pickpath
;	    print,' *****  Exit with bfile = '+pickfile
	    widget_control, ev.top, /dest
 	    widget_control, map.res, set_uval={outdir:pickpath, bfile:pickfile}
	  endif
	  return
	endif
 
	if uval eq 'CANCEL' then begin
	  widget_control, ev.top, /dest
	  widget_control, map.res, set_uval={outdir:'',bfile:''}
	  return
	endif
 
	if uval eq 'HELP' then begin
	  txt = ['To highlight a list item click on it.',$
		'Click on OK to choose it or cancel to',$
		'  cancel selection.']
	  if map.readonly eq 0 then begin
	    txt = [txt, 'To add current click on Add Current.',$
                'To remove a list item, highlight it, then',$
                '  click on Remove.', $
                'To edit an item, highlight it, then',$
                '  click on Edit.',$
                'To swap an item with the one above,',$
                '  highlight it, then click on swap.']
	  endif
	  xhelp, txt
	  return
	endif
 
	if uval eq 'LIST' then begin
	  map.index = ev.index		; Save index of selection.
	  map.pick = 1			; Flag that a selection is available.
	  widget_control, map.id_ok, sensitive=1	; Turn on OK button.
	  widget_control, map.id_mod, sensitive=1	; Turn on modify bttns.
	  widget_control, ev.top, set_uval=map
	  return
	endif
 
	if uval eq 'ADD' then begin
	  ic = n_elements(map.flag) - 1			; Index of current.
	  if (map.flag(ic) eq 0) and (map.item(ic) ne '') then begin
	    w = where((map.item(ic) eq map.item(0:ic-1)) and $
		(map.flag ne 0), cnt)
	    if cnt ne 0 then begin
	      bell
	      txt = ['Error.','Current duplicates:',$
		map.text(w),'Cannot add current.']
	      xmess, txt
	    endif else begin
	      map.flag(ic) = 1				; Set flag to ON.
	      xhotlist_update, map
	      widget_control, ev.top, set_uval=map	; Save new flags.
	    endelse
	  endif
	endif
 
	if uval eq 'REMOVE' then begin
	  i = map.index
	  if i ge 0 then begin
	    map.flag(i) = 0				  ; Clear display flag.
	    xhotlist_update, map
	    map.index = -1
	    map.pick = 0	; Flag that no selection is available.
            widget_control, ev.top, set_uval=map          ; Save new flags.
	    widget_control, map.id_ok, sensitive=0
	    widget_control, map.id_mod, sensitive=0
	  endif
	endif
 
	if uval eq 'EDIT' then begin
	  i = map.index
	  if i ge 0 then begin
	    t0=map.text(i)
	    xtxtin,out, def=t0,title='Edit description:',/wait
	    if out eq '' then out=t0
	    map.text(i) = out
	    t0=map.item(i)
	    xtxtin,out, def=t0,title='Edit value:',/wait
	    if out eq '' then out=t0
	    map.item(i) = out
	    xhotlist_update, map
	    map.index = -1
	    map.pick = 0	; Flag that no selection is available.
            widget_control, ev.top, set_uval=map          ; Save new flags.
	    widget_control, map.id_ok, sensitive=0
	    widget_control, map.id_mod, sensitive=0
	  endif
	endif
 
	if uval eq 'SWAP' then begin
	  i = map.index
	  if i gt 0 then begin
	    t = map.item(i)
	    map.item(i) = map.item(i-1)
	    map.item(i-1) = t
	    t = map.text(i)
	    map.text(i) = map.text(i-1)
	    map.text(i-1) = t
	    xhotlist_update, map
	    map.pick = 0	; Flag that no selection is available.
            widget_control, ev.top, set_uval=map          ; Save new flags.
	    widget_control, map.id_ok, sensitive=0
	    widget_control, map.id_mod, sensitive=0
	  endif
	endif
 
	return
	end
 
 
;=========================================================
;	xhotlist.pro = Widget based hotlist of items.
;	R. Sterner, 1994 Apr 28
;=========================================================
 
	pro xhotlist, file=file, out=out, xsize=xsize, $
	  ysize=ysize, title=ttl, description=text, value=item, $
	  readonly=readonly, browse=browse, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Widget based hotlist of items.'
	  print,' xhotlist'
	  print,'   All args are keywords:'
	  print,' Keywords:'
	  print,'   FILE=f    Full name of hotlist file (format below).'
	  print,'   OUT=t     Returned selected item (null for cancel).'
	  print,'      This will be a directory if browse option used.'
	  print,'   BROWSE=bfile  Returned file selected by browse if any.'
	  print,'      If this is not null then it was the selected file.'
	  print,'   TITLE=tt  Hotlist title (def=none).'
	  print,'   VALUE=v   Current incoming value (def=none).'
	  print,'   DESCRIPTION=d  Current incoming description (def=none).'
	  print,'     Above two keywords used for Add Current. For example:'
	  print,'     VALUE might be a subdirectory and DESCR its description.'
	  print,'   /READONLY Suppress file modification buttons (no update).'
	  print,'   XSIZE=xs  Max text window width in characters (def=30).'
	  print,'   YSIZE=ys  Max text window height in characters (def=12).'
	  print,' Notes: A hotlist is a good way to provide easy access to a'
	  print,'   a number of frequently used items such as directories.'
	  print,'   The hotlist resides in a text file of the following format.'
	  print,'     Line 1:  Title line'
	  print,'     Line 2:  Title line'
	  print,'     Line 3:  Value_1'
	  print,'     Line 5:  Description_1.'
	  print,'     Line 6:  Value_2'
	  print,'     Line 4:  Description_2.'
	  print,'      . . .
	  print,'   First two lines (title lines) are ignored.'
	  print,'   Values and descriptions are text strings.'
	  print,'   Descriptions are what are actually displayed in the'
	  print,'   hotlist.  The corresponding value is returned.'
	  print,' '
	  print,'   The hotlist modification buttons (along widget bottom)'
	  print,'   update the hotlist file.'
	  return
	endif
 
	if n_elements(xsize) eq 0 then xsize = 30
	if n_elements(ysize) eq 0 then ysize = 12
	if n_elements(ttl) eq 0 then ttl = ' '
	if n_elements(item) eq 0 then item = ' '
	if n_elements(text) eq 0 then text = item
	if n_elements(readonly) eq 0 then readonly = 0
 
	;-------  Read hotlist from file  --------------
	if n_elements(file) eq 0 then begin
	  print,' Error in xhotlist: no hotlist file given.'
	  out = ''
	  return
	endif
	txt = getfile(file, error=err)
	if err ne 0 then begin
	  print,' Error in xhotlist: hotlist file not read.'
	  out = ''
	  return
	endif
	n = n_elements(txt)
	i = makei(2,n-1,2)
	;-------  Extract items and tags  ---------------
	out_txt = txt(i)	; Returnable text.
	dsp_txt = txt(i+1)	; Display text.
	flag = intarr(n_elements(dsp_txt)) + 1
	;-------  Add current but don't turn display flag on ----
	out_txt = [out_txt, item]
	dsp_txt = [dsp_txt, text]
	flag = [flag, 0]
	w = where(flag eq 1)
	;-------  Index lookup table  -----------
	look = indgen(n_elements(dsp_txt))
 
	xs = max(strlen(dsp_txt))<xsize
	ys = max(n_elements(dsp_txt))<ysize
 
	;===============================================
	;	Set up widget
	;===============================================
	top = widget_base(/column, title=' ')
 
	id = widget_label(top, val=ttl)
 
	id_list = widget_list(top,val=dsp_txt(w),xsize=xs,ysize=ys,uval='LIST')
 
	b = widget_base(top, /row)
	id_ok = widget_button(b, val='OK',uval='OK')
	widget_control, id_ok, sensitive=0
	id = widget_button(b, val='Cancel',uval='CANCEL')
	id = widget_button(b, val='Browse...',uval='BROWSE')
	id = widget_button(b, val='Help',uval='HELP')
	b = widget_base(top, /row)
 
	if not keyword_set(readonly) then begin
	  id_add = widget_button(b, val='Add Current',uval='ADD')
	  if item eq ' ' then widget_control, id_add, sensitive=0
	  id_mod = widget_base(b, /row)
	  id = widget_button(id_mod, val='Remove',uval='REMOVE')
	  id = widget_button(id_mod, val='Edit',uval='EDIT')
	  id = widget_button(id_mod, val='Swap',uval='SWAP')
	  widget_control, id_mod, sensitive=0
	endif
 
	widget_control, top, /real
	;=====================================================
 
	;--------  Make needed info available  ----------
	res = widget_base()
	map = {title:txt(0:1), item:out_txt, text:dsp_txt, flag:flag, $
	  index:-1, look:look, list:id_list, readonly:readonly, $
	  start:item, pick:0, id_ok:id_ok, id_add:id_add, id_mod:id_mod, $
	  file:file, res:res}
	widget_control, top, set_uval=map
 
	;---------  Event loop  -----------------------
	xmanager, 'xhotlist', top, /modal
 
	;--------  Get returned item  -----------------
	widget_control, res, get_uval=outval
	out = outval.outdir
	browse = outval.bfile
 
	return
	end
