;-------------------------------------------------------------
;+
; NAME:
;       DIRMEM
; PURPOSE:
;       Update a directory list for easy access.
; CATEGORY:
; CALLING SEQUENCE:
;       out_list = dirmem( entry)
; INPUTS:
;       entry = potential new list entry.                 in
;         Directory followed by an optional alias:
;         /users/images/lunar/gif  Moon GIFS
; KEYWORD PARAMETERS:
;       Keywords:
;         READ=rf  Initialization text file: one directory/alias
;           pair per line.  Comments allowed (start with * or ;).
;           Over-rides any given list.
;         WRITE=wf File to save updated list in.
;         LIST=lst Text array with dir/alias pairs.  In/out.
;         /ALIAS  Means use aliases for out_list (display list).
;           Default is use directories.  ALIAS=2 means use both.
;        MAX_ENTRIES=m  Max size of list.  Def=size of init file
;          or 5 if that is not available.
; OUTPUTS:
;       out_list = Display list.                          out
;         Directories, aliases, or both.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Feb 14
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function dirmem, entry, read=rfile, write=wfile, list=list, $
	  alias=alias, max_entries=mx, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Update a directory list for easy access.'
	  print,' out_list = dirmem( entry)'
	  print,'   entry = potential new list entry.                 in'
	  print,'     Directory followed by an optional alias:'
	  print,'     /users/images/lunar/gif  Moon GIFS'
	  print,'   out_list = Display list.                          out'
	  print,'     Directories, aliases, or both.'
	  print,' Keywords:'
	  print,'   READ=rf  Initialization text file: one directory/alias'
	  print,'     pair per line.  Comments allowed (start with * or ;).'
	  print,'     Over-rides any given list.'
	  print,'   WRITE=wf File to save updated list in.'
	  print,'   LIST=lst Text array with dir/alias pairs.  In/out.'
	  print,'   /ALIAS  Means use aliases for out_list (display list).'
	  print,'     Default is use directories.  ALIAS=2 means use both.'
	  print,'  MAX_ENTRIES=m  Max size of list.  Def=size of init file'
	  print,'    or 5 if that is not available.'
	  return,''
	endif
 
	;--------  Init file  -------------
	if n_elements(rfile) ne 0 then begin
	  txt = getfile(rfile,/quiet,error=err)
	  if err eq 0 then list = drop_comments(txt)
	endif
 
	;--------  Default list  ----------
	if n_elements(list) eq 0 then begin
	  cd, curr=c
	  list = [c+' Entry directory']
	endif
 
	;---------  Process entry  ----------
	if n_elements(entry) eq 0 then entry = ' '
	dir = getwrd(entry,0)		; New entry directory.
	ali = getwrd(entry,1,9)		; New entry alias.
 
	;------ Extract directory and alias list  ---------
	dlist = list
	for i=0,n_elements(dlist)-1 do dlist(i) = getwrd(dlist(i),0)
 
	;------  Check for new directory in list  --------
	ind0 = indgen(n_elements(dlist))		; Indices of list.
	ind = -1					; Indices to keep.
	if n_elements(dlist) gt 1 then begin		; Handle list.
	  wn = where(dir ne dlist(1:*), cnt)		; All but dir.
	  if cnt gt 0 then ind = wn+1			; Keep.
	endif
 
	;------  Update list  ---------------------------
	if n_elements(mx) eq 0 then mx=5	; Max list size.
	tmp = [list(0)]
	if entry ne ' ' then tmp = [tmp,entry]
	if ind(0) ne -1 then tmp = [tmp,list(ind)]
	list = tmp
	lst = (n_elements(list)-1)<(mx-1)
	list = list(0:lst)
	
	;-----  Make display list  ----------
	if n_elements(alias) eq 0 then alias = 0
	alias = alias>0<2
	case alias of
0:	begin
	  out = list
	  for i=0,n_elements(out)-1 do out(i) = getwrd(out(i))
	end
1:	begin
	  out = list
	  for i=0,n_elements(out)-1 do begin
	    tmp = getwrd(out(i),1,9)
	    if tmp eq '' then tmp = getwrd(out(i))
	    out(i) = tmp
	  endfor
	end
2:	out = list
	endcase
 
	;---------  Save file  ------------
	if n_elements(wfile) ne 0 then begin
	  t = '*  Saved '+systime()
	  putfile, wfile, [t,list]
	endif
 
	return, out
	end
