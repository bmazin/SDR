;-------------------------------------------------------------
;+
; NAME:
;       FACTOR
; PURPOSE:
;       Find prime factors of a given number.
; CATEGORY:
; CALLING SEQUENCE:
;       factor, x, p, n
; INPUTS:
;       x = Number to factor (>1).       in
; KEYWORD PARAMETERS:
;       Keywords:
;         /QUIET  means do not print factors.
;         /DEBUG  Means list steps as they happen.
;         /TRY    Go beyond 20000 primes.
; OUTPUTS:
;       p = Array of prime numbers.      out
;       n = Count of each element of p.  out
; COMMON BLOCKS:
; NOTES:
;       Note: see also prime, numfactors, print_fact.
; MODIFICATION HISTORY:
;       R. Sterner.  4 Oct, 1988.
;       RES 25 Oct, 1990 --- converted to IDL V2.
;       R. Sterner, 1999 Jun 30 --- Improved (faster, bigger).
;       R. Sterner, 1999 Jul  7 --- Bigger values (used unsigned).
;       R. Sterner, 1999 Jul  9 --- Tried to make backward compatable.
;       R. Sterner, 2000 Jan 06 --- Fixed to ignore non-positive numbers.
;       R. Sterner, 2004 Nov 12 --- IDL 5.2 up only.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro factor, x, p, n, quiet=quiet, debug=debug, try=try, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Find prime factors of a given number.'
	  print,' factor, x, p, n'
	  print,'   x = Number to factor (>1).       in'
	  print,'   p = Array of prime numbers.      out'
	  print,'   n = Count of each element of p.  out'
	  print,' Keywords:'
	  print,'   /QUIET  means do not print factors.'
	  print,'   /DEBUG  Means list steps as they happen.'
	  print,'   /TRY    Go beyond 20000 primes.'
	  print,' Note: see also prime, numfactors, print_fact.'
	  return
	endif
 
	if x le 0 then return
 
	flag = !version.release ge 5.2
 
	s = sqrt(x)			; Only need primes up to sqrt(x).
	g = long(50 + 0.13457*s)	; Upper limit of # primes up to s.
	np = 50				; Start with np (50) primes.
	p = prime(np)			; Find np primes.
	n = intarr(n_elements(p))	; Divisor count.
 
	if flag eq 1 then $		; Working number.
;	  err=execute('t=ulong64(x)') $	; Pre IDL5.2 version.
	  t = ulong64(x) $		; IDL5.2 and up version.
	  else t=long(x)		; Best pre-5.2 integer.
	i = 0L				; Index of test prime.
 
loop:	pt = p(i)			; Pull test prime.
	if keyword_set(debug) then $
	  print,' Trying '+strtrim(pt,2)+' into '+strtrim(t,2)
	if flag eq 1 then $
;	  err=execute('t2=ulong64(t/pt)') $  ; Pre IDL5.2 version.
	  t2 = ulong64(t/pt) $		; IDL5.2 and up version.
	  else t2=long(t/pt)
	if t eq t2*pt then begin	; Check if it divides.
	  if keyword_set(debug) then $
	    print,'   Was a factor.  Now do '+strtrim(t2,2)
	  n(i) = n(i) + 1		; Yes, count it.
	  t = t2			; Result after division.
	  if t2 eq 1 then goto, done	; Check if done.
	  goto, loop			; Continue.
	endif else begin
	  i = i + 1			; Try next prime.
	  if i ge np then begin
	    s = sqrt(t)			; Only need primes up to sqrt(x).
	    g = long(50 + 0.13457*s)	; Upper limit of # primes up to s.
	    if g le np then goto, last	; Must be done.
	    np = (np+50)<g		; Want 50 more primes.
	    if (np gt 20000) and (not keyword_set(try)) then begin
	      print,' Too hard.  Tried '+strtrim(np-50,2)+' primes.'
	      print,' Trying to crack '+strtrim(t,2)
	      print,' To go farther use keyword /TRY.'
	      return
	    endif
	    if keyword_set(debug) then $
	      print,' Finding more primes: '+strtrim(np,2)+ $
	      '.  Max needed = '+strtrim(g,2)
	    p = prime(np)		; Find primes.
	    n = [n,intarr(50)]		; Make room for more factors.
	  endif
	  if i ge g then goto, last	; Nothing up to sqrt works.
	  goto, loop			; Continue.
	endelse
 
last:	p = [p,t]			; Residue was > sqrt, must be prime.
	n = [n,1]			; Must occur only once. (else < sqrt).
 
done:	w = where(n gt 0)
	n = n(w)			; Trim excess off tables.
	p = p(w)
 
	if not keyword_set(quiet) then print_fact, p, n
 
	return
	end
