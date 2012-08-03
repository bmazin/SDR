;-------------------------------------------------------------
;+
; NAME:
;       NAMENUM
; PURPOSE:
;       Break a name into a pattern and numbers in the name.
; CATEGORY:
; CALLING SEQUENCE:
;       namenum, name, pat, i, j, k
; INPUTS:
;       name = text string to analyze.              in
; KEYWORD PARAMETERS:
;       Keywords:
;         DIGITS=d  max number of digits in a number in the string.
; OUTPUTS:
;       pat = pattern of text string.               out 
;       i = number that was in the # position.      out 
;       j = number that was in the $ position.      out 
;       k = number that was in the % position.      out 
; COMMON BLOCKS:
; NOTES:
;       Notes: Ex1: name='file7.txt' -> pat = 'file#.txt',  i=7
;         Ex2: name='A1B2C3D' -> pat = 'A#B$C%D', i=1, j=2, k=3
;         Ex3: name='A0005B' -> pat='A#B', i=5.
;         If $ and % are not in resulting pattern then"
;           j and k did not occur.
;         Inverse of numname, see numname.
; MODIFICATION HISTORY:
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro namenum, name, pat, i, j, k, digits=dig, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Break a name into a pattern and numbers in the name.'
	  print,' namenum, name, pat, i, j, k'
	  print,'   name = text string to analyze.              in'
	  print,'   pat = pattern of text string.               out 
	  print,'   i = number that was in the # position.      out 
	  print,'   j = number that was in the $ position.      out 
	  print,'   k = number that was in the % position.      out 
	  print,' Keywords:'
	  print,'   DIGITS=d  max number of digits in a number in the string.'
	  print,"   Notes: Ex1: name='file7.txt' -> pat = 'file#.txt',  i=7"
	  print,"     Ex2: name='A1B2C3D' -> pat = 'A#B$C%D', i=1, j=2, k=3"
	  print,"     Ex3: name='A0005B' -> pat='A#B', i=5."
	  print,'     If $ and % are not in resulting pattern then"
	  print,'       j and k did not occur.'
	  print,'     Inverse of numname, see numname.'
	  return
	endif
 
	i = 0					; Defaults are 0.
	j = 0
	k = 0
	dig = 1					; Default is 1 digit.
	sp0 = bytarr(80)+32b			; Array of 80 spaces.
 
	t = byte(name)				; Name as a byte string.
	w = where((t ge 48) and (t le 57), count)  ; Find numbers.
 
	;-----  No numbers in name  -------------
	if count eq 0 then begin		; No number, pattern is name.
	  pat = name
	  return
	endif
 
	;------  Name has numbers in it, process up to 3 of them  -----------
	sp = sp0				; Get a clean space array.
	sp(w) = t(w)				; Move digits from t to sp.
	ss = string(sp)				; Convert to string.
	n = nwrds(ss)				; How many numbers?
 
	;--------  first number (#)  ----------
	if n ge 1 then begin
	  w = getwrd(ss, 0, loc=loci)
	  leni = strlen(w)
	  i = w + 0
	  start = 0
	  len = loci
	  pat = strmid(name, start, len) + '#'
	  loc = loci
	  len = leni
	  dig = dig > len
	endif
	
	;--------  second number ($)  ----------
	if n ge 2 then begin
	  w = getwrd(ss, 1, loc=locj)
	  lenj = strlen(w)
	  j = w + 0
	  start = loci + leni
	  len = locj - start
	  pat = pat + strmid(name, start, len) + '$'
	  loc = locj
	  len = lenj
	  dig = dig > len
	endif
	
	;--------  third number (%)  ----------
	if n ge 3 then begin
	  w = getwrd(ss, 2, loc=lock)
	  lenk = strlen(w)
	  k = w + 0
	  start = locj + lenj
	  len = lock - start
	  pat = pat + strmid(name, start, len) + '%'
	  loc = lock
	  len = lenk
	  dig = dig > len
	endif
 
	;---------  finish up  -------------
	start = loc + len
	pat = pat + strmid(name, start, 99)
	
	return
 
	end
	  
