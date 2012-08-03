;-------------------------------------------------------------
;+
; NAME:
;       TEXT_BLOCK
; PURPOSE:
;       Print or return a block of inline text (lines starts with ;).
; CATEGORY:
; CALLING SEQUENCE:
;       text_block, out
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /WIDGET   Display text in a text widget.
;         /WAIT     With /WIDGET, wait until exit button is pressed.
;         /QUIET    Do not print text.
; OUTPUTS:
;       out = returned text block.       out
; COMMON BLOCKS:
; NOTES:
;       Notes: Block of text must directly follow text_block.
;       Examples:
;           text_block
;         ; This is a test.
;       
;       text_block
;       ; Line 1
;       ; Line 2
;       ; Line 3
;        
;        <> The semicolon comment character must be in column 1.
;        <> The first character is dropped (semicolon is not printed).
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Mar 3
;       R. Sterner, 2006 May 03 --- Allowed longer lines.
;       R. Sterner, 2007 Sep 04 --- Added /WIDGET.
;       R. Sterner, 2007 Sep 11 --- Added /WAIT
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro text_block, out, quiet=quiet, widget=widget, $
	  wait=wait, help=hlp
 
	if keyword_set(hlp) then begin
help:	  print,' Print or return a block of inline text (lines starts with ;).'
	  print,' text_block, out'
	  print,'   out = returned text block.       out'
	  print,' Keywords:'
	  print,'   /WIDGET   Display text in a text widget.'
	  print,'   /WAIT     With /WIDGET, wait until exit button is pressed.'
	  print,'   /QUIET    Do not print text.'
	  print,' Notes: Block of text must directly follow text_block.'
	  print,' Examples:'
	  print,'     text_block'
	  print,'   ; This is a test.'
	  print,' '
	  print,' text_block'
	  print,'; Line 1'
	  print,'; Line 2'
	  print,'; Line 3'
	  print,' '
	  print,' <> The semicolon comment character must be in column 1.'
	  print,' <> The first character is dropped (semicolon is not printed).'
	  return
	end
 
	whocalledme, dir, file, line=n		; Find who called data_block.
	if file eq '' then goto, help
	name = filename(dir,file,/nosym)
	txt = getfile(name)			; Read in calling routine.
	last = n_elements(txt)-1		; Last line in routine.
 
	out = strarr((last-n)>1)		; Set up max possible space.
 
	;-----  Search until no more comment lines  --------
	for i=n, last do begin
	  if strmid(txt(i),0,1) ne ';' then goto, done	; Not a comment?
	  out(i-n) = strmid(txt(i),1,999)		; It was, grab it.
	endfor
 
done:	out = out(0:i-n-1)			; Keep only filled lines.
 
	if keyword_set(widget) then begin
	  xhelp, out, exit_text='OK', /bottom, wait=wait
	  return
	endif
 
	if not keyword_set(quiet) then $	; Print if not /quiet.
	  for i=0,n_elements(out)-1 do print,out(i)
 
	end
