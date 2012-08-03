;-------------------------------------------------------------
;+
; NAME:
;       GETSTR
; PURPOSE:
;       Get delimited strings from a text string or array.
; CATEGORY:
; CALLING SEQUENCE:
;       s = getstr(txt)
; INPUTS:
;       txt = input text string or string array.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = Returned array of strings found.       out
; COMMON BLOCKS:
; NOTES:
;       Notes: Delimited strings must be surrounded by
;         a single or double quote.  The other type of
;         quote may be contained within the delimited string.
;         The strings may be separated by white space, commas,
;         or any other kind of separator.
;         If no strings are found a null string is returned.
;         Only delimited strings are returned, all other items
;         are ignored.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Apr 10
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function getstr, txt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get delimited strings from a text string or array.'
	  print,' s = getstr(txt)'
	  print,'   txt = input text string or string array.   in'
	  print,'   s = Returned array of strings found.       out'
	  print,' Notes: Delimited strings must be surrounded by'
	  print,'   a single or double quote.  The other type of'
	  print,'   quote may be contained within the delimited string.'
	  print,'   The strings may be separated by white space, commas,'
	  print,'   or any other kind of separator.'
	  print,'   If no strings are found a null string is returned.'
	  print,'   Only delimited strings are returned, all other items'
	  print,'   are ignored.'
	  return, ''
	endif
 
	n = n_elements(txt)		; Number of lines to search.
	sa = ['']			; Seed array.
 
	;-------  Loop through input lines  -------------
	for i=0, n-1 do begin
	  t = txt(i)			; Extract i'th line.
loop:	  len = strlen(t)               ; Length of this line.
	  p1 = strpos(t,"'")		; Look for '.
	  p2 = strpos(t,'"')		; Look for ".
	  if (p1>p2) lt 0 then goto, skip	; No strings in line.
	  p = -1			; Don't know delimiter position yet.
	  if p1 lt 0 then p=p2		; Correct position was p2.
	  if p2 lt 0 then p=p1		; Correct position was p1.
	  if p lt 0 then p=p1<p2	; Take first position.
	  d = strmid(t,p,1)		; Pick off delimiter.
	  b = byte(t) eq (byte(d))(0)	; Find string limits.
	  w = [where(b eq 1),len]	; Where are they?  Add end of string.
	  lo = w(0)+1			; String start.
	  hi = w(1)-1			; End of string.
	  sa = [sa,strmid(t,lo,hi-lo+1)]	; Pick off string.
	  t = strmid(t,hi+2,999)	; Drop front of line.
	  if t ne '' then goto, loop	; Keep looking.
skip:
	endfor  ; i
 
	if n_elements(sa) eq 1 then begin	; No strings found.
	  return, ''
	endif else begin			; Drop seed value.
	  return, sa(1:*)
	endelse
 
	end
