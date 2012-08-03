;-------------------------------------------------------------
;+
; NAME:
;       TXTMERCON
; PURPOSE:
;       Merge continued lines in a text array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = txtmercon(in)
; INPUTS:
;       in = Array of text to process.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         CHAR=chr Continuation character (def='$').
;           Any lines in the input array that end with chr
;           will be merged with the following line.
;           Multiple line continuations are allowed.
; OUTPUTS:
;       out = Returned array of processed text. out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Dec 05
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function txtmercon, in, char=chr, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Merge continued lines in a text array.'
	  print,' out = txtmercon(in)'
	  print,'   in = Array of text to process.          in'
	  print,'   out = Returned array of processed text. out'
	  print,' Keywords:'
	  print,"   CHAR=chr Continuation character (def='$')."
	  print,'     Any lines in the input array that end with chr'
	  print,'     will be merged with the following line.'
	  print,'     Multiple line continuations are allowed.'
	  return,''
	endif
 
	out = ['']				; Output array.
	last = ''				; Last text.
	n = n_elements(in)			; Lines in input.
	if n_elements(chr) eq 0 then chr='$'	; Default continuation char.
 
	for i=0,n-1 do begin			; Loop through input lines.
	  t = last + in[i]			; Add last to next line.
	  if strmid(t,strlen(t)-1,1) eq chr then begin	; Continuation char?
	    last = strmid(t,0,strlen(t)-1)	;   Yes, drop it, save as last.
	  endif else begin			; Not continued.
	    out = [out, t]			;   Move text to output array.
	    last = ''				;   Clear last.
	  endelse
	endfor ; i
 
	return, out[1:*]			; Drop leading NULL.
 
	end
