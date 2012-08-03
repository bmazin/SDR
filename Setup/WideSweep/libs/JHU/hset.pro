;-------------------------------------------------------------
;+
; NAME:
;       HSET
; PURPOSE:
;       Set a handle value.
; CATEGORY:
; CALLING SEQUENCE:
;       hset, h, v
; INPUTS:
;       v = value to store in handle.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NO_COPY if given copies contents of v to handle
;           and sets v to undefined.  Useful for large items
;           if v is not needed after hset.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: if h is not a valid handle then it is set to
;         a valid handle which is returned.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Jan 15
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro hset, h, v, no_copy=no_copy, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Set a handle value.'
	  print,' hset, h, v'
	  print,'   h = handle ID.                   in,out'
	  print,'   v = value to store in handle.    in'
	  print,' Keywords:'
	  print,'   /NO_COPY if given copies contents of v to handle'
	  print,'     and sets v to undefined.  Useful for large items'
	  print,'     if v is not needed after hset.'
	  print,' Notes: if h is not a valid handle then it is set to'
	  print,'   a valid handle which is returned.'
	  return
	endif
 
	no_copy = n_elements(no_copy)			; Force defined.
 
	if n_elements(h) eq 0 then h=0			; Force defined.
	if not handle_info(h) then h=handle_create()	; Create a handle.
	
	handle_value, h, v, /set, no_copy=no_copy	; Set handle value.
 
	return
	end
