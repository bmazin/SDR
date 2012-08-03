;-------------------------------------------------------------
;+
; NAME:
;       STRLENTAB
; PURPOSE:
;       Gives length of a string with tab characters expanded.
; CATEGORY:
; CALLING SEQUENCE:
;       len = strlentab(txt)
; INPUTS:
;       txt = text string.                 in
; KEYWORD PARAMETERS:
;       Keywords:
;         TABSIZE=s  # spaces tabs expand to (def=8).
; OUTPUTS:
;       len = length of expanded string.   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 Feb, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function strlentab, txt, help=hlp, tabsize=ts
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Gives length of a string with tab characters expanded.'	
	  print,' len = strlentab(txt)'
	  print,'   txt = text string.                 in'
	  print,'   len = length of expanded string.   out'
	  print,' Keywords:'
	  print,'   TABSIZE=s  # spaces tabs expand to (def=8).'
	  return, -1
	endif
 
	w = where(byte(txt) eq 9, c)	   ; Where are tabs?
	if c eq 0 then return, strlen(txt) ; No tabs.
 
	if n_elements(ts) eq 0 then ts = 8
 
	len = 0				   ; Length due to tabs.
 
	for i = 0, nruns(w)-1 do begin	   ; Loop thru runs of tabs.
	  leni = 0			   ; Length from i'th run.
	  wi = getrun(w, i)		   ; Get i'th run.
	  leni = leni+(ts-1)-(wi(0) mod ts)  ; Extra spaces due to leading tab.
	  leni = leni+(ts-1)*(n_elements(wi)-1)  ; Extra spaces from other tabs.
	  len = len + leni		   ; Count i'th run spaces.
	  w = w + leni			   ; Inc all positions by tab effect.
	endfor
 
	return, strlen(txt) + len	   ; Total length.
 
	end
