;-------------------------------------------------------------
;+
; NAME:
;       PLURAL
; PURPOSE:
;       Plural function: returns 's' if arg > 1, else ''.
; CATEGORY:
; CALLING SEQUENCE:
;       c = plural(n,s,p)
; INPUTS:
;       n = a number.                                       in
;       s = optional item to return if singlular (def='').  in
;       p = optional item to return if plural (def='s').    in
;       c = returned item (def: '' if n is 1, else 's').    out'
; KEYWORD PARAMETERS:
;       Keywords:
;         /NUMBER means return n as a word: no,one,two,...
;           s may be given to change the returned word for 1.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Useful for generating numeric related messages.
;       Examples: print,strtrim(n,2)+' cow'+plural(n)
;        print,strtrim(n,2)+' '+plural(n,'ox','oxen')
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Dec 14
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function plural, n, sing, plur, number=num, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print," Plural function: returns 's' if arg > 1, else ''."
	  print,' c = plural(n,s,p)'
	  print,'   n = a number.                                       in'
	  print,"   s = optional item to return if singlular (def='').  in"
	  print,"   p = optional item to return if plural (def='s').    in"
	  print,"   c = returned item (def: '' if n is 1, else 's').    out'
	  print,' Keywords:'
	  print,'   /NUMBER means return n as a word: no,one,two,...'
	  print,'     s may be given to change the returned word for 1.'
	  print,' Notes: Useful for generating numeric related messages.'
	  print," Examples: print,strtrim(n,2)+' cow'+plural(n)"
	  print,"  print,strtrim(n,2)+' '+plural(n,'ox','oxen')"
	  return,''
	endif
 
	if keyword_set(num) then begin
	  if n le 10 then begin
	    if n_elements(sing) eq 0 then sing = 'one'
	    return,(['no',sing,'two','three','four','five','six',$
	      'seven','eight','nine','ten'])(n)
	  endif else return,strtrim(n,2)
	endif
 
	if n_elements(sing) eq 0 then sing = ''
	if n_elements(plur) eq 0 then plur = 's'
	if n eq 1 then return,sing else return,plur
 
	end
