;-------------------------------------------------------------
;+
; NAME:
;       PMATCH
; PURPOSE:
;       Find a given pattern in a 1-d array.
; CATEGORY:
; CALLING SEQUENCE:
;       pmatch, s, p, in
; INPUTS:
;       s = array to search.         in
;       p = pattern array.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         /ALL means return index of all matches, else just first.
; OUTPUTS:
;       in = index of match.         out
;          -1 means no match found.
; COMMON BLOCKS:
; NOTES:
;       Notes: useful if you need to find a sequence of values
;         occuring somewhere in an array.  Longer pattern
;         arrays give slower searches.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Apr 30
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro pmatch, s, p, in, all=all, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Find a given pattern in a 1-d array.'
	  print,' pmatch, s, p, in'
	  print,'   s = array to search.         in'
	  print,'   p = pattern array.           in'
	  print,'   in = index of match.         out'
	  print,'      -1 means no match found.'
	  print,' Keywords:'
	  print,'   /ALL means return index of all matches, else just first.'
	  print,' Notes: useful if you need to find a sequence of values'
	  print,'   occuring somewhere in an array.  Longer pattern'
	  print,'   arrays give slower searches.'
	  return
	endif
 
	;---------------------------------------------------------------
	;  The technique is to find all matches for each pattern value,
	;  shifting the input array to align all the expected matches
	;  to the starting index.  A logical EQ gives a byte array of
	;  0s and 1s, these are ANDed together for each pattern value.
	;  The starting index of the first complete match, if any
	;  is returned.
	;---------------------------------------------------------------
 
	m = s eq p(0)
	for i=0,n_elements(p)-1 do m = m and (shift(s,-i) eq p(i))
	if keyword_set(all) then in = where(m) else $
	  in = (where(m))(0)
 
	return
	end
