;-------------------------------------------------------------
;+
; NAME:
;       XLINER
; PURPOSE:
;       Display one line descriptions of routines given keywords.
; CATEGORY:
; CALLING SEQUENCE:
;       xliner
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /ADDLIBS display info on how to add help on any IDL
;           libraries that use the standard front-end documentation.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: click on a listed routine for its built-in help.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Oct 15
;       R. Sterner, 2003 Oct 28 --- Allowed help text to be saved.
;       R. Sterner, 2004 Jan 08 --- Allowed help for any IDL library with
;       standard front-end template.
;       R. Sterner, 2004 Jan 09 --- Allowed libs to be turned off in xliner.txt.
;       R. Sterner, 2004 Jan 09 --- Handled built in routines as special case.
;       R. Sterner, 2005 Jun 21 --- Now can display full source code.
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xliner_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=s
 
	;---------------------------------------------
	;  Quit xliner.  Free pointer to match list.
	;---------------------------------------------
	if uval eq 'QUIT' then begin
	  ptr_free, s.p_results
	  widget_control, ev.top, /destroy
	  return
	endif
 
	;---------------------------------------------
	;  Enter keywords and check all libraries
	;  for one line descriptions that contain all
	;  keywords.
	;---------------------------------------------
	if uval eq 'KEY' then begin
	  ;-----  Init search  ---------------
	  widget_control, s.id_key, get_val=val		; Get keywords.
	  if strcompress(val,/rem) eq '' then begin	; Any?
	    widget_control, s.id_results, $
	      set_val='Must enter one or more keywords.'
	    widget_control, s.id_num_match,set_val=''
	    s.n_results = 0
	    widget_control, ev.top, set_uval=s
	    return
	  endif
	  nval = nwrds(val)
	  w = where(s.state,n)				; Active directories.
	  if n eq 0 then begin				; Any?
	    widget_control, s.id_results, set_val='No directories selected.'
	    widget_control, s.id_num_match,set_val=''
	    s.n_results = 0
	    widget_control, ev.top, set_uval=s
	    return
	  endif
	  dlist = s.srch(w)				; alph.one files.
	  blist = s.base(w)				; Base directories.
	  llist = s.lib(w)				; Lib names.
	  stxt = 'Searching '+strtrim(n,2)+ ' director'+ $
	    plural(n,'y','ies')+' . . .'
	  widget_control, s.id_results, set_val=stxt
	  all_list = ['']				; Matches for all dirs.
	  ;-------  Directories loop  --------
	  for j=0,n-1 do begin				; Loop through dirs.
	    widget_control, s.id_results, set_val=[stxt,blist(j)]
	    txt = getfile(dlist(j))			; Read alph.one.
	    ;--------  Keywords loop  ------------
	    for i=0, nval-1 do begin			; Loop through keywords.
	      wd = getwrd(val,i)			; Grab keyword.
	      strfind, txt, wd, index=in, /quiet	; Test remaining text.
	      if in(0) eq -1 then break			; Not there, done.
	      txt = txt(in)				; Was there, subset.
	    endfor
	    if in(0) ne -1 then all_list=[all_list,llist(j)+' '+txt]
	  endfor ; j
	  if n_elements(all_list) eq 1 then begin
	    widget_control, s.id_results, set_val='No matches found.'
	    widget_control, s.id_num_match,set_val='0 matches'
	    s.n_results = 0
	  endif else begin
	    all_list = all_list(1:*)			    ; Drop seed.
	    widget_control, s.id_results, set_val=all_list  ; Display.
	    ptr_free, s.p_results			    ; Save in top uval.
	    s.p_results = ptr_new(all_list)
	    s.n_results = n_elements(all_list)		    ; List size.
	    widget_control, s.id_num_match,set_val=strtrim(s.n_results,2)+$
	      ' match'+plural(s.n_results,'','es')
	  endelse
	  widget_control, ev.top, set_uval=s		; Save in top uval.
	  return
	endif
 
	;---------------------------------------------
	;  Click on a one line description to bring
	;  up the full help text.
	;---------------------------------------------
	if uval eq 'RESULTS' then begin
	  txt = *s.p_results			; Grab results.
	  off = ev.offset			; Grab offset into text.
	  len = cumulate(strlen(['',txt]))+indgen(n_elements(txt)+1) ; Len.
	  w = where(off ge len)			; Fing which line in results.
	  line = max(w)
	  if line ge s.n_results then return
	  tmp = getwrd(txt(line),del=':')	; Pick off lib and routine.
	  lib = getwrd(tmp)
	  rout = getwrd(tmp,1)
	  if lib eq 'built_in' then begin
	    t = [rout+' is an internal routine in IDL',$
		'Use ? in IDL to call up the online help',$
		'and look in the Index under first letter.']
	    xhelp,t,exit='Dismiss'
	    return
	  endif
	  save_help = rout+'_help_text.txt'
	  w = where(lib eq s.lib)		; Find directory.
	  dir = s.base(w(0))
	  f = filename(dir,rout+'.pro',/nosym)	; Full path to routine.
	  t = getfile(f)			; Read it in.
	  w1 = where(t eq ';+', c1)		; Look for header.
	  w2 = where(t eq ';-', c2)
	  if (c1 ne 0) and (c2 ne 0) then begin	; Display just the help text.
	    xhelp,t(w1(0):w2(0)),exit='Dismiss',save=save_help,$
	      text2=t,t2lab='Source code'
	  endif else begin			; Display complete routine.
	    xhelp,t,exit='Dismiss',save=save_help
	  endelse
	  return
	endif
 
	;---------------------------------------------
	;  Clear keyword area.  Just a convenience.
	;---------------------------------------------
	if uval eq 'CLEAR' then begin
	  widget_control, s.id_key, set_val=''
	  return
	endif
 
	;---------------------------------------------
	;  Select all listed IDL libraries.  Useful
	;  if all or many were unselected.
	;---------------------------------------------
	if uval eq 'ALL' then begin
	  for i=0,s.n-1 do begin
	    widget_control, s.sel_id(i),/set_button
	    s.state(i) = 1
	  endfor
	  widget_control, ev.top, set_uval=s
	  return
	endif
 
	;---------------------------------------------
	;  Deselect all listed IDL libraries.  Useful
	;  if only a few are wanted.
	;---------------------------------------------
	if uval eq 'NONE' then begin
	  for i=0,s.n-1 do begin
	    widget_control, s.sel_id(i),set_button=0
	    s.state(i) = 0
	  endfor
	  widget_control, ev.top, set_uval=s
	  return
	endif
 
	;---------------------------------------------
	;  Select or unselect an IDL library.
	;---------------------------------------------
	;----  Toggle a button  -----
	s.state(uval) = ev.select
	widget_control, ev.top, set_uval=s
 
	end
 
;-------------------------------------------------------------
;	Main routine
;-------------------------------------------------------------
 
	pro xliner, help=hlp, addlibs=addlibs
 
	if keyword_set(hlp) then begin
	  print,' Display one line descriptions of routines given keywords.'
	  print,' xliner'
	  print,'   No args, widget based.'
	  print,' Keywords:'
	  print,'   /ADDLIBS display info on how to add help on any IDL'
	  print,'     libraries that use the standard front-end documentation.'
	  print,' Notes: click on a listed routine for its built-in help.'
	  return
	endif
 
	;====  Display information on adding help for any IDL library  =====
	if keyword_set(addlibs) then begin
	  whoami, dir
	  file = filename(dir,'xliner_addlibs.txt',/nosym)
	  t = getfile(file,err=err)
	  if err ne 0 then begin
	    xmess,['Could not open:',file]
	    return
	  endif
	  xhelp,t, save='xliner_addlibs.txt'
	  return
	endif
 
	;====  Find all alph.one files on path  =======
	path,path=list			; All path dirrctories.
 
	n = n_elements(list)		; Total # libraries on path.
	srch = ['']			; Directories with alph.one.
	base = ['']			; Library directory.
	lib = ['']			; Library name.
	tmp = filename('','',delim=del)	; Get path delimiter.
 
	;----  Check libraries on path  -------
	for i=0,n-1 do begin		; Check for alph.one files.
	  nam = filename(list(i),'alph.one',/nosym)
	  f = file_search(nam,count=cnt)
	  if cnt gt 0 then begin	; Found alph.one in this IDL lib.
	    srch = [srch,nam]		; Save full alph.one path.
	    base = [base,list(i)]	; And just lib directory.
	    lib = [lib,getwrd(list(i),del=del,/last)]	; And short lib name.
	  endif
	endfor
 
	;----  Check for user defined aplh.one files  ------
	home = getenv('HOME')
	try = filename(home,'xliner.txt',/nosym)
	f = file_search(try,count=c)
	if c eq 0 then begin
	  try = filename(home,'.xliner.txt',/nosym)
	  f = file_search(try,count=c)
	endif
	noff = 0				; # of libs to turn off.
	;-------  Process xliner control file  ------
	if c gt 0 then begin	; Found xliner.txt or .xliner.txt in $HOME.
	  t = getfile(f(0))	; Read file (xliner.txt or .xliner.txt).
	  t = drop_comments(t)	; Ignore comments.
	  n = n_elements(t)	; # lines.
	  ;-----  Look for OFF line  ------
;	  noff = 0				; # of libs to turn off.
	  tmp = strarr(n)			; Array to hold first word.
	  for i=0,n-1 do tmp(i)=getwrd(t(i))	; Grab first word.
	  w = where(strupcase(tmp) eq 'OFF',comp=cmp,c)	; Look for OFF.
	  if c gt 0 then begin			; Found it.
	    tmp = getwrd(t(w(0)),1,del='=')	; Grab value of OFF line.
	    t = t(cmp)				; Drop OFF line.
	    n = n-1				; New count for t.
	    wordarray,tmp,off,number=noff	; Split libs to turn off.
	  endif
	  ;-----  Loop through added libraries  ----------
	  for i=0,n-1 do begin	; Loop through library entries.
	    tt = t(i)		; i'th library.
	    nw = nwrds(tt)	; # items on line.
	    if nw ne 3 then begin	; Must be 3.
	      print,' Error in xliner: Problem with '+f(0)
	      print,'   That file must have 3 items on each library line.'
	      print,'   Problem line:'
	      print,' '+tt
	      print,'   Ignored.'
	      continue
	    endif
	    srch = [srch,getwrd(tt,0)]	; Add fill path to alph.pne file.
	    base = [base,getwrd(tt,1)]	; Add full path to library.
	     lib = [ lib,getwrd(tt,2)]	; Add short name for library.
	  endfor
	endif
 
	if n_elements(srch) eq 1 then begin
	  print,' No alph.one files found on path.'
	  return
	endif
 
	srch = srch(1:*)	; Drop off seed values.
	base = base(1:*)
	lib = lib(1:*)
	n = n_elements(srch)	; # IDL libs with alph.one.
	state = intarr(n) + 1	; Select state, def=all.
	sel_id = lonarr(n)	; For lib select buttons (for ALL or NONE).
 
	;-----  Deal with any libs to turn off  -------
	if noff gt 0 then begin
	  for i=0,noff-1 do begin
	    w = where(lib eq off(i),c)
	    if c gt 0 then state(w(0))=0
	  endfor
	endif
 
	;-----  Layout widget  ------------
	top = widget_base(/col, title='XLINER')
 
	;-----  Libraries to search area ---------
	b = widget_base(top,/row)
	id = widget_label(b,val='IDL libraries to search')
	id = widget_button(b,val='All',uval='ALL')
	id = widget_button(b,val='None',uval='NONE')
	id = widget_label(b,val='   ')
	id = widget_button(b,val='Quit',uval='QUIT')
	b = widget_base(top,/col,/frame,/scroll,/nonex,x_scr=300,y_scr=200)
	for i=0,n-1 do begin		; Set up lib selection buttons.
	  id = widget_button(b,val=base(i),uval=strtrim(i,2))
	  if state(i) then widget_control, id, /set_button
	  sel_id(i) = id
	endfor
 
	;----  Keyword area  -------
	b = widget_base(top,/row)
	id = widget_label(b,val='Keywords:')
	id_key = widget_text(b,xsize=40,/edit,uval='KEY')
	id = widget_button(b,val='Search',uval='KEY')
	id = widget_button(b,val='Clear',uval='CLEAR')
	id_num_match = widget_label(b,val=' ',/dynamic)
 
	;----  Results window  -----
	txt =  ['Enter one or more keywords in the Keywords area above.',$
		'Press Enter or click the Search button.',$
		' ',$
		'Routines with one line descriptions containing all the',$
		'keywords will be listed in this area. Click on a ', $
		'routine name to display its built-in help text',$
		'(if none the entire routine will be displayed).', $
		' ',$
	 	'The listed IDL libraries each have a one line description',$
		'file (alph.one).  Libraries may be selected or unselected',$
		'to restrict the search.']
	id_results = widget_text(top,xsize=90,ysize=15, /scroll,$
	  /all_events,uval='RESULTS',val=txt)
 
 
	;----  Set up needed info and activate widget  -----------
	p_results = ptr_new()		; Pointer to results.
	s = {n:n, sel_id:sel_id, state:state, id_results:id_results, $
	  srch:srch, base:base, lib:lib, id_key:id_key, $
	  p_results:p_results, n_results:0, id_num_match:id_num_match}
	widget_control, top, /real, set_uval=s
	widget_control, id_key, /input_focus
 
	xmanager, 'xliner', top, /no_block
 
	end
