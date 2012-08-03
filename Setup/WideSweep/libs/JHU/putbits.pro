;-------------------------------------------------------------
;+
; NAME:
;       PUTBITS
; PURPOSE:
;       Insert specified bits in a target.
; CATEGORY:
; CALLING SEQUENCE:
;       out = putbits(src, tar, s, n)
; INPUTS:
;       src = integer scalar value to get bits from.    in
;       tar = integer scalar value to insert bits in.   in
;       s = bit number in tar to start at (LSB is 0).   in
;       n = number of bits to insert.                   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = returned value.                           out
; COMMON BLOCKS:
; NOTES:
;       Notes: source and target must be a single scalars of
;         one of the integer data types (byte, int, u_int,
;         long, u_long, long_64, u_long_64).
;         Returned value is same data type as target.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Jun 7
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
        function putbits, src0, tar, start, num, help=hlp
 
        if (n_params(0) lt 4) or keyword_set(hlp) then begin
          print,' Insert specified bits in a target.'
          print,' out = putbits(src, tar, s, n)'
          print,'   src = integer scalar value to get bits from.    in'
          print,'   tar = integer scalar value to insert bits in.   in'
          print,'   s = bit number in tar to start at (LSB is 0).   in'
          print,'   n = number of bits to insert.                   in'
          print,'   out = returned value.                           out'
          print,' Notes: source and target must be a single scalars of'
          print,'   one of the integer data types (byte, int, u_int,'
          print,'   long, u_long, long_64, u_long_64).'
          print,'   Returned value is same data type as target.'
          return,''
        endif
 
	;------  Source error checks  ----------------
	t = datatype(src0,integer_bits=bits)
        if bits le 0 then begin
          print,' Error in putbits: Source must be an integer.'
          return,-1
        endif
	if bits lt num then begin
	  print,' Error in putbits: Requested '+strtrim(num,2)+ $
	    ' bit'+plural(num)+', but source only has '+ $
	    strtrim(bits,2)+' bits.'
          return,-1
	endif
 
	;------  Target error checks  ----------------
	t = datatype(tar,integer_bits=bits)
        if bits le 0 then begin
          print,' Error in putbits: Target must be an integer.'
          return,-1
        endif
	if (start+num) ge bits then begin
	  print,' Error in putbits: '+$
	    'Target ('+strtrim(bits,2)+' bits) is too small to'
	  print,'   insert '+strtrim(num,2)+' bits starting at bit '+$
	    strtrim(start,2)+'.'
	  return,-1
	endif
 
	;--------------------------------------------------
	;  Set up mask to match source bits.  Use it to
	;  clear away any other bits (unrequested bits)
	;  after forcing source data type to match target.
	;  Mask will be shifted and inverted later.
	;--------------------------------------------------
	case bits of
8:	begin				; Byte.
	  mask = 2B^num - 1B		; Mask for source bits.
	  src = byte(src0) and mask	; Force to target type and mask bits.
	end
16:	begin				; Int.
	  mask = 2^num - 1		; Mask for source bits.
	  src = uint(src0) and mask	; Force to target type and mask bits.
	end
32:	begin				; Long.
	  mask = 2L^num - 1L		; Mask for source bits.
	  src = ulong(src0) and mask	; Force to target type and mask bits.
	end
64:	begin				; Long_64.
	  mask = 2LL^num - 1LL		; Mask for source bits.
	  src = ulong64(src0) and mask	; Force to target type and mask bits.
	end
else:	stop,' Stopped in putbits: internal error.'
	endcase
 
	;-----  Shift and invert mask  -----------------
	clear = not(ishft(mask,start))	; Target bit clearing mask.
 
	;-----  Insert new bits into target  --------
	out = (clear and tar) or ishft(src,start)
 
	return, out
 
	end
