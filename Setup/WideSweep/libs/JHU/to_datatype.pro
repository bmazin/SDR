;-------------------------------------------------------------
;+
; NAME:
;       TO_DATATYPE
; PURPOSE:
;       Convert arg to specified data type.
; CATEGORY:
; CALLING SEQUENCE:
;       out = to_datatype(in, typ)
; INPUTS:
;       in = Input item to be converted.                     in
;       typ = Data type code as given by the size function.  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = Returned item.                                 out
; COMMON BLOCKS:
; NOTES:
;       Note: The Numeric type codes are: 1=Byte, 2=Int, 3=Long,
;         4=Float, 5=Double, 6=Complex, 7=String, 9=DComplex,
;         12=UInt, 13=ULong, 14=Long64, 15=ULong64.
;         Any other type codes are ignored and the input is returned.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Sep 06
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function to_datatype, in, typ, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert arg to specified data type.'
	  print,' out = to_datatype(in, typ)'
	  print,'   in = Input item to be converted.                     in'
	  print,'   typ = Data type code as given by the size function.  in'
	  print,'   out = Returned item.                                 out'
	  print,' Note: The Numeric type codes are: 1=Byte, 2=Int, 3=Long,'
	  print,'   4=Float, 5=Double, 6=Complex, 7=String, 9=DComplex,'
	  print,'   12=UInt, 13=ULong, 14=Long64, 15=ULong64.'
	  print,'   Any other type codes are ignored and the input is returned.'
	  return,''
	endif
 
	;---------------------------------------------------
	;  If correct type already just return
	;---------------------------------------------------
	typ0 = size(in,/type)		; Original data type.
	if typ0 eq typ then return, in	; If same as target just return.
 
	;---------------------------------------------------
	;  Convert using correct conversion routine
	;---------------------------------------------------
	case typ of		; Pick requested numeric data type.
1:	return, byte(in+0)
2:	return, fix(in)
3:	return, long(in)
4:	return, float(in)
5:	return, double(in)
6:	return, complex(in)
7:	return, string(in)
9:	return, dcomplex(in)
12:	return, uint(in)
13:	return, ulong(in)
14:	return, long64(in)
15:	return, ulong64(in)
else:				; Ignore invalid type codes.
	endcase
	return, in		; Just return original if not converted.
 
 
	end
