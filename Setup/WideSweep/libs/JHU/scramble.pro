;-------------------------------------------------------------
;+
; NAME:
;       SCRAMBLE
; PURPOSE:
;       Scrambles an array or returns an array scrambled indices.
; CATEGORY:
; CALLING SEQUENCE:
;       r = scramble(in)
; INPUTS:
;       in = array to scramble.                        in
;         If in is a scalar integer then an array of
;         indices from 0 to in-1 is returned in scrambled form.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       r = scrambled values returned.                 out
; COMMON BLOCKS:
;       scramble_com
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 17 Dec, 1984.
;       RES  10 Feb, 1987 --- allowed arrays.
;       R. Sterner, 1999 Jun 9 --- Upgraded to long ints.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function scramble, a, help=hlp
 
	common scramble_com, k
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Scrambles an array or returns an array scrambled indices.'
	  print,' r = scramble(in)'
	  print,'   in = array to scramble.                        in'
	  print,'     If in is a scalar integer then an array of'
	  print,'     indices from 0 to in-1 is returned in scrambled form.'
	  print,'   r = scrambled values returned.                 out'
	  return,''
	endif
 
	;--------  Array of values  --------
	if (size(a))(0) ne 0 then begin	
	  n = n_elements(a)	   ; Number of elements to scramble.
	  ir = a		   ; Array to scramble.
	;--------  Number of indices to scramble  -------
	endif else begin
	  n = a			   ; Number of elements to scramble.
	  ir = lindgen(n)	   ; Array to scramble.
	endelse
 
	r = lonarr(n)		   ; Make output array space.
 
	for i = n-1L,0,-1 do begin ; Loop thru unscrambled list backwards.
	  rnd = randomu(k)
	  j = long(rnd*(i+1))	   ; Random number from 0 to I.
	  r(i) = ir(j)		   ; Move number J to output.
	  ir(j) = ir(i)		   ; Put last number into location J.
	endfor
 
	return,r
	end
