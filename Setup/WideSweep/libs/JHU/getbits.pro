;-------------------------------------------------------------
;+
; NAME:
;       GETBITS
; PURPOSE:
;       Pick out specified bits from a value.
; CATEGORY:
; CALLING SEQUENCE:
;       out = getbits(in, s, n)
; INPUTS:
;       in = integer value (scalar or array) to pick from. in
;       s = bit number to start at (LSB is 0).             in
;       n = number of bits to pick out (def=1).            in
; KEYWORD PARAMETERS:
;       Keywords:
;         /REDUCE means reduce extracted value to smallest
;           data type possible (unsigned) based on # bits (n).
; OUTPUTS:
;       out = returned value.                              out
; COMMON BLOCKS:
; NOTES:
;       Notes: Input value must be an integer data type:
;         byte, int, u_int, long, u_long, long_64, u_long_64
;         Returned value is same data type unless /REDUCE is used.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Jun 3
;       R. Sterner, 2002 Oct 15 --- Added /REDUCE, also forced num numeric.
;       R. Sterner, 2004 Feb 20 --- Howard Taylor found typo: ulon --> ulong.
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function getbits, in, start, num0, reduce=reduce, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Pick out specified bits from a value.'
	  print,' out = getbits(in, s, n)'
	  print,'   in = integer value (scalar or array) to pick from. in'
	  print,'   s = bit number to start at (LSB is 0).             in'
	  print,'   n = number of bits to pick out (def=1).            in'
	  print,'   out = returned value.                              out'
	  print,' Keywords:'
	  print,'   /REDUCE means reduce extracted value to smallest'
	  print,'     data type possible (unsigned) based on # bits (n).'
	  print,' Notes: Input value must be an integer data type:'
	  print,'   byte, int, u_int, long, u_long, long_64, u_long_64'
	  print,'   Returned value is same data type unless /REDUCE is used.'
	  return,''
	endif
 
	;-----  Input error checks  ------------
	t = datatype(in,integer_bits=bits)
	if bits le 0 then begin
	  print,' Error in getbits: must be an integer value.'
	  return,-1
	endif
	if n_elements(num0) eq 0 then num0=1
	num = num0 + 0
        if (start+num) gt bits then begin
          print,' Error in getbits: '+$
            'Source ('+strtrim(bits,2)+' bits) is too small to'
          print,'   extract '+strtrim(num,2)+' bits starting at bit '+$
            strtrim(start,2)+'.'
          return,-1
        endif
 
	;-----  Shift requested start bit to LSB  -----------
	out = ishft(in,-start)
 
	;-----  Needed bit mask  -------------
        case bits of
8:      mask = 2B ^num - 1B	; Byte mask.
16:     mask = 2  ^num - 1	; Int mask.
32:     mask = 2L ^num - 1L	; Long mask.
64:     mask = 2LL^num - 1LL	; Long_24 mask.
else:   stop,' Stopped in getbits: internal error.'
        endcase
 
	;-----  Mask off unrequested bits  --------- 
	val = out AND mask
 
	;-----  Reduce to min required data type  -----
	if keyword_set(reduce) then begin
	  if num le 8 then return, byte(val)
	  if num le 16 then return, uint(val)
	  if num le 32 then return, ulong(val)
	endif
 
	return, val
 
	end
