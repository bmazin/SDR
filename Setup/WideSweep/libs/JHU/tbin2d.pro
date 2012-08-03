;-------------------------------------------------------------
;+
; NAME:
;       TBIN2D
; PURPOSE:
;       Total 2-D binned values.
; CATEGORY:
; CALLING SEQUENCE:
;       out = tbin2d(arr,ix,iy,val)
; INPUTS:
;       arr = 2-D array to sum curve into.  in
;       ix = array of X indices of curve.   in
;       iy = array of Y indices of curve.   in
;       val = values along curve.           in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = Array with curve summed in.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: The curve must be inside the array.
;         ix,iy must be integer indices inside arr.
;         This is lke a weighted 2-D histogram, where
;         the values are the weights.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jul 23
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function tbin2d, arr, ix, iy, val, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Total 2-D binned values.'
	  print,' out = tbin2d(arr,ix,iy,val)'
	  print,'   arr = 2-D array to sum curve into.  in'
	  print,'   ix = array of X indices of curve.   in'
	  print,'   iy = array of Y indices of curve.   in'
	  print,'   val = values along curve.           in'
	  print,'   out = Array with curve summed in.   out'
	  print,' Notes: The curve must be inside the array.'
	  print,'   ix,iy must be integer indices inside arr.'
	  print,'   This is lke a weighted 2-D histogram, where'
	  print,'   the values are the weights.'
	  return,''
	endif
 
	;--------------------------------------
	;  Convert 2-D indices to 1-D indices
	;  so histogram function can be used.
	;--------------------------------------
	two2one, ix, iy, arr, in	; Convert to 1-d indices.
	n = n_elements(arr)		; # elements in arr.
	h = histogram(in, rev=r, $	; Histogram indices and get rev_ind.
	              min=0, max=n-1)	; Same # elements as arr.
 
	;--------------------------------------
	;  Accumulator.
	;  Set up as 2-d but access as 1-d
	;  below. Just add to arr to add in
	;  the curve ix,iy,val.
	;--------------------------------------
	t = arr*0.			; Accumulator (2-d).
 
	;--------------------------------------
	;  Find only non-zero histogram bins.
	;--------------------------------------
	ii = lindgen(n)			; Indices into h.
	lo = r(ii)			; Reverse indices start for ii.
	hi = r(ii+1)			; Reverse indices end for ii.
	w = where(hi gt lo, cnt)	; Want non-zero h bins.
 
	;--------------------------------------
	;  Sum values for non-zero bins.
	;--------------------------------------
	for i=0, cnt-1 do begin		; Loop through non-zero h bins.
	  j = ii(w(i))			; Bin number.
	  t(j) = total(val(r(lo(j):hi(j)-1)))  ; Total in bin.
	endfor
 
	return, arr+t			; Sum into arr.
 
	end
