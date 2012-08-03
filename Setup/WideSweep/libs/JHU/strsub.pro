;-------------------------------------------------------------
;+
; NAME:
;       STRSUB
; PURPOSE:
;       Extract a substring by start and end positions.
; CATEGORY:
; CALLING SEQUENCE:
;       ss = strsub(s, p1, p2)
; INPUTS:
;       s = string to extract from.                    in
;       p1 = position of first character to extract.   in
;       p2 = position of last character to extract.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /LAST  means positions are backwards from last char.
;           Ex: strsub(s,1,0,/last) returns last 2 chars in s.
; OUTPUTS:
;       ss = extracted substring.                      out
; COMMON BLOCKS:
; NOTES:
;       Notes: position of first character in s is 0.  If p1 and
;         p2 are out of range they set to be in range.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 6 Jan, 1985.
;       R. Sterner, 1996 Mar 20 --- Added /LAST.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function strsub,strng,p1,p2, last=last, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Extract a substring by start and end positions.'
	  print,' ss = strsub(s, p1, p2)'
	  print,'   s = string to extract from.                    in'
	  print,'   p1 = position of first character to extract.   in'
	  print,'   p2 = position of last character to extract.    in'
	  print,'   ss = extracted substring.                      out'
	  print,' Keywords:'
	  print,'   /LAST  means positions are backwards from last char.'
	  print,'     Ex: strsub(s,1,0,/last) returns last 2 chars in s.'
	  print,' Notes: position of first character in s is 0.  If p1 and'
	  print,'   p2 are out of range they set to be in range.'
	  return, -1
	endif
 
	n = strlen(strng)		; Lengths of each string.
	num = n_elements(strng)		; # strings.
	out = strarr(num)		; Output strings.
 
	for j=0, num-1 do begin		; Loop through all strings.
	  if keyword_set(last) then begin	; Work from back.
	    l1 = (p1>p2) < (n(j)-1)
	    l2 = (p1<p2) > 0
	    out(j) = strmid(strng(j),n(j)-1-l1,l1-l2+1)
	  endif else begin			; Work from front.
	    l1 = (p1<p2) > 0
	    l2 = (p2>p1) < (n(j)-1)
	    out(j) = strmid(strng(j),l1,l2-l1+1)
	  endelse
	endfor
 
	if num eq 1 then out = out(0)
	return, out
 
	end
