;-------------------------------------------------------------
;+
; NAME:
;       TAG_ADD
; PURPOSE:
;       Add or update a tag in a structure.
; CATEGORY:
; CALLING SEQUENCE:
;       tag_add, ss, tag, val
; INPUTS:
;       ss = given structure.       in
;       tag = given tag.            in
;       val = Value for tag.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         MINLEN=mn Minimum tag length to match (def=exact match).
;           SS may have the tag abbreviated down to mn characters.
;           (But tag must be at least as long as appears in ss).
;         FLAG=flag 0=added, 1=updated.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: No change if ss does not contain the tag.
;       GIVEN TAG MUST BE AS BIG OR BIGGER than the tag to match
;       in ss or it will be considered a new tag and added.
;       Also data type must be compatible with the type to replace.
;       Giving a constant for an array tag will fill the array with
;       that constant.  Non-matching types may give errors.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Sep 27
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro tag_add, ss, tag, val, minlen=mn, flag=flag, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Add or update a tag in a structure.'
	  print,' tag_add, ss, tag, val'
	  print,'   ss = given structure.       in'
	  print,'   tag = given tag.            in'
	  print,'   val = Value for tag.        in'
	  print,' Keywords:'
	  print,'   MINLEN=mn Minimum tag length to match (def=exact match).'
	  print,'     SS may have the tag abbreviated down to mn characters.'
	  print,'     (But tag must be at least as long as appears in ss).'
	  print,'   FLAG=flag 0=added, 1=updated.'
	  print,' Notes: No change if ss does not contain the tag.'
	  print,' GIVEN TAG MUST BE AS BIG OR BIGGER than the tag to match'
	  print,' in ss or it will be considered a new tag and added.'
	  print,' Also data type must be compatible with the type to replace.'
	  print,' Giving a constant for an array tag will fill the array with'
	  print,' that constant.  Non-matching types may give errors.'
	  return
	endif
 
	;----------------------------------------
	;  Initialize
	;----------------------------------------
	if n_elements(ss) eq 0 then return	; Do nothing.
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
	;  Tag not found, add it
	;----------------------------------------
	if cnt eq 0 then begin
	  ss = create_struct(ss,tag,val)	; Add new tag and value.
	  flag = 0				; Added.
	  return
	endif
 
	;----------------------------------------
	;  Tag appears in structure, update
	;----------------------------------------
	ss.(w(0)) = val
	flag = 1				; Updated.
	return
 
	end
