;-------------------------------------------------------------
;+
; NAME:
;       NRUNS
; PURPOSE:
;       Gives # of runs of consecutive integers in given array.'
; CATEGORY:
; CALLING SEQUENCE:
;       n = nruns(w)
; INPUTS:
;       w = output from where to process.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         START=strt  Start indices for all runs.
;         LENGTH=len  Lengths of all runs.
; OUTPUTS:
;       n = number of runs in w.                   out
; COMMON BLOCKS:
; NOTES:
;       Note: see getrun.
; MODIFICATION HISTORY:
;       R. Sterner, 1990
;       R. Sterner, 12 Aug, 1993 --- minor simplification.
;       R. Sterner, 19 Mar 1996 --- Returned all run lengths and starts.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function nruns, w, start=loc, length=len, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
 	  print," Gives # of runs of consecutive integers in given array.'
	  print,' n = nruns(w)'
	  print,'   w = output from where to process.          in'
	  print,'   n = number of runs in w.                   out'
	  print,' Keywords:'
	  print,'   START=strt  Start indices for all runs.'
	  print,'   LENGTH=len  Lengths of all runs.'
	  print,' Note: see getrun.'
	  return, -1
	endif
 
	d = w-shift(w,1)			; Distance to next point.
	loc = where(d ne 1)			; Distance ne 1 = run starts.
	loc2 = [loc,n_elements(w)]		; Where next run would start.
	len = loc2(1:*) - loc2			; Compute run lengths.
	nwds = n_elements(loc)			; Number of runs.
 
	loc = w(loc)				; Original start indices.
 
	return, nwds
 
	end
