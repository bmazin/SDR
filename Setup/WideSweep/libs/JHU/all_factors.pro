;-------------------------------------------------------------
;+
; NAME:
;       ALL_FACTORS
; PURPOSE:
;       Return sorted array of all factors of a given number.
; CATEGORY:
; CALLING SEQUENCE:
;       f = all_factors(num)
; INPUTS:
;       num = Number to factor (>0).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       f = Array of factors of num.  out
; COMMON BLOCKS:
; NOTES:
;       Note: all factors are returned, not just the prime factors.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Apr 15
;       R. Sterner, 2004 Jul 27 --- Fixed to work for one prime factor.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function all_factors, num, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return sorted array of all factors of a given number.'
	  print,' f = all_factors(num)'
	  print,'   num = Number to factor (>0).  in'
	  print,'   f = Array of factors of num.  out'
	  print,' Note: all factors are returned, not just the prime factors.'
	  return,''
	endif
 
	if num lt 1 then return,-1 
	if num eq 1 then return,[num]
 
	;---  Get primt factors  --------
	factor, num, p, n, /quiet
 
	;----  Get number of factors (all)  -----
	nfact = numfactors(num,/quiet) + 2
 
	;-----  Set up powers array  -------------
	np = n_elements(p)		; # primes.
	if np eq 1 then begin		; Special case: only 1 prime factor.
	  return,p(0)^lindgen(nfact)
	endif
	pow = intarr(np,nfact)
	div = round(exp(total(alog([1,n(0:np-2)+1]),/cum)))
	mm = n+1			; Mod.
	for i=0,np-1 do begin
	  pow(i,0) = transpose((indgen(nfact)/div(i)) mod mm(i))
	endfor
 
	;------  Compute factors  ------------
	ff = p(0)^pow(0,*)
	for i=1,np-1 do ff=ff*p(i)^pow(i,*)
 
	;------  sort  ------------------------
	is = sort(ff)
	return, ff(is)
 
	end
