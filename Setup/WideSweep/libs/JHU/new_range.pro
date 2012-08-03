;-------------------------------------------------------------
;+
; NAME:
;       NEW_RANGE
; PURPOSE:
;       Compute a new range array from old.
; CATEGORY:
; CALLING SEQUENCE:
;       r2 = new_range(r,mag,[center])
; INPUTS:
;       r = current range: [lo,hi].     in
;       mag = magnification factor.     in
;       center = optional new center.   in
;         Default = (lo+hi)/2.
; KEYWORD PARAMETERS:
;       Keywords:
;         LIMIT=r0  Max allowed range.
;           Default is r when mag > 1, no default for mag < 1.
; OUTPUTS:
;       r2 = new range: [lo2,hi2].        out
; COMMON BLOCKS:
; NOTES:
;       Notes: Useful for changing plot ranges, like xrange or
;       yrange.  mag may be < 1 to zoom out (new range is bigger).
;       If given, center will be centered in new range if
;       possible.  New range will be contained within
;       current range when mag > 1.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Mar 14
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function new_range, r, mag, center, limit=r0, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Compute a new range array from old.'
	  print,' r2 = new_range(r,mag,[center])'
	  print,'   r = current range: [lo,hi].     in'
	  print,'   mag = magnification factor.     in'
	  print,'   center = optional new center.   in'
	  print,'     Default = (lo+hi)/2.'
	  print,' r2 = new range: [lo2,hi2].        out'
	  print,' Keywords:'
	  print,'   LIMIT=r0  Max allowed range.'
	  print,'     Default is r when mag > 1, no default for mag < 1.'
	  print,' Notes: Useful for changing plot ranges, like xrange or'
	  print,' yrange.  mag may be < 1 to zoom out (new range is bigger).'
	  print,' If given, center will be centered in new range if'
	  print,' possible.  New range will be contained within'
	  print,' current range when mag > 1.'
	  return,''
	endif
 
	;-----  Set limits  ------------------------------
	if mag lt 1 then if n_elements(r0) eq 0 then r0=r
 
	;-----  Target value  ----------------------------
	if n_elements(center) eq 0 then center=midv(r)
 
	;-----  Compute new range  -----------------------
	dr = (r(1)-r(0))/float(mag)	; New range.
	dr2 = dr/2.			; New half-range.
	lo = center - dr2
	hi = center + dr2
 
	;-----  Keep in bounds  --------------------------
	if n_elements(r0) eq 0 then begin
	  return, [lo,hi]		; No bounds.
	endif
 
	if hi gt r0(1) then begin	; Top too high.
	  hi = hi<r0(1)			; Limit hi.
	  lo = (hi-dr)>r0(0)		; Offset to lo and limit.
	endif
 
	if lo lt r0(0) then begin	; Bottom too low.
	  lo = lo>r0(0)			; Limit lo.
	  hi = (lo+dr)<r0(1)		; Offset to hi and limit.
	endif
 
	return, [lo,hi]			; Return new range.
 
	end
