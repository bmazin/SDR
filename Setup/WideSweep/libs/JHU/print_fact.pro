;-------------------------------------------------------------
;+
; NAME:
;       PRINT_FACT
; PURPOSE:
;       Print prime factors found by the factor routine.
; CATEGORY:
; CALLING SEQUENCE:
;       print_fact, p, n
; INPUTS:
;       p = prime factors.          in
;       n = number of each factor.  in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner  4 Oct, 1988.
;       RES 25 Oct, 1990 --- converted to IDL V2.
;       R. Sterner, 26 Feb, 1991 --- Renamed from print_factors.pro
;       R. Sterner, 1999 Jun 30 --- Better output format.
;       R. Sterner, 1999 Jul  7 --- Bigger values (used unsigned).
;       R. Sterner, 1999 Jul  9 --- Made backward compatable.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro print_fact, p, n, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Print prime factors found by the factor routine.'
	  print,' print_fact, p, n'
	  print,'   p = prime factors.          in'
	  print,'   n = number of each factor.  in'
	  return
	endif
 
	;-------  Drop unused primes  ---------------
	w = where(n gt 0)	; Find only primes used.
	p2 = p(w)
	n2 = n(w)
 
	;-------  Use largest available integer type  --------------
	flag = !version.release ge 5.2
	if flag eq 1 then begin
	  err=execute('t=1ULL')		; Use 64 bit int (hide from old IDL).
	endif else begin
	  t = 1L			; Use long int (best available in old).
	endelse
 
	;-------  Compute number from it's prime factors.  ----------
	for i = 0, n_elements(p2)-1 do t = t * p2(i)^n2(i)
 
	;-------  Prepare output  -----------------------
	a = strtrim(t,2)+' = '			; Start factors string.
	b = ''					; Start exponents string.
	last = n_elements(p2)-1			; Last factors index.
	for i=0, last do begin
	  a = a + strtrim(p2(i),2)		; Insert next factor.
	  lena = strlen(a)			; Length of factor string.
	  nxtb = strtrim(n2(i),2)		; Next exponent.
	  if nxtb eq '1' then nxtb=' '		; Weed out 1s.
	  b = b+spc(lena,b,/notrim)+nxtb	; Insert next exponent.
	  if i ne last then a=a+' x '		; Not last, add x.
	endfor
 
	;------  Print exponents and factors  -----------
	print,' '
	print,' '+b
	print,' '+a
 
	return
	end
