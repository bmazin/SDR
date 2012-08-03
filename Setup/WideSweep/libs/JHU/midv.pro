;-------------------------------------------------------------
;+
; NAME:
;       MIDV
; PURPOSE:
;       Return value midway between array extremes.
; CATEGORY:
; CALLING SEQUENCE:
;       vmd = midv(a)
; INPUTS:
;       a = array.                      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       vmd = (min(a)+max(a))/2.        out
;       
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 Aug, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function midv, x, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return value midway between array extremes.'
	  print,' vmd = midv(a)' 
	  print,'  a = array.                      in'
	  print,'  vmd = (min(a)+max(a))/2.        out'
	  print,' '
	  return, -1
	end
 
	return, .5*(min(x) + max(x))
	end
