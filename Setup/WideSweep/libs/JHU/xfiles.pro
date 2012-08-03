;-------------------------------------------------------------
;+
; NAME:
;       XFILES
; PURPOSE:
;       Select files, individual or ranges.
; CATEGORY:
; CALLING SEQUENCE:
;       xfiles
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=t  menu title.
;         FILES=f output array of selected files.
;         DIRECTORY=d initial directory (def=current).
;         PATTERN=p initial filename pattern (def=*.*).
;         NEWDIRECTORY=nd last directory used.        out
;         NEWPATTERN=np last file name pattern used.  out
;         /WAIT  means wait for a selection before returning.
;           Needed if called from another widget routine.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1 Jul, 1991
;       R. Sterner, somewhat reworked 8,9 Nov, 1993
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xfiles_event, ev
 
	name = strmid(tag_names(ev,/structure_name),7,1000)
	widget_control, ev.id, get_uvalue=uvalue
	widget_control, ev.top, get_uval=d
	widget_control, d.bbot, get_uval=fd
	cmd = strtrim(uvalue,2)			; May be a number.
 
	;----  Find new file list (for both directory and file pattern) --
	if (cmd eq 'DIR') or (cmd eq 'FPAT') or (cmd eq 'CURR') then begin
	  if cmd eq 'CURR' then begin
	    cd, curr=curr
	    widget_control, d.dir_id, set_val=curr
	  endif
	  xfiles_update, d
	  widget_control, d.bbot, get_uval=fd	; Get updated file list.
	  if fd.nn lt 1 then begin
	    xmess,'No files found'
	    return
	  endif
	  goto, sel
	endif
 
	;-------  Directory help  ------------
	if cmd eq 'DIR_HELP' then begin
	  whelp,[$
	    'The directory is the path where the files of',$
	    'interest are located. This may be changed from',$
	    'the default value by clicking in the text area.',$
	    'When the desired directory has been entered press APPLY',$
	    'to get an updated list of files.']
	  return
	endif
 
	;-------  Directory tree command  ------------
	if cmd eq 'TREE' then begin
	  xsubdir, out, start=d.m_dir, /wait
	  if out eq '' then return
	  widget_control, d.dir_id, set_val=out
	  d.m_pat = out
	  widget_control, ev.top, set_uval=d
	  xfiles_update, d
	  return
	endif
 
	;-------  File name pattern help  ------------
	if cmd eq 'PAT_HELP' then begin
	  whelp,[$
	    'The list of files is based on the specified file name',$
	    'pattern.  The pattern may contain ordinary wildcards, *,',$
	    'or the special wildcards $ or #.',$
	    'The wildcard $ means to sort that field as a string.',$
	    'The wildcard # means to sort that field as a number.',$
	    'Only one of $ or # may be used in the pattern, which',$
	    'may also contain one or more * (but not adjacent to any',$
	    'other wildcard characters.',$
	    'The wildcard handling is a bit primitive and will not',$
	    'handle all that the operating system could.',$
	    'When the desired pattern has been entered press APPLY',$
	    'to get an updated list of files.']
	  return
	endif
 
	;--------  Handle mode change  -------------
	if (cmd eq 'TR') or (cmd eq 'TI') then begin
	  case cmd of			; Find current mode.
	'TR': begin			; This is a bit messy because
	      tr_sel = ev.select	; either button may be pressed to
	      ti_sel = 1 - tr_sel	; toggle the button states.
	    end				; That is, a button may be toggled
	'TI': begin			; on or off by pressing it.  So
	      ti_sel = ev.select	; which button is pressed does not
	      tr_sel = 1 - ti_sel	; determine the state and thus the mode.
	    end
	  endcase
	  cmode = ti_sel + 2*tr_sel	; Current mode: 1 or 2.
	  if cmode ne d.mode then begin	; Mode changed, handle new mode.
	    d.mode = cmode
	    case d.mode of
	 1: begin
	      widget_control, d.lab1_id, set_value='Select individual files'
	      widget_control, d.lab2_id, set_value=' '
	    end
	 2: begin
	      widget_control, d.lab1_id, set_value='Select a range of files'
	      widget_control, d.lab2_id, set_value='Press range START file'
	      d.submode = 1
	    end
	    endcase
	    widget_control, ev.top, set_uval=d
	  endif  ; cmode ne mode
	  return
	endif  ; TR or TI
 
	;---------  DONE  -----------
	if cmd eq 'DONE' then begin
	  widget_control, ev.top, /destroy
	  vals = fd.vals
	  allfiles = fd.allfiles
	  w = where(vals eq 1, cnt)
	  if cnt gt 0 then begin
	    allfiles = allfiles(w)
	  endif else begin
	    allfiles = ''
	  endelse
	  res = {cnt:cnt, files:allfiles, dir:d.m_dir, pat:d.m_pat}
	  widget_control, d.result, set_uval=res
	  return
	endif
 
	;-----------  Toggle buttons  -------------
	if fd.nn lt 1 then return
 
	;---------  ALL_ON  -----------
	if cmd eq 'ALL_ON' then begin
	  for i=0, n_elements(fd.bids)-1 do begin
	    widget_control, fd.bids(i), set_button=1
	    fd.vals(i) = 1
	  endfor
	  goto, sel
	endif
 
	;---------  ALL_OFF  -----------
	if cmd eq 'ALL_OFF' then begin
	  for i=0, n_elements(fd.bids)-1 do begin
	    widget_control, fd.bids(i), set_button=0
	    fd.vals(i) = 0
	  endfor
	  goto, sel
	endif
 
	;---------  Assume file button  ------------
	if d.mode eq 1 then begin		; Individual file selection.
	  fd.vals(uvalue) = ev.select		; Update file selection flag.
	  widget_control, d.bbot, set_uval=fd	; Store new flags.
	  goto, sel
	endif  ; mode eq 1.
 
	if d.mode eq 2 then begin		; File range selection.
	  if d.submode eq 1 then begin		; Range start.
	    d.r_start = uvalue
	    d.r_set = ev.select			; May be on (1) or off (0).
	    fd.vals(d.r_start) = d.r_set
	    widget_control, d.lab2_id, set_value='Press range END file'
	    d.submode = 2
	  endif else begin			; Range end.
	    r_end = uvalue
	    step = 1				; Assume forward.
	    if r_end lt d.r_start then step = -1	; Was actually backward.
	    for i=d.r_start, r_end, step do begin
	      widget_control, fd.bids(i), set_button=d.r_set
	      fd.vals(i) = d.r_set
	    endfor
	    widget_control, d.lab2_id, set_value='Press range START file'
	    d.submode = 1
	  endelse  ; d.submode eq 2.
	endif  ; mode eq 2.
 
 
sel:	txt = strtrim(fix(total(fd.vals)),2)+' selected'
	widget_control, d.lab0_id, set_value=txt
	widget_control, ev.top, set_uval=d
	widget_control, d.bbot, set_uval=fd
	return
 
	end
 
;================================================================
;	xfiles_update = update file list.
;================================================================
 
	pro xfiles_update, d
 
	if d.bbot gt 0 then begin
	  widget_control, d.bbot, /destroy	; Delete old list.
	endif
 
	d.bbot = widget_base(d.bsides, /column, /frame, /nonex, y_scroll=300, $
	  x_scr=300)
 
	widget_control, d.dir_id, get_value=tmp
	d.m_dir = tmp(0)
	widget_control, d.pat_id, get_value=tmp
	d.m_pat = tmp(0)
	fname = filename(d.m_dir,d.m_pat,/nosym,delim=fdelim)
	allfiles = findfile3(fname,/quiet)
 
	nn = n_elements(allfiles)
	if allfiles(0) eq '' then nn = 0
	fdata = {nn:nn, labels:allfiles, bids:lonarr(nn>1), $
	  vals:bytarr(nn>1), allfiles:d.m_dir+fdelim+allfiles}
	widget_control, d.labnn_id, set_val='There are '+strtrim(nn,2)+' files'
 
	;-------  Buttons  -----------
	for i = 0, nn-1 do begin	; Loop thru labels making buttons.
	  x = widget_button(d.bbot, val=fdata.labels(i), uval=i)
	  fdata.bids(i) = x			; Save button id.
	endfor
	widget_control, d.bbot, set_uval=fdata
	widget_control, d.b0, set_uval=d
 
	return
	end
 
;================================================================
;	xfiles.pro = file selection pop-up widget
;	R. Sterner, 9 Nov, 1993 --- reworked from early version.
;================================================================
 
	pro xfiles, title=title, files=files, $
	  directory=directory, pattern=pattern, help=hlp, $
	  newdirectory=new_dir, newpattern=new_pat, wait=wait
 
	if keyword_set(hlp) then begin
	  print,' Select files, individual or ranges.'
	  print,' xfiles'
	  print,'   all parameters are keywords.'
	  print,' Keywords:'
	  print,'   TITLE=t  menu title.'
	  print,'   FILES=f output array of selected files.'
	  print,'   DIRECTORY=d initial directory (def=current).'
	  print,'   PATTERN=p initial filename pattern (def=*.*).'
	  print,'   NEWDIRECTORY=nd last directory used.        out'
	  print,'   NEWPATTERN=np last file name pattern used.  out'
	  print,'   /WAIT  means wait for a selection before returning.'
	  print,'     Needed if called from another widget routine.'
	  return
	endif
 
	;---------  Initialize  ----------
	if n_elements(title) eq 0 then title='Select files'
	if n_elements(directory) eq 0 then cd,current=directory
	if n_elements(pattern) eq 0 then pattern = '*.*'
	m_dir = directory
	m_pat = pattern
 
	;--------  main base  --------
	b0 = widget_base(title=title, /column)
	;--------  Directory  --------
	bd = widget_base(b0, /row)
	x = widget_label(bd, value='Directory')
 	dir_id = widget_text(bd, value=m_dir, /editable, uvalue='DIR', $
	  xsize=65)
	;--------  Left side  --------
	bsides = widget_base(b0, /row)
	bleft = widget_base(bsides, /column)
	bbot = widget_base(bsides, /column, /frame, /nonex, y_scroll=300,$
	  x_scr=300)
	b = widget_base(bleft,/row)
	x = widget_button(b,val='Set to current directory', uval='CURR')
	x = widget_button(b,val='Select directory ...', uval='TREE')
	;-------  File name pattern  ------
	bf = widget_base(bleft, /row)
	x = widget_label(bf, value='File name pattern')
 	pat_id = widget_text(bf, value=m_pat, /editable, uvalue='FPAT')
	;-------  Status display  --------
	bd = widget_base(bleft,/column)
	labnn_id = widget_label(bd, value='There are 0 files')
	lab0_id = widget_label(bd,value='0 are selected')
	;-------  Mode select  -------
	bm = widget_base(bleft, /exclusive, /row)
	ti_id = widget_button(bm, value='Select individual files',uval='TI')
	ti_sel = 1	; Save current state for a bit.
	widget_control, ti_id, set_button=1
	tr_id = widget_button(bm, value='Select a range of files',uval='TR')
	tr_sel = 0	; Save current state for a bit.
	mode = tr_sel*2 + ti_sel	; Compute toggle mode.
	;-------- Mode status display  -----
	bmd = widget_base(bleft, /column)
	lab1_id = widget_label(bmd, value='Select individual files')
	lab2_id = widget_label(bmd, value=' ')
 
	;-------  Buttons  -----------
	b = widget_base(bleft,/row)
	x = widget_button(b, value='Select All',uval='ALL_ON')
	b = widget_base(bleft,/row)
	x = widget_button(b, value='Select None',uval='ALL_OFF')
	b = widget_base(bleft,/row)
	x = widget_button(b, value='DONE',uval='DONE')
	b = widget_base(bleft,/row)
	x = widget_button(b, value='HELP',uval='HELP')
 
	;-------  Save global info  -------------
	result = widget_base()	; Unused top level base for returned values.
	data = {fbase:bleft, ti_id:ti_id,tr_id:tr_id,mode:mode,b0:b0,$
	  bbot:bbot,bsides:bsides,fname:' ',lab0_id:lab0_id,lab1_id:lab1_id, $
	  lab2_id:lab2_id, submode:0, r_start:0, $
	  r_set:0, labnn_id:labnn_id, dir_id:dir_id, $
	  pat_id:pat_id,  m_dir:m_dir, m_pat:m_pat, result:result}
	fdata = {nn:0, labels:[' '], bids:[0], vals:[0], allfiles:[' ']}
	widget_control, b0, set_uval=data
 
	;-------  Do file list  --------
	xfiles_update, data
 
	;-------  Create widget  ------
	widget_control, b0, /realize
 
	;-------  Start event loop  ----------
	xmanager, 'xfiles', b0, modal=wait
 
	;-------  Retrieve results  --------
	widget_control, result, get_uval=res
	files = res.files
	new_dir = res.dir
	new_pat = res.pat
 
	return
	end
