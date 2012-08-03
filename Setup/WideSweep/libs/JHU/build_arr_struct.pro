;-------------------------------------------------------------
;+
; NAME:
;       BUILD_ARR_STRUCT
; PURPOSE:
;       Build a structure from arrays of tags and values.
; CATEGORY:
; CALLING SEQUENCE:
;       s = build_arr_struct( tags, vals)
; INPUTS:
;       tags = string array with structure tag names.  in
;       vals = array with values.                      in
; KEYWORD PARAMETERS:
;       Keywords:
;         NAME=name Name if a named structure, else anonymous.
; OUTPUTS:
;       s = returned structure.                        out
; COMMON BLOCKS:
; NOTES:
;       Note: All structure values must be of the same type
;         since they are given using an array.  For the more
;         general case use the builtin create_struct function.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Mar 05
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function build_arr_struct, tags, vals, help=hlp, name=name
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Build a structure from arrays of tags and values.'
	  print,' s = build_arr_struct( tags, vals)'
	  print,'   tags = string array with structure tag names.  in'
	  print,'   vals = array with values.                      in'
	  print,'   s = returned structure.                        out'
	  print,' Keywords:'
	  print,'   NAME=name Name if a named structure, else anonymous.'
	  print,' Note: All structure values must be of the same type'
	  print,'   since they are given using an array.  For the more'
	  print,'   general case use the builtin create_struct function.'
	  return,''
	endif
 
	n = n_elements(tags)
	if n_elements(vals) ne n then begin
	  print,' Error in build_arr_struct: must give the same number'
	  print,'   of values as tags.'
	  return,''
	endif
 
	s = create_struct(tags(0), vals(0))
 
	if n eq 1 then goto, done
 
	for i=1,n-1 do s = create_struct(s, tags(i), vals(i))
 
done:   s = create_struct(s, name=name)
	return, s
 
	end
