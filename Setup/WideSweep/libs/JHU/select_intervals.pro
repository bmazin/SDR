;-------------------------------------------------------------
;+
; NAME:
;       SELECT_INTERVALS
; PURPOSE:
;       Select all intervals within a given range.
; CATEGORY:
; CALLING SEQUENCE:
;       ind = select_intervals(rlo,rhi,ilo,ihi)
; INPUTS:
;       rlo = start time of selection range.      in
;       rhi = end time of selection range.        in
;       ilo = array of interval start times.      in
;       ihi = array of interval end times.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         /ANY  return an interval if any of it is in range (def).
;         /MOST return an interval if most of it is in range.
;         /ALL  return an interval only if all of it is in range.
; OUTPUTS:
;       ind = returned array of interval indices. out
;         If no intervals are within selection range ind=-1.
; COMMON BLOCKS:
; NOTES:
;       Notes: Values must be numeric.  May be used to select
;         which of a list of short time intervals fall within
;         a given time span.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Apr 3
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function select_intervals, rlo,rhi,ilo,ihi,$
	  any=any,most=most,all=all,help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Select all intervals within a given range.'
	  print,' ind = select_intervals(rlo,rhi,ilo,ihi)'
	  print,'   rlo = start time of selection range.      in'
	  print,'   rhi = end time of selection range.        in'
	  print,'   ilo = array of interval start times.      in'
	  print,'   ihi = array of interval end times.        in'
	  print,'   ind = returned array of interval indices. out'
	  print,'     If no intervals are within selection range ind=-1.'
	  print,' Keywords:'
	  print,'   /ANY  return an interval if any of it is in range (def).'
	  print,'   /MOST return an interval if most of it is in range.'
	  print,'   /ALL  return an interval only if all of it is in range.'
	  print,' Notes: Values must be numeric.  May be used to select'
	  print,'   which of a list of short time intervals fall within'
	  print,'   a given time span.'
	  return,''
	endif
 
	
 
	w = where((ihi ge rlo) and (ilo le rhi), c)
 
	;----------  No intervals are withing range  ------------
	if c eq 0 then return, -1
 
	;----------  Intervals completely inside range  ---------
	if keyword_set(all) then begin
	  slo = w(0)				; Index of first interval.
	  shi = w(c-1)				; Index of last interval.
	  if ilo(slo) lt rlo then slo=slo+1	; Use next interval.
	  if ihi(shi) gt rhi then shi=shi-1	; Use previous interval.
	  if shi lt slo then return, -1		; None.
	  return, makei(slo,shi,1)		; Return list.
	endif
 
	;----------  Intervals all or mostly within range  ------------
	if keyword_set(most) then begin
	  slo = w(0)				; Index of first interval.
	  shi = w(c-1)				; Index of last interval.
	  h1 = (ihi(slo)-ilo(slo))/2.		; Half of 1st interval.
	  h2 = (ihi(shi)-ilo(shi))/2.		; Half of last interval.
	  if ilo(slo)+h1 lt rlo then slo=slo+1	; Use next interval.
	  if ihi(shi)-h2 gt rhi then shi=shi-1	; Use previous interval.
	  if shi lt slo then return, -1		; None.
	  return, makei(slo,shi,1)		; Return list.
	endif
 
	;----------  Intervals with any part within range  -----------
	return, w
 
	end
