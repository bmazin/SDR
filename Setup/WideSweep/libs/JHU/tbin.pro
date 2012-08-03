;-------------------------------------------------------------
;+
; NAME:
;       TBIN
; PURPOSE:
;       Total binned values.
; CATEGORY:
; CALLING SEQUENCE:
;       t = tbin(in,val)
; INPUTS:
;       in = array of indices of values.   in
;         Must be integers from 0 to some max, N.
;       val = array of values.             in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       t = returned totaled values.       out
; COMMON BLOCKS:
; NOTES:
;       Notes: This is a weighted histogram, where
;         the values are the weights.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 05
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function tbin, in, val, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Total binned values.'
	  print,' t = tbin(in,val)'
	  print,'   in = array of indices of values.   in'
	  print,'     Must be integers from 0 to some max, N.'
	  print,'   val = array of values.             in'
	  print,'   t = returned totaled values.       out'
	  print,' Notes: This is a weighted histogram, where'
	  print,'   the values are the weights.'
	  return,''
	endif
 
	h = histogram(in, rev=r)	; Histogram indices and get rev_ind.
	n = n_elements(h)		; Size of histogram.
	t = h*0.			; Accumulator.
 
	for i=0, n-1 do begin
	  lo = r(i)
	  hi = r(i+1)
	  if hi gt lo then t(i)=total(val(r(lo:hi-1)))
	endfor
 
	return, t
 
	end
