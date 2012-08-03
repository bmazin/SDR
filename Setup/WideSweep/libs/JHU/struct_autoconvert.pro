;-------------------------------------------------------------
;+
; NAME:
;       STRUCT_AUTOCONVERT
; PURPOSE:
;       Convert a structure wih all string items to numeric.
; CATEGORY:
; CALLING SEQUENCE:
;       out = struct_autoconvert(in)
; INPUTS:
;       in = Structure with all string items.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = Converted structure with numeric  out
;         strings converted to numeric values.
; COMMON BLOCKS:
; NOTES:
;       Notes: Non-numeric items are kept as strings.
;       Integer items are returned as long ints.
;       Floating items are returned as double.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Sep 07
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function struct_autoconvert, in, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a structure wih all string items to numeric.'
	  print,' out = struct_autoconvert(in)'
	  print,'   in = Structure with all string items.   in'
	  print,'   out = Converted structure with numeric  out'
	  print,'     strings converted to numeric values.'
	  print,' Notes: Non-numeric items are kept as strings.'
	  print,' Integer items are returned as long ints.'
	  print,' Floating items are returned as double.'
	  return,''
	endif
 
	tags = tag_names(in)		; Tags in incoming strutcure.
	n = n_elements(tags)		; Number of tags.
	typ = bytarr(n)			; To hold data types.
	tbl = [7,3,5]			; Convert isnumber output to type.
 
	for i=0,n-1 do typ(i)=tbl(isnumber(in.(i)))	; Find data types.
 
	out = create_struct(tags(0), $			; Create output struct.
	  to_datatype(in.(0),typ(0)))
	for i=1,n-1 do out = create_struct(out, $
	  tags(i),to_datatype(in.(i),typ(i)))
 
	return, out
 
	end
