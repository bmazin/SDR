;-------------------------------------------------------------
;+
; NAME:
;       TAG_VALUE
; PURPOSE:
;       Return the value for a given structure tag.
; CATEGORY:
; CALLING SEQUENCE:
;       val = tag_value(ss, tag)
; INPUTS:
;       ss = given structure.     in
;       tag = given tag.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         MINLEN=mn Minimum tag length to match (def=exact match).
;           SS may have the tag abbreviated down to mn characters.
;           (But tag must be at least as long as appears in ss).
;         ERROR=err Error flag: 0=ok, else tag not found.
;           On error returned value is a null string.
; OUTPUTS:
;       val = returned value.     out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 05
;       R. Sterner, 2006 Sep 27 --- Added MINLEN.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function tag_value, ss, tag, error=err, minlen=mn, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return the value for a given structure tag.'
	  print,' val = tag_value(ss, tag)'
	  print,'   ss = given structure.     in'
	  print,'   tag = given tag.          in'
	  print,'   val = returned value.     out'
	  print,' Keywords:'
	  print,'   MINLEN=mn Minimum tag length to match (def=exact match).'
	  print,'     SS may have the tag abbreviated down to mn characters.'
	  print,'     (But tag must be at least as long as appears in ss).'
	  print,'   ERROR=err Error flag: 0=ok, else tag not found.'
	  print,'     On error returned value is a null string.'
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
	;  Tag not found, return null string
	;----------------------------------------
	if cnt eq 0 then begin
	  err = 1
	  return, ''
	endif
 
	;----------------------------------------
	;  Tag appears in structure, return value
	;----------------------------------------
	err = 0
	return, ss.(w(0))
 
	end
