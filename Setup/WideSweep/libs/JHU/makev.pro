;-------------------------------------------------------------
;+
; NAME:
;       MAKEV
; PURPOSE:
;       Make simulated 3-d data.  Useful for software development.
; CATEGORY:
; CALLING SEQUENCE:
;       data = makev( nx, ny, nz, [w, m, sd, seed])
; INPUTS:
;       nx, ny, nz = size of 3-d array to make.                 in
;       w = smoothing window size (def=5% of (nx*ny*nz)^(1/3.)) in
;       m = mean (def = 100).                                   in
;       sd = standard deviation (def = 40% of mean).            in
;       seed = random number seed.                              in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       data = resulting data array (def = undef).              out
; COMMON BLOCKS:
;       makev_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  2 Jun, 1993.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function makev, nx, ny, nz, w, m, sd, seed0, help=hlp
 
	common makev_com, seed
 
	np = n_params(0)
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make simulated 3-d data.  Useful for software development.' 
	  print,' data = makev( nx, ny, nz, [w, m, sd, seed])' 
	  print,'   nx, ny, nz = size of 3-d array to make.                 in'
	  print,'   w = smoothing window size (def=5% of (nx*ny*nz)^(1/3.)) in'
	  print,'   m = mean (def = 100).                                   in'
	  print,'   sd = standard deviation (def = 40% of mean).            in'
	  print,'   seed = random number seed.                              in'
	  print,'   data = resulting data array (def = undef).              out'
	  return, -1
	endif
 
	if n_elements(seed0) ne 0 then seed = seed0
	if np lt 4 then w = (.05*(long(nx)*ny*nz)^(1./3.)) > 1
	if np lt 5 then m = 100
	if np lt 6 then sd = .40*m > 1
 
	w = w>4
	x = randomu( seed, nx+w+w, ny+w+w, nz+w+w)
	seed0 = seed
	x = smooth2( x, w)
	x = x(w:(nx+w-1), w:(ny+w-1), w:(nz+w-1))
	x = x - mean(x)
	x = x*sd/sdev(x) + m
	return, x
	end
