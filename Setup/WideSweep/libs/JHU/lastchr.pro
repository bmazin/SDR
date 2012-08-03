;-------------------------------------------------------------
;+
; NAME:
;       LASTCHR
; PURPOSE:
;       Set last character of a string, add if needed.
; CATEGORY:
; CALLING SEQUENCE:
;       out = lastchr(in,chr)
; INPUTS:
;       in = input text string.      in
;       chr = character to be last.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /REMOVE removes given last character if there.
; OUTPUTS:
;       out = modified text string.  out
; COMMON BLOCKS:
; NOTES:
;       Note: if input string was already correct nothing is changed.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Oct 15
;       R. Sterner, 2002 Mar 22 --- Added /REMOVE.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function lastchr, in, chr, remove=rem, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Set last character of a string, add if needed.'
	  print,' out = lastchr(in,chr)'
	  print,'   in = input text string.      in'
	  print,'   chr = character to be last.  in'
	  print,'   out = modified text string.  out'
	  print,' Keywords:'
	  print,'   /REMOVE removes given last character if there.'
	  print,' Note: if input string was already correct nothing is changed.'
	  return,''
	endif
 
	if keyword_set(rem) then begin
	  if strmid(in,strlen(in)-1,1) eq chr then begin
	    return, strmid(in,0,strlen(in)-1)
	  endif else begin
	    return, in
	  endelse
	endif
 
	if strmid(in,strlen(in)-1,1) eq chr then return, in
	return, in+chr
 
	end
