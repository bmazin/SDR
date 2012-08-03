;-------------------------------------------------------------
;+
; NAME:
;       TXTDB_IN
; PURPOSE:
;       Index into a structure returned by txtdb_rd.
; CATEGORY:
; CALLING SEQUENCE:
;       si = txtdb_in(s, i)
; INPUTS:
;       s = Input structure.  Must be from txtdb_rd.  in
;       in = Index to return.                         in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       si = Returned structure.                      out
; COMMON BLOCKS:
; NOTES:
;       Note: si has scalar tags that are element i of
;       each array in s except for the __textxxx arrays
;       which are not returned.  This returns all the values
;       in si for the i'th element in structure s.  Structure
;       s has the values in arrays.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Aug 29
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function txtdb_in, s, in, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Index into a structure returned by txtdb_rd.'
	  print,'  si = txtdb_in(s, i)'
	  print,'    s = Input structure.  Must be from txtdb_rd.  in'
	  print,'    in = Index to return.                         in'
	  print,'    si = Returned structure.                      out'
	  print,' Note: si has scalar tags that are element i of'
	  print,' each array in s except for the __textxxx arrays'
	  print,' which are not returned.  This returns all the values'
	  print," in si for the i'th element in structure s.  Structure"
	  print,' s has the values in arrays.'
	  return,''
	endif
 
	n = n_tags(s)		; # tags in s.
	tags = tag_names(s)	; Names of tags in s.
 
	for i=0,n-1 do begin
	  if strmid(tags(i),0,2) eq '__' then continue	; Ignore __textxxx.
	  if n_elements(si) eq 0 then begin
	    si = create_struct(tags(i),s.(i)(in))
	  endif else begin
	    si = create_struct(si, tags(i),s.(i)(in))
	  endelse
	endfor
 
	return, si
 
	end
