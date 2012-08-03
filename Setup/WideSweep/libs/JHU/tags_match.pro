;-------------------------------------------------------------
;+
; NAME:
;       TAGS_MATCH
; PURPOSE:
;       Find matching tags in two structures.
; CATEGORY:
; CALLING SEQUENCE:
;       tags_match, s1, s2, list
; INPUTS:
;       s1, s2 = two structures to compare.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /QUIET do not list matches.
; OUTPUTS:
;       list = list of matching tags.        out
; COMMON BLOCKS:
; NOTES:
;       Note: case is ignored.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Nov 21
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro tags_match, s1, s2, list, quiet=quiet, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find matching tags in two structures.'
	  print,' tags_match, s1, s2, list'
	  print,'   s1, s2 = two structures to compare.  in'
	  print,'   list = list of matching tags.        out'
	  print,' Keywords:'
	  print,'   /QUIET do not list matches.'
	  print,' Note: case is ignored.'
	  return
	endif
 
	tags1 = strupcase(tag_names(s1))
	n1 = n_elements(tags1)
	tags2 = strupcase(tag_names(s2))
	n2 = n_elements(tags2)
 
	list = ['']
 
	for i=0,n1-1 do begin
	  tg = tags1(i)
	  w = where(tg eq tags2,cnt)
	  if cnt gt 0 then begin
	    list = [list,tg]
	    if not keyword_set(quiet) then print,tg
	  endif
	endfor
 
	if n_elements(list) gt 1 then begin
	  list = list(1:*)
	endif else begin
	  list = ''
	endelse
 
	end
