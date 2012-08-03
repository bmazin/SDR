;-------------------------------------------------------------
;+
; NAME:
;       BEST_FFT
; PURPOSE:
;       Attempts to find size of fastest FFT from given choices.
; CATEGORY:
; CALLING SEQUENCE:
;       m = best_fft(n)
; INPUTS:
;       n = proposed FFT size.                         in
; KEYWORD PARAMETERS:
;       Keywords:
;         DELTA=d  The range to search in samples or percent.
;           Default = +/-1.
;         /PERCENT means DELTA is in percent of n.
;         /DOWN  Search from n down to n-DELTA.
; OUTPUTS:
;       m = Predicted fastest FFT size within range.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: the selection is made based on the prime factors
;         of the possible values.  The largest prime factor of
;         each candidate is determined and the value with the
;         smallest max prime factor is considered the best to use.
;         For multiple matches the one with the smallest sum
;         of the prime factors is selected.
; MODIFICATION HISTORY:
;       R. Sterner, 8 Feb, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function best_fft,n0,delta=delta,percent=percent,down=down,help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Attempts to find size of fastest FFT from given choices.'
	  print,' m = best_fft(n)'
	  print,'   n = proposed FFT size.                         in'
	  print,'   m = Predicted fastest FFT size within range.   out'
	  print,' Keywords:'
	  print,'   DELTA=d  The range to search in samples or percent.'
	  print,'     Default = +/-1.'
	  print,'   /PERCENT means DELTA is in percent of n.'
	  print,'   /DOWN  Search from n down to n-DELTA.'
	  print,' Notes: the selection is made based on the prime factors'
	  print,'   of the possible values.  The largest prime factor of'
	  print,'   each candidate is determined and the value with the'
	  print,'   smallest max prime factor is considered the best to use.'
	  print,'   For multiple matches the one with the smallest sum'
	  print,'   of the prime factors is selected.'
	  return, -1
	endif
 
	n = n0					   ; Copy value.
	if n_elements(delta) eq 0 then delta = 1.  ; Default is 1.
	dn = delta				   ; Assume samples.
	if keyword_set(percent) then dn = fix(dn/100.*n)>1	; Was percent.
	if keyword_set(down) then begin
	  arr = makei(n-dn,n,1)			   ; Search down.
	endif else begin
	  arr = makei(n-dn,n+dn,1)		   ; Possible values.
	endelse
 
	n = n_elements(arr)			; Number to check.
	mx = lonarr(n)				; Max prime.
	sp = lonarr(n)				; Sum of primes.
 
	for i=0,n-1 do begin			; Loop through numbers.
	  factor,arr(i),pp,nn,/quiet		; Factor each.
	  mx(i) = max(pp)			; Max factor.
	  sp = total(pp)			; Sum of primes.
	endfor
 
	w = where(mx eq min(mx), cnt)		; Look for min max fact.
	if cnt eq 1 then begin
	  return, arr(w(0))			; One case.
	endif else begin			; Multiple cases.
	  a = arr(w)
	  sp = sp(w)
	  w = where(sp eq min(sp))		; Find min sum.
	  return, a(w(0))
	endelse
 
	end
