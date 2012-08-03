;-------------------------------------------------------------
;+
; NAME:
;       NUMNAME
; PURPOSE:
;       Generate names or text strings with embedded numbers.
; CATEGORY:
; CALLING SEQUENCE:
;       name = numname(pat, i, [j, k])
; INPUTS:
;       pat = pattern of text string.                      in
;       i = number to substitute for # in pat.             in
;       j = number to substitute for $ in pat.             in
;       k = number to substitute for % in pat.             in
; KEYWORD PARAMETERS:
;       Keywords:
;         DIGITS=d number of digits to force in name (def=none).
;           d can be an array giving the number of digits for
;           each of i, j, and k (else d will apply to all).
; OUTPUTS:
;       name = resulting text string.                      out
; COMMON BLOCKS:
; NOTES:
;       Notes: Ex1: pat = 'file#.txt',  i=7, name='file7.txt'
;          Ex2: pat = 'A#B$C%D', i=1, j=2, k=3, name='A1B2C3D'
;          Ex3: pat='A#B', i=5, DIGITS=4, name='A0005B'.
;          If j and k are not given then $ and % are not changed
;          in pat if they occur.
;          Inverse of namenum, see namenum.
; MODIFICATION HISTORY:
;       R. Sterner, 11 Jan, 1990
;       R. Sterner,  3 Sep, 1992 --- fixed an integer overflow problem
;       found by George Simon at Sac Peak NSO.
;       R. Sterner, 2006 Dec 06 --- Revised dig to be an array.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function numname, pat, i, j, k, help=hlp, digits=dig
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Generate names or text strings with embedded numbers.'
	  print,' name = numname(pat, i, [j, k])'
	  print,'   pat = pattern of text string.                      in'
	  print,'   i = number to substitute for # in pat.             in'
	  print,'   j = number to substitute for $ in pat.             in'
	  print,'   k = number to substitute for % in pat.             in'
	  print,'   name = resulting text string.                      out'
	  print,' Keywords:'
	  print,'   DIGITS=d number of digits to force in name (def=none).'
	  print,'     d can be an array giving the number of digits for'
	  print,'     each of i, j, and k (else d will apply to all).'
	  print," Notes: Ex1: pat = 'file#.txt',  i=7, name='file7.txt'"
	  print,"    Ex2: pat = 'A#B$C%D', i=1, j=2, k=3, name='A1B2C3D'"
	  print,"    Ex3: pat='A#B', i=5, DIGITS=4, name='A0005B'."
	  print,'    If j and k are not given then $ and % are not changed'
	  print,'    in pat if they occur.'
	  print,'    Inverse of namenum, see namenum.'
	  return, -1
	endif
 
	if not keyword_set(dig) then begin	; Force dig defined.
	  dig = 0				; # digits (def).
	  lst_dig = 0				; Index of last element in dig.
	endif else lst_dig=n_elements(dig)-1	; Index of last element in dig.
 
	n = strtrim(dig[0],2)			; # digits for i.
	fmt = '(I'+n+'.'+n+')'			; Format.
	ii = string(i,form=fmt)			; Format i into ii.
	name = stress(pat, 'R', 0, '#', ii)	; Replace # with ii.
	if n_params(0) lt 3 then return, name	; Return if done.
 
	n = strtrim(dig[1<lst_dig],2)		; # digits for j.
	fmt = '(I'+n+'.'+n+')'
	jj = string(j,form=fmt)
	name = stress(name, 'R', 0, '$', jj)
	if n_params(0) lt 4 then return, name
 
	n = strtrim(dig[2<lst_dig],2)		; # digits for k.
	fmt = '(I'+n+'.'+n+')'
	kk = string(k,form=fmt)
	name = stress(name, 'R', 0, '%', kk)
	return, name
 
	end
