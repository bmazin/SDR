;-------------------------------------------------------------
;+
; NAME:
;       MAKEY
; PURPOSE:
;       Make simulated data.  Useful for software development.
; CATEGORY:
; CALLING SEQUENCE:
;       data = makey( n, w)
; INPUTS:
;       n = number of data values to make.                in
;       w = smoothing window size (def = 5% of n).        in
; KEYWORD PARAMETERS:
;       Keywords:
;         /PERIODIC   forces data to match at ends.  Will not work
;           for smoothing windows much more than about 30% of n.
;         SEED=s      Set random seed for repeatable results.
;         LASTSEED=s  returns last random seed used.
; OUTPUTS:
;       data = resulting data array (def = undef).        out
; COMMON BLOCKS:
;       makey_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  2 Apr, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 21 Nov, 1988 --- added SEED.
;       R. Sterner, 2 Feb, 1990 --- added periodic.
;       R. Sterner, 29 Jan, 1991 --- renamed from makedata.pro.
;       R. Sterner, 24 Sep, 1992 --- Added /NORMALIZE.
;       R. Sterner, 1994 Feb 22 --- Greatly simplified.  Always normalize.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	function makey, n, w, seed=seed0, lastseed=lseed, $
	  periodic=per, help=hlp
 
        common makey_com, seed
	;-----------------------------------------------------------------
	;   Must store seed in common otherwise it is undefined
	;   on entry each time and gets set by the clock but only
	;   to a one second resolution (same random data for a whole sec).
	;-----------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Make simulated data.  Useful for software development.' 
	  print,' data = makey( n, w)' 
	  print,'   n = number of data values to make.                in'
	  print,'   w = smoothing window size (def = 5% of n).        in'
	  print,'   data = resulting data array (def = undef).        out' 
	  print,' Keywords:'
	  print,'   /PERIODIC   forces data to match at ends.  Will not work'
	  print,'     for smoothing windows much more than about 30% of n.'
	  print,'   SEED=s      Set random seed for repeatable results.'
	  print,'   LASTSEED=s  returns last random seed used.'
	  return, -1
	endif
 
	;-----  Return last random seed or set new  -----
	if n_elements(seed) ne 0 then lseed=seed else lseed=-1
	if n_elements(n) eq 0 then return,0	; That was all.
        if n_elements(seed0) ne 0 then seed = seed0
 
	;-----  Default smoothing window size  ---------
	if n_elements(w) eq 0 then w = .05*n > 5
 
	;-----  Compute size of edge effect  --------
	lo = long(w)/2L + long(w)	; First index after edge effects.
	nt = n + 2*lo			; Size extended to include edge effects.
	hi = nt - 1 - lo		; Last index before edge effects.
 
	;-----  Make data  ---------------------------
	r = randomu(seed, nt)		; Random starting data.
	seed0 = seed			; Return new seed.
	if keyword_set(per) then begin	; Want periodic data.
	  r(nt-2*lo) = r(0:2*lo-1)	; Copy part of random data.
	endif
	s = smooth2(r,w)		; Smooth.
	s = s(lo:hi)			; Trim edge effects.
	s = s - min(s)			; Normalize.
	s = s/max(s)
 
	lseed = seed			; Return last seed.
 
	return, s
	end
