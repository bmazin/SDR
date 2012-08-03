;-------------------------------------------------------------
;+
; NAME:
;       DIMSZ
; PURPOSE:
;       Return size of requested array dimension.
; CATEGORY:
; CALLING SEQUENCE:
;       n = dimsz(arr,dim)
; INPUTS:
;       arr = Array                         in
;       dim = Which dimension (1,2,3,...).  in
;         If dim is 0 return number of dimensions.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       n = returned size of dimension dim. out
;           0 if that dimension does not exist.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jul 27
;       R. Sterner, 2004 Sep 14 --- Made dim of 0 return number of dimensions.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function dimsz, arr, dim, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return size of requested array dimension.'
	  print,' n = dimsz(arr,dim)'
	  print,'   arr = Array                         in'
	  print,'   dim = Which dimension (1,2,3,...).  in'
	  print,'     If dim is 0 return number of dimensions.'
	  print,'   n = returned size of dimension dim. out'
	  print,'       0 if that dimension does not exist.'
	  return,''
	endif
 
	sz = size(arr)
	if dim gt sz(0) then return, 0
	if dim lt 1 then return, sz(0)
	return, sz(dim)
 
	end
