;-------------------------------------------------------------
;+
; NAME:
;       LASTINDEX
; PURPOSE:
;       Returns last index for each dimension of the given array.
; CATEGORY:
; CALLING SEQUENCE:
;       lastindex, array, l1, l2, ... l8
; INPUTS:
;       array = given array.                          in
; KEYWORD PARAMETERS:
;       Keywords:
;         /SIZE means return size of each dimension.
;               Else return last index of each dimension.
; OUTPUTS:
;       l1, l2, ... = last index for each dimension.  out
;         Max of 8 dimensions.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 5 Jan, 1990
;       R. Sterner, 18 Mar, 1990 --- removed execute (recursion problem).
;       R. Sterner, 2005 Apr 19 --- Corrected to match name.  Keyword
;       /SIZE added for some backward compatability.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro lastindex, a, l1, l2, l3, l4, l5, l6, l7, l8, size=num, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Returns last index for each dimension of the given array.'
	  print,' lastindex, array, l1, l2, ... l8'
	  print,'   array = given array.                          in'
	  print,'   l1, l2, ... = last index for each dimension.  out'
	  print,'     Max of 8 dimensions.'
	  print,' Keywords:'
	  print,'   /SIZE means return size of each dimension.'
	  print,'         Else return last index of each dimension.'
	  return
	endif
 
	sz = size(a)
 
	n = sz(0)
 
	if not keyword_set(num) then sz=sz-1
 
	if n ge 1 then l1 = sz(1)
	if n ge 2 then l2 = sz(2)
	if n ge 3 then l3 = sz(3)
	if n ge 4 then l4 = sz(4)
	if n ge 5 then l5 = sz(5)
	if n ge 6 then l6 = sz(6)
	if n ge 7 then l7 = sz(7)
	if n ge 8 then l8 = sz(8)
 
	return
	end
