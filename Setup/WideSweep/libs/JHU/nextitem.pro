;-------------------------------------------------------------
;+
; NAME:
;       NEXTITEM
; PURPOSE:
;       Return next line from a file, ignore comments & null lines.
; CATEGORY:
; CALLING SEQUENCE:
;       itm = nextitem(lun, [txt])
; INPUTS:
;       lun = unit number of opened text file.     in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       txt = optionally returned complete line.   out
;       itm = first word in text line.             out
; COMMON BLOCKS:
; NOTES:
;       Note: Useful to read control files.  First item on each
;         line is returned. Items may be delimited by spaces,
;         commas, or tabs.  Null lines and comments are ignored.
;         Comment lines have * as the first character in the line.
;         If a line contains only a single space it is considered
;         a null line. The entire text line may optionally be
;         returned.  It has commas and tabs converted spaces,
;         ready for GETWRD.  On EOF a null string is returned.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 19 June, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES  5 Nov, 1985 --- returned TXT.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function nextitem,lun,txt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return next line from a file, ignore comments & null lines.'
	  print,' itm = nextitem(lun, [txt])'
	  print,'   lun = unit number of opened text file.     in'
	  print,'   txt = optionally returned complete line.   out'
	  print,'   itm = first word in text line.             out'
	  print,' Note: Useful to read control files.  First item on each'
	  print,'   line is returned. Items may be delimited by spaces,'
	  print,'   commas, or tabs.  Null lines and comments are ignored.'
	  print,'   Comment lines have * as the first character in the line.'
	  print,'   If a line contains only a single space it is considered'
	  print,'   a null line. The entire text line may optionally be'
	  print,'   returned.  It has commas and tabs converted spaces,'
	  print,'   ready for GETWRD.  On EOF a null string is returned.'
	  return, -1
	endif
 
	txt = ''
loop:	if eof(lun) then goto, endfile
	readf,lun,txt
	if txt eq "" then goto, loop
	if txt eq " " then goto, loop
	if strsub(txt,0,0) eq '*' then goto, loop
	txt = stress(txt,'r',0,',',' ')			; Replace commas.
	txt = stress(txt,'r',0,'	',' ')		; Replace tabs.
	return, getwrd(txt,0)
 
endfile:
	return, ""
 
	end
