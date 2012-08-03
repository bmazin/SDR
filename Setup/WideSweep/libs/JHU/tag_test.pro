;-------------------------------------------------------------
;+
; NAME:
;       TAG_TEST
; PURPOSE:
;       Test if given tag is in given structure.
; CATEGORY:
; CALLING SEQUENCE:
;       flag = tag_test(ss, tag)
; INPUTS:
;       ss = given structure.       in
;       tag = given tag.            in
; KEYWORD PARAMETERS:
;       Keywords:
;         MINLEN=mn Minimum tag length to match (def=exact match).
;           SS may have the tag abbreviated down to mn characters.
;           (But tag must be at least as long as appears in ss).
;         INDEX=ind Index of first match (-1 means none).
; OUTPUTS:
;       flag = test result:         out
;          0=tag not found, 1=tag found.
; COMMON BLOCKS:
; NOTES:
;       Note: useful for testing if tag occurs. Example:
;         if tag_test(ss,'cmd') then call_procedure,ss.cmd
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Jun 30
;       R. Sterner, 2005 Jan 19 --- Added INDEX=ind.
;       R. Sterner, 2006 Sep 27 --- Added MINLEN.
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function tag_test, ss, tag, index=ind, minlen=mn, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Test if given tag is in given structure.'
	  print,' flag = tag_test(ss, tag)'
	  print,'   ss = given structure.       in'
	  print,'   tag = given tag.            in'
	  print,'   flag = test result:         out'
	  print,'      0=tag not found, 1=tag found.'
	  print,' Keywords:'
	  print,'   MINLEN=mn Minimum tag length to match (def=exact match).'
	  print,'     SS may have the tag abbreviated down to mn characters.'
	  print,'     (But tag must be at least as long as appears in ss).'
	  print,'   INDEX=ind Index of first match (-1 means none).'
	  print,' Note: useful for testing if tag occurs. Example:'
	  print,"   if tag_test(ss,'cmd') then call_procedure,ss.cmd"
	  return,''
	endif
 
	;----------------------------------------
	;  Initialize
	;----------------------------------------
	if n_elements(ss) eq 0 then return,''	; Do nothing.
	tagup = strupcase(tag)			; Uppercase copy of tag.
	tnames = tag_names(ss)			; Get structure tags (UCase).
	len = strlen(tagup)			; # characters in given tag.
	if n_elements(mn) eq 0 then mn=len	; Min matching size allowed.
	mn = mn<len				; Match at least len.
 
 	;----------------------------------------
	;  Loop over allowed match lengths
	;----------------------------------------
	for i=len, mn, -1 do begin		; Test tag chars: all,all-1,...
	  tst = strmid(tagup,0,i)		; Pick off first i chars.
	  w = where(tst eq tnames, cnt)		; Is it in structure?
	  if cnt eq 1 then break		; Yes, exactly once.
	endfor ; i
 
	;----------------------------------------
	;  Tag not found, return 0
	;----------------------------------------
	if cnt eq 0 then begin
	  ind = -1
	  return, 0
	endif
 
	;----------------------------------------
	;  Tag appears in structure, return 1 
	;----------------------------------------
	ind = w(0)
	return, 1
 
	end
