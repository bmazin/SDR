;-------------------------------------------------------------
;+
; NAME:
;       XTEXTFILE
; PURPOSE:
;       Explore a text file of unkown format.
; CATEGORY:
; CALLING SEQUENCE:
;       xtextfile
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         MAXBUFF=n  Max number of bytes to read (def=30000).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Feb 18
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro update, map
 
	widget_control, map.edit, get_uval=etab
	widget_control, map.start, get_val=start	; Buffer start byte.
	start = start(0)+0L
	widget_control, map.lo, get_val=lo		; Low offset.
	widget_control, map.hi, get_val=hi		; high offset.
	widget_control, map.cs, get_val=cs		; Custom offset.
	widget_control, map.step, get_val=step		; Custom step size.
	step = step(0)+0
	lst = n_elements(map.buff)-1
	index = (lo + hi*30L + cs*step)<(map.maxbuf-250)
	i1 = index<lst
	i2 = (i1 + 59)<lst
	widget_control, map.text, set_val=string(etab(map.buff(i1:i2)))
	widget_control, map.point, set_val=strtrim(index+start,2)
	return
	end
 
;====================================================================
;	xtextfile_event = Event handler.
;	R. Sterner, 1994 Feb 18
;====================================================================
 
	pro xtextfile_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=map
 
	if uval eq 'QUIT' then begin
	  if map.lun ne 0 then begin
	    close, map.lun
	    free_lun, map.lun
	  endif
	  widget_control, ev.top, /dest
	  return
	endif
 
	if uval eq 'OPEN' then begin
	  f = pickfile()
	  if f eq '' then return
	  if map.lun ne 0 then begin
	    close, map.lun
	    free_lun, map.lun
	  endif
	  openr, lun, f, /get_lun
	  widget_control, map.file, set_val=f
	  widget_control, map.start, set_val='0'
	  map.lun = lun
	  fs = fstat(lun)
	  t = bytarr(map.maxbuf<fs.size)
	  map.buff = bytarr(map.maxbuf)
	  readu,lun, t
	  last = n_elements(t)<map.maxbuf
	  map.buff(0:last-1) = t
	  widget_control, map.lo, set_val=0
	  widget_control, map.hi, set_val=0
	  widget_control, map.cs, set_val=0
	  widget_control, ev.top, set_uval=map
	  update, map
	  return
	endif
 
	if (uval eq 'LO') or (uval eq 'HI') or (uval eq 'CS') or $
	   (uval eq 'STEP') then begin
	  if map.lun eq 0 then return
	  update, map
	  return
	endif
 
	if uval eq 'START' then begin
start:	  if map.lun eq 0 then return
	  widget_control, map.start, get_val=start & start=start(0)+0L
	  fs = fstat(map.lun)
	  n = map.maxbuf<(fs.size-start)
	  map.buff = bytarr(map.maxbuf)
	  if n ge 1 then begin
	    t = bytarr(n)
	    point_lun, map.lun, start
	    readu,map.lun, t
	    map.buff(0:n-1) = t
	  endif
	  widget_control, map.lo, set_val=0
	  widget_control, map.hi, set_val=0
	  widget_control, map.cs, set_val=0
	  widget_control, ev.top, set_uval=map
	  update, map
	  return
	endif
 
	if uval eq 'COPY' then begin
	  widget_control, map.point, get_val=index
	  widget_control, map.start, set_val=index
	  goto, start
	endif
 
	if uval eq 'HELP' then begin
	  xhelp,['XTESTFILE may be used to examine a text file',$
		 'of unkown format.  After a text file has been',$
		 'opened it is read as a byte stream and displayed',$
		 'in the display window 60 characters at a time.',$
		 ' ',$
		 'Use the slider bars to scroll through the file.',$
		 'The fine slider bar moves by one character, the',$
		 'coarse by 30 and the custom by a specified number',$
		 'of characters as set in the text field below it.',$
		 'The custom step slider bar is useful to check on',$
		 'an estimated record length.',' ',$
		 'The start byte may be set to jump into the file',$
		 'by the number of characters specified.',' ',$
		 'Invisible characters, such as Line Feeds, may be',$
		 'made visible by replacing them by another character',$
		 'as specified in the edit table.  The ascii code of',$
		 'original character is on the left and the ascii',$
		 'code to substitute is on the right.  This table',$
		 'may be modified.  The default table makes Line Feeds',$
		 'and Null Characters visible.  An ascii table may',$
		 'be displayed using the ascii table button.'],$
	    	 group=ev.top
	  return
	endif
 
	if uval eq 'EHELP' then begin
	  xhelp,['The edit window contains pairs of',$
		 'ascii codes.  The original ascii',$
	    	 'code on the left will be replaced',$
	    	 'by the code on the right before',$
		 'the text is displayed.  Pairs may',$
	    	 'be added, changed  or deleted.'],$
	    	 group=ev.top
	  return
	endif
 
	if uval eq 'ASCII' then begin
	  t=strarr(257)
	  t(0) = 'Ascii  Char'
	  for i=0,255 do t(i+1)=string(i,form='(i3)')+'   '+string(byte(i))
	  xhelp,t,titl=['Ascii table','Scroll down'],exit='Quit',group=ev.top
	  return
	endif
 
	if uval eq 'EDIT' then begin
	  widget_control, ev.id, get_val=t	; Get table of substitutions.
	  n = n_elements(t)			; Table size.
	  etab = bindgen(256)			; Table for no changes.
	  for i=0,n-1 do begin			; Add changes.
	    in = getwrd(t(i))+0			; Ascii code to change.
	    etab(in) = getwrd('',1)+0B		; What to change to.
	  endfor
	  widget_control, map.edit, set_uval=etab	; Store edit table.
	  update, map
	  return
	endif
 
	return
	end
 
;====================================================================
;	xtextfile.pro = Explore a text file
;	R. Sterner, 1994 Feb 18
;====================================================================
 
	pro xtextfile, maxbuff=maxbuf, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Explore a text file of unkown format.'
	  print,' xtextfile'
	  print,'   No args.  Widget based.'
	  print,' Keywords:'
	  print,'   MAXBUFF=n  Max number of bytes to read (def=30000).'
	  return
	endif
 
	if n_elements(maxbuf) eq 0 then maxbuf = 30000
 
	;-------  Widget layout  -------------
	top = widget_base(/column)
	;---------------------------------------
	b = widget_base(top, /row, title=' ')
	id = widget_button(b, val='Open a file', uval='OPEN')
	id = widget_button(b, val='Quit',uval='QUIT')
	id = widget_button(b, val='Help',uval='HELP')
	;---------------------------------------
	b = widget_base(top, /row)
	id = widget_label(b,val='File:')
	id_file = widget_label(b,val='No file has been opened yet.',/dynamic)
	;---------------------------------------
	id_text = widget_text(top,xsize=60)
	;---------------------------------------
	b = widget_base(top, /row)
	pt = widget_label(b,val=' ',/dynamic)
	;---------------------------------------
	lo = widget_slider(top,xsiz=500,max=250,/drag,titl='Fine',uval='LO')
	hi =widget_slider(top,xsiz=500,max=250,/drag,titl='Coarse',uval='HI')
	cs = widget_slider(top,xsiz=500,max=250,/drag,titl='Custom',uval='CS')
	;---------------------------------------
	b = widget_base(top, /row)
	id = widget_label(b,val='Start byte:')
	id_start = widget_text(b,val='0',uval='START',/edit,xsize=10)
	id = widget_button(b,val='Copy current',uval='COPY')
	id = widget_label(b,val='Custom step:')
	id_step = widget_text(b,val='80',uval='STEP',/edit,xsize=10)
	;---------------------------------------
	b = widget_base(top, /row)
	etab = b
	id = widget_label(b,val='Edit table:')
	t = ['10 127','0  179']			; Def edit table.
	id = widget_text(b,/edit,val=t,ysize=5,xsize=10,uval='EDIT')
	n = n_elements(t)			; Table size.
	et = bindgen(256)			; Table for no changes.
	for i=0,n-1 do begin			; Add changes.
	  in = getwrd(t(i))+0			; Ascii code to change.
	  et(in) = getwrd('',1)+0B		; What to change to.
	endfor
	widget_control, etab, set_uval=et	; Store edit table.
	bb = widget_base(b, /column)
	id = widget_button(bb,val='Edit help', uval='EHELP')
	id = widget_button(bb,val='Ascii table', uval='ASCII')
 
	;--------  Activate  -----------------
	widget_control, top, /real
 
	;--------  Info  -----------------------
	map = {file:id_file, text:id_text, start:id_start, lo:lo, hi:hi, $
	  lun:0, buff:bytarr(maxbuf), last:0L, maxbuf:maxbuf, $
	  edit:etab, point:pt, cs:cs, step:id_step}
	widget_control, top, set_uval=map
 
	xmanager, 'xtextfile', top
 
	return
 
	end
