;-------------------------------------------------------------
;+
; NAME:
;       UNIQ_TAGVAL
; PURPOSE:
;       Reduce given tag and value lists to unique tags only.
; CATEGORY:
; CALLING SEQUENCE:
;       uniq_tagval, tag, val, tag2, val2
; INPUTS:
;       tag = Text array of tag names.   in
;       val = Array of tag values.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         /FIRST means use the first value found for each tag
;           as the returned value.
;         /LAST means use the last value found for each tag
;           as the returned value.  This is the default.
;         INDEX=in Indices of the unique elements selected from tag.
;         COUNT=n  Number of elements in returned arrays.
;         USED=uin Array giving the index of the element actually
;           used for each element in the original tag array.
; OUTPUTS:
;       tag2 = Unique tag names.         out
;       val2 = Corresponding tag values. out
; COMMON BLOCKS:
; NOTES:
;       Note: May also call with just tag, tag2:
;         uniq_tagval, tag, tag2
;       if val is not needed.  Keywords work the same.
;       The tag array may have a tag repeated multiple times.
;       The array val must be the same size, it can be any type.
;       The returned array tag2 will have only the unique tags in
;       the order first found in tag, val2 will have the
;       corresponding values.  For example:
;         Inputs    With /FIRST   With /LAST
;         tag val   tag2  val2    tag2  val2
;         --- ---   ----  ----    ----  ----
;          a  0.58   a    0.58    a    0.31
;          b  0.42   b    0.42    b    0.31
;          e  0.88   e    0.88    e    0.06
;          f  0.47   f    0.47    f    0.47
;          c  0.84   c    0.84    c    0.79
;          b  0.01   d    0.27    d    0.27
;          a  0.17
;          d  0.27
;          e  0.27
;          b  0.49
;          c  0.79
;          a  0.31
;          b  0.31
;          e  0.06
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Dec 19
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro uniq_tagval, tag, val, tag2, val2, $
	  index=in, count=n2, first=first, last=last, $
	  used=used, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Reduce given tag and value lists to unique tags only.'
	  print,' uniq_tagval, tag, val, tag2, val2'
	  print,'   tag = Text array of tag names.   in'
	  print,'   val = Array of tag values.       in'
	  print,'   tag2 = Unique tag names.         out'
	  print,'   val2 = Corresponding tag values. out'
	  print,' Keywords:'
	  print,'   /FIRST means use the first value found for each tag'
	  print,'     as the returned value.'
	  print,'   /LAST means use the last value found for each tag'
	  print,'     as the returned value.  This is the default.'
	  print,'   INDEX=in Indices of the unique elements selected from tag.'
	  print,'   COUNT=n  Number of elements in returned arrays.'
	  print,'   USED=uin Array giving the index of the element actually'
	  print,'     used for each element in the original tag array.'
	  print,' Note: May also call with just tag, tag2:'
	  print,'   uniq_tagval, tag, tag2'
	  print,' if val is not needed.  Keywords work the same.'
	  print,' The tag array may have a tag repeated multiple times.'
	  print,' The array val must be the same size, it can be any type.'
	  print,' The returned array tag2 will have only the unique tags in'
	  print,' the order first found in tag, val2 will have the'
	  print,' corresponding values.  For example:'
	  print,'   Inputs    With /FIRST   With /LAST'
	  print,'   tag val   tag2  val2    tag2  val2'
	  print,'   --- ---   ----  ----    ----  ----'
	  print,'    a  0.58   a    0.58    a    0.31'
	  print,'    b  0.42   b    0.42    b    0.31'
	  print,'    e  0.88   e    0.88    e    0.06'
	  print,'    f  0.47   f    0.47    f    0.47'
	  print,'    c  0.84   c    0.84    c    0.79'
	  print,'    b  0.01   d    0.27    d    0.27'
	  print,'    a  0.17'
	  print,'    d  0.27'
	  print,'    e  0.27'
	  print,'    b  0.49'
	  print,'    c  0.79'
	  print,'    a  0.31'
	  print,'    b  0.31'
	  print,'    e  0.06'
	  return
	endif
 
	if keyword_set(first) then no_up=1 else no_up=0
 
	n = n_elements(tag)		; Size of arrays.
	v = sindgen(n)			; Indices of arrays as strings.
	for i=0,n-1 do $  		; Add to an associative array.
	  aa=aarr(aa,tag[i],val=v[i], /add,no_up=no_up)
 
	n2 = n_elements(aa)/2
	in = 0L + aa[1+2*indgen(n2)]    ; Indices of elements used.
	tag2 = tag[in]			; Unique tags.
 
	if arg_present(used) then begin	; Index used for each original element.
	  used = lonarr(n)
	  for i=0,n-1 do begin
	    w = where(tag eq tag[i])
	    if no_up then j=min(w) else j=max(w)
	    used[i] = j
	  endfor
	endif
 
	if n_params(0) eq 2 then begin	; Called with just tag, tag2.
	  val = tag[in]			; Extract unique tags
	  return			; and return.
	endif
 
	val2 = val[in]			; Also extract corresponding values.
 
	end
