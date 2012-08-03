;-------------------------------------------------------------
;+
; NAME:
;       DETAB
; PURPOSE:
;       Replace tab characters by spaces.
; CATEGORY:
; CALLING SEQUENCE:
;       out = detab(in)
; INPUTS:
;       in = input text string.              in
;         Scalar or array.
; KEYWORD PARAMETERS:
;       Keywords:
;         TAB=tb  number of spaces per tab (def=8).
; OUTPUTS:
;       out = processed output text string.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Nov 3
;       R. Sterner, 2003 Aug 27 --- Allowed text arrays.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function detab, ina, tab=tab, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Replace tab characters by spaces.'
	  print,' out = detab(in)'
	  print,'   in = input text string.              in'
	  print,'     Scalar or array.'
	  print,'   out = processed output text string.  out'
	  print,' Keywords:'
	  print,'   TAB=tb  number of spaces per tab (def=8).'
	  return,''
	endif
 
	if n_elements(tab) eq 0 then tab=8	; Default tab setting.
 
	outa = ina
 
	for ia=0,n_elements(ina)-1 do begin
 
	  in = ina(ia)
 
	  ;------  Check if any tabs occur  --------
	  b = byte(in)
	  w = where(b eq 9, cnt)
	  if cnt eq 0 then continue	; Go to next line.
 
	  ;------  Process tabs  -------------------
	  out = ''				; Output string.
	  p = 0					; Pointer.
	  for i=0,cnt-1 do begin			; Loop through tabs.
	    ii = w(i)				; Tab position.
	    out = out + strmid(in,p,ii-p)		; Move text before tab.
	    jj = strlen(out)			; Effective position of nxt tab.
	    n = tab*(floor(jj/tab)+1) - jj	; Expand to n spaces.
	    out = out + spc(n)			; Add tab spaces.
	    p = ii+1				; Next pointer position.
	  endfor
 
	  ;-------  Text after last tab  ----------
	  out = out + strmid(in,p,strlen(in)-p)	; Handle end of string.
 
	  outa(ia) = out
 
	endfor
 
	return, outa
	end
