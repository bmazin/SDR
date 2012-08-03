;-------------------------------------------------------------
;+
; NAME:
;       TAG_DROP
; PURPOSE:
;       Drop a specified tag in a given structure.
; CATEGORY:
; CALLING SEQUENCE:
;       ss2 = tag_drop(ss, tag)
; INPUTS:
;       ss = given structure.     in
;       tag = given tag.          in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ss2 = modified structure. out
; COMMON BLOCKS:
; NOTES:
;       Note: If given tag not found then the
;        original structure is returned.
;        If last tag is dropped a null string is returned.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 05
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function tag_drop, ss, tag, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Drop a specified tag in a given structure.'
	  print,' ss2 = tag_drop(ss, tag)'
	  print,'   ss = given structure.     in'
	  print,'   tag = given tag.          in'
	  print,'   ss2 = modified structure. out'
	  print,' Note: If given tag not found then the'
	  print,'  original structure is returned.'
	  print,'  If last tag is dropped a null string is returned.'
	  return,''
	endif
 
	;----  Ignore if not a structure  -------
	if datatype(ss) ne 'STC' then return, ss
 
	;----  Get structure tags and find specified tag  ----
	tags = tag_names(ss)
	w = where(tags ne strupcase(tag), cnt, ncomp=ncnt)
 
	;----  Tag not found, do nothing  -----
	if ncnt eq 0 then return, ss
 
	;----  Construct new structure  ----
	if cnt eq 0 then return,''	; Return null string if all dropped.
	ss2 = create_struct(tags(w(0)),ss.(w(0))) ; Copy first item.
	for i=1,cnt-1 do begin		; Copy any other items.
	  ss2 = create_struct(ss2, tags(w(i)), ss.(w(i)) )
	endfor
 
	return, ss2
 
	end
