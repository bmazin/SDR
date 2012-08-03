;-------------------------------------------------------------
;+
; NAME:
;       MAKEZ
; PURPOSE:
;       Make simulated 2-d data.  Useful for software development.
; CATEGORY:
; CALLING SEQUENCE:
;       data = makez( nx, ny, w)
; INPUTS:
;       nx, ny = size of 2-d array to make.                   in
;       w = smoothing window size (def = 5% of sqrt(nx*ny)).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /PERIODIC   forces data to match at ends.  Will not work
;           for smoothing windows much more than about 30% of n.
;         SEED=s      Set random seed for repeatable results.
;         LASTSEED=s  returns last random seed used.
; OUTPUTS:
;       data = resulting data array (def = undef).            out
; COMMON BLOCKS:
;       makez_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  29 Nov, 1986.
;       R. Sterner,  1994 Feb 22 --- Rewrote from new makey.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function makez, nx, ny, w, seed=seed0, lastseed=lseed, $
	  periodic=per, help=hlp
 
        common makez_com, seed
	;-----------------------------------------------------------------
	;   Must store seed in common otherwise it is undefined
	;   on entry each time and gets set by the clock but only
	;   to a one second resolution (same random data for a whole sec).
	;-----------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Make simulated 2-d data.  Useful for software development.' 
	  print,' data = makez( nx, ny, w)' 
	  print,'   nx, ny = size of 2-d array to make.                   in'
	  print,'   w = smoothing window size (def = 5% of sqrt(nx*ny)).  in'
	  print,'   data = resulting data array (def = undef).            out' 
	  print,' Keywords:'
	  print,'   /PERIODIC   forces data to match at ends.  Will not work'
	  print,'     for smoothing windows much more than about 30% of n.'
	  print,'   SEED=s      Set random seed for repeatable results.'
	  print,'   LASTSEED=s  returns last random seed used.'
	  return, -1
	endif
 
	;-----  Return last random seed or set new  -----
	if n_elements(seed) ne 0 then lseed=seed else lseed=-1
	if n_elements(nx) eq 0 then return,0			; That was all.
        if n_elements(seed0) ne 0 then seed = seed0
 
	;-----  Default smoothing window size  ---------
	if n_elements(w) eq 0 then w = .05*sqrt(long(nx)*ny) > 5
 
	;-----  Compute size of edge effect  --------
	lo = fix(w)/2 + fix(w)	; First index after edge effects.
	ntx = nx + 2*lo		; X size extended to include edge effects.
	nty = ny + 2*lo		; Y size extended to include edge effects.
	hix = ntx - 1 - lo	; Last X index before edge effects.
	hiy = nty - 1 - lo	; Last Y index before edge effects.
 
	;-----  Make data  ---------------------------
	r = randomu(seed, ntx, nty)	; Random starting data.
	seed0 = seed			; Return new seed.
	if keyword_set(per) then begin	; Want periodic data.
	  r(ntx-2*lo,0) = r(0:2*lo-1,*)	; Copy part of random data.
	  r(0,nty-2*lo) = r(*,0:2*lo-1)
	endif
	s = smooth2(r,w)		; Smooth.
	s = s(lo:hix, lo:hiy)		; Trim edge effects.
	s = s - min(s)			; Normalize.
	s = s/max(s)
 
	lseed = seed			; Return last seed.
 
	return, s
	end
