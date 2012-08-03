;-------------------------------------------------------------
;+
; NAME:
;       SWAP_NIBBLES
; PURPOSE:
;       Swap nibbles in a byte.
; CATEGORY:
; CALLING SEQUENCE:
;       ss = swap_nibbles(bb)
; INPUTS:
;       bb = input byte or byte array.  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ss = output byte or byte array. out
; COMMON BLOCKS:
; NOTES:
;       Notes: swaps the upper and lower 4 four
;       bits in the given bytes.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 30
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function swap_nibbles, bb, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Swap nibbles in a byte.'
	  print,' ss = swap_nibbles(bb)'
	  print,'   bb = input byte or byte array.  in'
	  print,'   ss = output byte or byte array. out'
	  print,' Notes: swaps the upper and lower 4 four'
	  print,' bits in the given bytes.'
	  return, ''
	endif
 
	return, ishft(bb,-4) or ishft(bb,4)
 
	end
