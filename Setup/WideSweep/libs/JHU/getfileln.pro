;-------------------------------------------------------------
;+
; NAME:
;       GETFILELN
; PURPOSE:
;       Get a line from a text file.
; CATEGORY:
; CALLING SEQUENCE:
;       txt = getfileln(file)
; INPUTS:
;       file = text file name.               in
; KEYWORD PARAMETERS:
;       Keywords:
;         LINE=L  file line number to return.  First = 1.
;         KEY=K   Keyword to search for.  First line in
;           which keyword K is found is returned as txt.
;           File is searched up to line L (def=1000).
;         START=S line to start keyword search.
;         FOUND=F line in which keyword was found.
;         ERROR=e error flag.  0=ok, 1=file not opened,
;           2=LINE out of range, 3=KEY not found.
; OUTPUTS:
;       txt = returned text string.          out
; COMMON BLOCKS:
; NOTES:
;       Notes: If LINE or KEY not specified the first line
;         is returned.  If both LINE and KEY are specified
;         then the search for KEY is limited to LINE lines.
;         If LINE is out of range or KEY is not found then
;         a null string is returned.
; MODIFICATION HISTORY:
;       R. Sterner, 9 Mar, 1990
;       R. Sterner, 26 Feb, 1991 --- Renamed from getfileline.pro
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function getfileln, file, line=l, key=k, help=hlp,$
	  start=st, found=fnd, error=err
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get a line from a text file.'
	  print,' txt = getfileln(file)'
	  print,'   file = text file name.               in'
	  print,'   txt = returned text string.          out'
	  print,' Keywords:'
	  print,'   LINE=L  file line number to return.  First = 1.'
	  print,'   KEY=K   Keyword to search for.  First line in'
	  print,'     which keyword K is found is returned as txt.'
	  print,'     File is searched up to line L (def=1000).'
	  print,'   START=S line to start keyword search.'
	  print,'   FOUND=F line in which keyword was found.'
	  print,'   ERROR=e error flag.  0=ok, 1=file not opened,'
	  print,'     2=LINE out of range, 3=KEY not found.'
	  print,' Notes: If LINE or KEY not specified the first line'
	  print,'   is returned.  If both LINE and KEY are specified'
	  print,'   then the search for KEY is limited to LINE lines.'
	  print,'   If LINE is out of range or KEY is not found then'
	  print,'   a null string is returned.'
	  return, -1
	endif
 
	if n_elements(k) ne 0 then k2 = strupcase(k)
	if n_elements(st) eq 0 then st = 1
	get_lun, lun
	on_ioerror, err1
	openr, lun, file
	on_ioerror, err2
	txt = ''
	
	;---------  No keywords set, return first line  ------------
	if (n_elements(l) eq 0) and (n_elements(k) eq 0) then begin
	  readf, lun, txt
	  goto, done
	endif
 
	;----------  KEY set  --------------------------
	if n_elements(k) ne 0 then begin
	  ;--- Limit search to 1000 lines by default. ---
	  if n_elements(l) eq 0 then l = 1000
	  ;--- Start at line st, so skip st-1 lines. ---
	  if st gt 1 then for i = 1, st-1 do readf, lun, txt
	  ;--- Read up to line l. ---
	  for fnd = st, l do begin
	    readf, lun, txt
	    ;--- Key word found? ---
	    if strpos(strupcase(txt),k2) ge 0 then goto, done
	  endfor
	  err = 3					; Keyword not found.
	  txt = ''
	  goto, done2
	endif
 
	;---------  LINE set  --------------------------
	for i = 1, l do readf, lun, txt			; Read to line L.
	
done:	err=0
done2:	close, lun
	free_lun, lun
	return, txt
 
err1:	free_lun, lun
	err = 1
	print,' Error: file '+file+' not opened.'
	return, ''
 
err2:	close, lun
	free_lun, lun
	err = 2
	print,' Error: EOF on file '+file
	return, ''
 
	end
