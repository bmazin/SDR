;-------------------------------------------------------------
;+
; NAME:
;       STRINGFORM
; PURPOSE:
;       Format a string array (1024 not a limit).
; CATEGORY:
; CALLING SEQUENCE:
;       out = stringform(in)
; INPUTS:
;       in = input array.              in
; KEYWORD PARAMETERS:
;       Keywords:
;         FORMAT=fmt  fmt is a valid IDL format.
; OUTPUTS:
;       out = formatted string array.  out
; COMMON BLOCKS:
; NOTES:
;       Note: the IDL string function can only handle 1024
;         lines, it truncates the returned results to 1024
;         elements.  This function just feeds the string
;         function subsets of no more than 1024 elements.
;         Just drop stringform in place of string if needed.
;         Can use with or without FORMAT.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jul 20
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function stringform, in, format=fmt, help=hlp
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Format a string array (1024 not a limit).'
	  print,' out = stringform(in)'
	  print,'   in = input array.              in'
	  print,'   out = formatted string array.  out'
	  print,' Keywords:'
	  print,'   FORMAT=fmt  fmt is a valid IDL format.'
	  print,' Note: the IDL string function can only handle 1024'
	  print,'   lines, it truncates the returned results to 1024'
	  print,'   elements.  This function just feeds the string'
	  print,'   function subsets of no more than 1024 elements.'
	  print,'   Just drop stringform in place of string if needed.'
	  print,'   Can use with or without FORMAT.'
	  return, ''
	endif
 
	;------  No format, no problem  -------------
	if n_elements(fmt) eq 0 then return,string(in)
 
	;------  Format no more than 1024 elements  ---------
	lst = n_elements(in)-1
	if lst le 1023 then return,string(in,form=fmt)
 
	;------  Format more then 1024 elements  --------
	out = ['']
	for lo=0,lst,1024 do begin
	  hi = (lo+1023)<lst
	  out = [out, string(in(lo:hi),form=fmt)]
	endfor
	return, out(1:*)
 
	end
