;-------------------------------------------------------------
;+
; NAME:
;       STR_CLIPTRAIL0
; PURPOSE:
;       Clip trailing zeros equally for given array of numbers.
; CATEGORY:
; CALLING SEQUENCE:
;       out = str_cliptrail0(in)
; INPUTS:
;       in = Input array of numbers (floats).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         NDEC=nd  Returned number of decimal places needed.
;           nd is 0 if all integers.  nd0 is -1 if no good
;           solution could be found.
; OUTPUTS:
;       out = returned string array.           out
; COMMON BLOCKS:
; NOTES:
;       Note: clips each element to same number of decimal places
;         determined by max needed.  Only works for a limited
;         number of decimal places.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jan 14
;       R. Sterner, 2002 Jan 24 --- Fixed for integers and #s like 1.025.
;       R. Sterner, 2003 Mar 18 --- Complete rewrite.
;       R. Sterner, 2003 Sep 12 --- Added comments.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function str_cliptrail0, a, ndec=nd0, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Clip trailing zeros equally for given array of numbers.'
	  print,' out = str_cliptrail0(in)'
	  print,'   in = Input array of numbers (floats).  in'
	  print,'   out = returned string array.           out'
	  print,' Keywords:'
	  print,'   NDEC=nd  Returned number of decimal places needed.'
	  print,'     nd is 0 if all integers.  nd0 is -1 if no good'
	  print,'     solution could be found.'
	  print,' Note: clips each element to same number of decimal places'
	  print,'   determined by max needed.  Only works for a limited'
	  print,'   number of decimal places.'
	  return,''
	endif
 
	for i=1,9 do begin			; Look at decimal places 1 to 9.
	  fmt = '(F25.'+strtrim(i,2)+')'	; Format with i decimal places.
	  s = string(a,form=fmt)		; Format value.
	  m = max(strmid(s,24,1)+0)		; Pick off dec place i, get max.
	  if m eq 0 then begin			; All 0s.
	    if i eq 1 then begin		; Special case, return integer.
	      nd0 = 0
	      return,strtrim(round(a),2)
	    endif
	    nd0 = i-1				;Trim numbers to previous place.
	    fmt = '(F25.'+strtrim(nd0,2)+')'
	    return,strtrim(string(a,form=fmt),2)
	  endif
	endfor
 
	nd0 = -1
	print,' Error in str_cliptrail0: could not find a good solution.'
	return,strtrim(s,2)
 
	end
