;-------------------------------------------------------------
;+
; NAME:
;       TXTPICK
; PURPOSE:
;       Select file(s) from a screen menu displaying a file list.
; CATEGORY:
; CALLING SEQUENCE:
;       txtmenu_pick, list, file
; INPUTS:
;       list = list of files (complete path).      in
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE_TEXT=ttxt title text (def=Select file).
;         ABORT_TEXT=qtxt quit text (def=Abort file selection).
;         /MULTIPLE means allow multiple file selections.
;         If /MULTIPLE is in effect then there are two exits:
;         ACCEPT_TEXT=actxt quit text (def=Accept selected files).
;         ABORT_TEXT=abtxt quit text (def=Abort file selection).
; OUTPUTS:
;       file = selected file(s) (none means none). out
; COMMON BLOCKS:
;       txtmenu_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 13 Feb, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro txtpick, list, outfile, title_text=tttxt, abort_text=abtxt, $
	  actxt=actxt, selection=sel, help=hlp, multiple=mult
 
	common txtmenu_com, initflag, x, y, tag, val, uval, sep, $
	  item_len, n_items, hilight, screen
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Select file(s) from a screen menu displaying a file list.'
	  print,' txtmenu_pick, list, file'
	  print,'   list = list of files (complete path).      in'
	  print,'   file = selected file(s) (none means none). out'
	  print,' Keywords:'
	  print,'   TITLE_TEXT=ttxt title text (def=Select file).'
	  print,'   ABORT_TEXT=qtxt quit text (def=Abort file selection).'
	  print,'   /MULTIPLE means allow multiple file selections.'
	  print,'   If /MULTIPLE is in effect then there are two exits:'
	  print,'   ACCEPT_TEXT=actxt quit text (def=Accept selected files).'
	  print,'   ABORT_TEXT=abtxt quit text (def=Abort file selection).'
	  print,'   SELECTION=sel set initial selection number and'
	  print,'     return final selection number.'
	  return
	endif
 
 
	n_files = n_elements(list)		; # files.
	;----  Get directory from first (assume same for all)  ----
	filebreak, list(0), dir=dir
	if dir ne '' then dir = ' from directory '+dir
	;----  Make a list of file names only  --------
	files = list
	for i = 0, n_files-1 do begin
	  filebreak, list(i), nvfile=txt
	  files(i)=txt
	endfor
 
	;--------  Set defaults  ------------
	if keyword_set(mult) then begin
	  if n_elements(tttxt) eq 0 then tttxt = 'Select files'
	  if n_elements(actxt) eq 0 then actxt = 'Accept selected files'
	  if n_elements(abtxt) eq 0 then abtxt = 'Abort file selection'
	  tmen = ['|3|2|'+tttxt+dir+'||',$
	    '|3|3|'+actxt+'| |',$
	    '|40|3|'+abtxt+'| |']
	  off = 1		; List offset.
	endif else begin
	  if n_elements(tttxt) eq 0 then tttxt = 'Select file'
	  if n_elements(abtxt) eq 0 then abtxt = 'Abort file selection'
	  tmen = ['|3|2|'+tttxt+dir+'||',$
	    '|3|3|'+abtxt+'| |']
	  off = 0		; List offset
	endelse
 
	;------  Set up file selection menu (56 files max) -------
	for i = 0, (n_files-1)<56 do begin
	  x = strtrim(3 + (i/19)*25, 2)
	  y = strtrim(4 + (i mod 19), 2)
	  tmen = [tmen, '|'+x+'|'+y+'|'+files(i)+'| |']
	endfor
	if n_files gt 57 then tmen = [tmen,$
	  '|5|23|WARNING: too many files,  partial list. Change wildcard.||']
 
	if n_elements(sel) eq 0 then sel = 2+off
	if sel gt (n_files+1)<56 then sel = (n_files+1)<56  ; set to last max.
	txtmenu, init=tmen
loop:	txtmenu, select=sel, multiple=mult
 
	;-------  Abort  ---------
	if sel eq (1+off) then begin
	  outfile = 'none'
	  return
	endif
 
	;---------  Accept  ------------
	hilight(sel) = 1-hilight(sel)	; Toggle High light selection.
	if keyword_set(mult) and (sel ne 1) then goto, loop
	w = where(hilight((2+off):*) eq 1)
	outfile = (['none',list])(w+1)
	if n_elements(outfile) eq 1 then outfile = outfile(0)
	return
	end
