;-------------------------------------------------------------
;+
; NAME:
;       ZERO_INT
; PURPOSE:
;       Return a zero of the requested data type.
; CATEGORY:
; CALLING SEQUENCE:
;       z = zero_int(val)
; INPUTS:
;       val = given value.                         in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NULL For strings return a null string instead of '0'.
;            Does not effect other data types.
; OUTPUTS:
;       z = returned zero of the same data type.   out
; COMMON BLOCKS:
; NOTES:
;       Note: Undefined, Structures, Pointers, and Objects
;         return a 16 bit 0.  To get a 1 of the same data type do:
;         one = zero_int(val)+1B (except for String type).
;       Useful for promoting a value or array to a higher
;       precision data type.  Some examples:
;       If A is long int and B is int then B+zero_int(A)
;       will be long int.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Jun 30
;       R. Sterner, 2004 Mar 30 --- Added /NULL option for string type.
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function zero_int, val, null=null, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return a zero of the requested data type.'
	  print,' z = zero_int(val)'
	  print,'   val = given value.                         in'
	  print,'   z = returned zero of the same data type.   out'
	  print,' Keywords:'
	  print,"   /NULL For strings return a null string instead of '0'."
	  print,'      Does not effect other data types.'
	  print,' Note: Undefined, Structures, Pointers, and Objects'
	  print,'   return a 16 bit 0.  To get a 1 of the same data type do:'
	  print,'   one = zero_int(val)+1B (except for String type).'
	  print,' Useful for promoting a value or array to a higher'
	  print,' precision data type.  Some examples:'
	  print,' If A is long int and B is int then B+zero_int(A)'
	  print,' will be long int.'
	  return, ''
	endif
 
	typ = datatype(val)
 
	case typ of
'UND':	out = 0
'BYT':	out = 0B
'INT':	out = 0
'LON':	out = 0L
'FLO':	out = 0.
'DOU':	out = 0.D0
'COM':	out = complex(0,0)
'STR':	if keyword_set(null) then out='' else out='0'
'STC':	out = 0
'DCO':	out = dcomplex(0,0)
'PTR':	out = 0
'OBJ':	out = 0
'UIN':	out = 0U
'ULO':	out = 0UL
'LLO':	out = 0LL
'ULL':	out = 0ULL
else:	out = 0
	endcase
 
	return, out
 
	end
