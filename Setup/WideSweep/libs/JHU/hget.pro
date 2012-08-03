;-------------------------------------------------------------
;+
; NAME:
;       HGET
; PURPOSE:
;       Get a handle value.
; CATEGORY:
; CALLING SEQUENCE:
;       v = hget(h)
; INPUTS:
;       h = handle ID.              in
;       v = Returned handle value.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NO_COPY if given copies contents the handle to v
;           and sets h to undefined.  Useful for large items
;           if h is not needed after hget.  For very large items
;           it may be better to use handle_value directly.
;         ERROR=err  Error flag: 0=ok, 1=invalid handle.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: this routine is often more convenient to use since
;         it is a function so may be called within expressions.
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
	function hget, h, no_copy=no_copy, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get a handle value.'
	  print,' v = hget(h)'
	  print,'   h = handle ID.              in'
	  print,'   v = Returned handle value.  in'
	  print,' Keywords:'
	  print,'   /NO_COPY if given copies contents the handle to v'
	  print,'     and sets h to undefined.  Useful for large items'
	  print,'     if h is not needed after hget.  For very large items'
	  print,'     it may be better to use handle_value directly.'
	  print,'   ERROR=err  Error flag: 0=ok, 1=invalid handle.'
	  print,' Notes: this routine is often more convenient to use since'
	  print,'   it is a function so may be called within expressions.'
	  return,''
	endif
 
	no_copy = n_elements(no_copy)			; Force defined.
 
	if n_elements(h) eq 0 then h=0			; Force defined.
	if not handle_info(h) then begin		; Is handle valid?
	  print,' Error in hget: given handle is not valid.'
	  err = 1
	  return,''
	endif
	
	handle_value, h, v, no_copy=no_copy		; Get handle value.
	err = 0
 
	return, v
	end
