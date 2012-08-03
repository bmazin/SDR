;-------------------------------------------------------------
;+
; NAME:
;       SUBSTRUCT
; PURPOSE:
;       Return a substructure from a structure by indices.
; CATEGORY:
; CALLING SEQUENCE:
;       s2 = substruct(s,in)
; INPUTS:
;       s = Input structure.           in
;       in = Indices to extract.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         /QUIET do not give error message.
; OUTPUTS:
;       s2 = resulting sub-structure.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: To list the tag names in a structure and their
;       indices do: more,/num,tag_names(s)
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Aug 18
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function substruct, s, in, help=hlp, quiet=quiet
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return a substructure from a structure by indices.'
	  print,' s2 = substruct(s,in)'
	  print,'   s = Input structure.           in'
	  print,'   in = Indices to extract.       in'
	  print,'   s2 = resulting sub-structure.  out'
	  print,' Keywords:'
	  print,'   /QUIET do not give error message.'
	  print,' Notes: To list the tag names in a structure and their'
	  print,' indices do: more,/num,tag_names(s)'
	  return,''
	endif
 
	n = n_elements(in)
	tags = tag_names(s)
	nt = n_elements(tags)
 
	s2 = create_struct(tags(in(0)),s.(in(0)))
 
	for i=1, n-1 do begin
	  j = in(i)
	  if j lt nt then begin
	    s2 = create_struct(s2,tags(j),s.(j))
	  endif else begin
	    if not keyword_set(quiet) then $
	      print,' Index out of range, ignored: ',j
	  endelse
	endfor
 
	return, s2
 
	end
