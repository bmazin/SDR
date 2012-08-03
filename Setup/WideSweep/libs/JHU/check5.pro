;-------------------------------------------------------------
;+
; NAME:
;       CHECK5
; PURPOSE:
;       Check if running IDL version 5 or greater.
; CATEGORY:
; CALLING SEQUENCE:
;       flag = check5()
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       flag = 0 if false, 1 if true.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: Useful to check if the current IDL version
;       supports features from version 5 or greater.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Jan 23
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function check5, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Check if running IDL version 5 or greater.'
	  print,' flag = check5()'
	  print,'   flag = 0 if false, 1 if true.   out'
	  print,' Notes: Useful to check if the current IDL version'
	  print,' supports features from version 5 or greater.'
	  return,''
	endif
 
	return, (!version.release+0) ge 5
	end
