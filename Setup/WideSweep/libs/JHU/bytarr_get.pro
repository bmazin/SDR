;-------------------------------------------------------------
;+
; NAME:
;       BYTARR_GET
; PURPOSE:
;       Extract a byte array from a byte buffer.
; CATEGORY:
; CALLING SEQUENCE:
;       bytarr_get, buf, out
; INPUTS:
;       buf = byte buffer to extract output from.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         INDEX=indx  Index of byte array to extract:
;           0=1st, 1=2nd, ...  Returned by bytarr_put
;           array was inserted.  Out of range indices return
;           a single 0 byte (no error).
;         The inverse routine, bytarr_put, is used to insert
;         arrays into the buffer.
;         You must handle converting from byte to correct
;         data type when extracting.
; OUTPUTS:
;       out = byte array extracted from buffer.    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 May 30
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro bytarr_get, b, out, index=indx,  help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Extract a byte array from a byte buffer.'
	  print,' bytarr_get, buf, out'
	  print,'   buf = byte buffer to extract output from.  in'
	  print,'   out = byte array extracted from buffer.    out'
	  print,' Keywords:'
	  print,'   INDEX=indx  Index of byte array to extract:'
	  print,'     0=1st, 1=2nd, ...  Returned by bytarr_put'
	  print,'     array was inserted.  Out of range indices return'
	  print,'     a single 0 byte (no error).'
	  print,'   The inverse routine, bytarr_put, is used to insert'
	  print,'   arrays into the buffer.'
	  print,'   You must handle converting from byte to correct'
	  print,'   data type when extracting.'
	  return
	endif
 
	if datatype(b) ne 'BYT' then begin
	  print,' Error in bytarr_get: input buffer must be a byte array.'
	  return
	endif
 
	if n_elements(indx) eq 0 then begin
	  print,' Error in bytarr_get: Must specify index of array to extract.'
          return
	endif
 
	;-----  If buffer invalid or index out of range return single 0  ----
	out = 0b
	if n_elements(b) lt 12 then return
	if indx lt 0 then return
 
	;------  Get pointers (see bytarr_put for details on buffer) ------
	;	Last entry in pointer table is always pointer
	;	to location to add next enrty.
	p = (long(b,0,1))(0)		; Offset to pointer table.
	c = (long(b,p,1))(0)		; Number of pointers in table.
	pt = long(b,p+4,c)		; Get pointer table.
 
	;-----  Check if beyond last entry  -------
	if indx gt (c-2) then return	; Beyond end of table.
 
	;-----  Find pointer and length  ----------
	a = pt(indx)			; Requested byte array start address.
	len = pt(indx+1)-a		; Length.
 
	out = b(a:a+len-1)		; Return array.
 
	return
	end
