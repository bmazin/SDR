;-------------------------------------------------------------
;+
; NAME:
;       INT_LOW
; PURPOSE:
;       Drop an integer data type to the lowest precision.
; CATEGORY:
; CALLING SEQUENCE:
;       out = int_low(in)
; INPUTS:
;       in = Input value or array (must be integer).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         TYPE=v Value to use to determine precision.
;           Will set the output precision to the lowest
;           possible that will hold max(v).  If TYPE=v is
;           not given then max(in) is used.
; OUTPUTS:
;       out = Returned value or array.                out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Jun 30
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function int_low, in, type=v, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Drop an integer data type to the lowest precision.'
	  print,' out = int_low(in)'
	  print,'   in = Input value or array (must be integer).  in'
	  print,'   out = Returned value or array.                out'
	  print,' Keywords:'
	  print,'   TYPE=v Value to use to determine precision.'
	  print,'     Will set the output precision to the lowest'
	  print,'     possible that will hold max(v).  If TYPE=v is'
	  print,'     not given then max(in) is used.'
	  return,''
	endif
 
	if n_elements(v) ne 0 then mx=max(v) else mx=max(in)
 
	if mx lt 0 then mx=abs(mx)
 
	if mx le 255                  then return, byte(in)
	if mx le 32767                then return, fix(in)
	if mx le 65535                then return, uint(in)
	if mx le 2147483647           then return, long(in)
	if mx le 4294967295           then return, ulong(in)
	if mx le 9223372036854775807  then return, long64(in)
	if mx le 18446744073709551615 then return, ulong64(in)
 
	end
