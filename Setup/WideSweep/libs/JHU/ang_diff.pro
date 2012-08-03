;-------------------------------------------------------------
;+
; NAME:
;       ANG_DIFF
; PURPOSE:
;       Return difference between two angles in degress.
; CATEGORY:
; CALLING SEQUENCE:
;       d = ang_diff(a1,a2)
; INPUTS:
;       a1, a2 = Input angles in degrees.    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       d = returned difference in degress.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: deals with 0/360 deg discontinuety.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Nov 07
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ang_diff, a1, a2, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return difference between two angles in degress.'
	  print,' d = ang_diff(a1,a2)'
	  print,'   a1, a2 = Input angles in degrees.    in'
	  print,'   d = returned difference in degress.  out'
	  print,' Notes: deals with 0/360 deg discontinuety.'
	  return,''
	endif
 
	f = fixang([a1,a2])
	return,f[1]-f[0]
 
	end
