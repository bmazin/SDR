;-------------------------------------------------------------
;+
; NAME:
;       NGROUPS
; PURPOSE:
;       Gives # of groupss of identical elements in given array.'
; CATEGORY:
; CALLING SEQUENCE:
;       n = nruns(a)
; INPUTS:
;       a = array to process.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         START=strt  Start indices for all groups.
;         LENGTH=len  Lengths of all groups.
; OUTPUTS:
;       n = number of groups in a.     out
; COMMON BLOCKS:
; NOTES:
;       Note: see getgroup.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Aug 02
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ngroups, a, start=loc, length=len, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
 	  print," Gives # of groupss of identical elements in given array.'
	  print,' n = nruns(a)'
	  print,'   a = array to process.          in'
	  print,'   n = number of groups in a.     out'
	  print,' Keywords:'
	  print,'   START=strt  Start indices for all groups.'
	  print,'   LENGTH=len  Lengths of all groups.'
	  print,' Note: see getgroup.'
	  return, -1
	endif
 
        d = a eq shift(a,1)                     ; Look for changes.
	d(0) = 0				; Force 0 to start.
	loc = where(d ne 1)			; Elements NE at group starts.
	loc2 = [loc,n_elements(a)]		; Where next group would start.
	len = loc2(1:*) - loc2			; Compute group lengths.
	nwds = n_elements(loc)			; Number of groups.
 
	return, nwds
 
	end
