;-------------------------------------------------------------
;+
; NAME:
;       JS_INCMONTH
; PURPOSE:
;       Increment JS by one month.
; CATEGORY:
; CALLING SEQUENCE:
;       js2 = js_incmonth(js1, [n])
; INPUTS:
;       js1 = input Julian Seconds.                   in
;       n = optional number to add to month (def=1).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       js2 = output Julian Seconds.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: Incrementing JS by one day is easy, just add
;         86400D0 for each day.  This routine increments
;         by exactly one month, so starting with 2000 May 2 12:46
;         gives 2000 Jun 2 12:46
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Jun 23
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function js_incmonth, js, n,  help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Increment JS by one month.'
	  print,' js2 = js_incmonth(js1, [n])'
	  print,'   js1 = input Julian Seconds.                   in'
	  print,'   n = optional number to add to month (def=1).  in'
	  print,'   js2 = output Julian Seconds.  out'
	  print,' Notes: Incrementing JS by one day is easy, just add'
	  print,'   86400D0 for each day.  This routine increments'
	  print,'   by exactly one month, so starting with 2000 May 2 12:46'
	  print,'   gives 2000 Jun 2 12:46'
	  return,''
	endif
 
	if n_elements(n) eq 0 then n=1	; Default add 1 month.
	dy = fix(n/12.)			; # years.
	dn = n mod 12			; # months.
 
	js2ymds, js, y, m, d, s		; Split JS into parts.
	y = y + dy			; Adjust year.
	m = m + dn			; Increment month number.
	if m gt 12 then begin		; Deal with overflow.
	  m = m - 12
	  y = y + 1
	endif
	return, ymds2js(y,m,d,s)	; Back to JS.
 
	end
