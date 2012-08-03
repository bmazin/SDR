;-------------------------------------------------------------
;+
; NAME:
;       SYMASYM
; PURPOSE:
;       Resolve an array into symmetric & anti-symmetric components.
; CATEGORY:
; CALLING SEQUENCE:
;       symasym, in, sym, asym
; INPUTS:
;       in = input array (1-d or 2-d).          in
; KEYWORD PARAMETERS:
;       Keywords:
;         /X  means do symmetry/antisymmetry in X dimension.
;         /Y  means do symmetry/antisymmetry in Y dimension.
;            These keywords only apply to 2-d data.
; OUTPUTS:
;       sym = symmetric component of in.        out
;       asym = anti-symmetric component of in.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: A set of radially sym/asym components for a
;         2-d array may be obtained as follows:
;         symasym,z,sx,sy,/x
;         symasym,z,sy,sy,/y
;         sym  = (sx+sy)-(ax+ay)
;         asym = (sx-sy)-(ax-ay)
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Jun 21
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro symasym, in, sym, asym, x=x, y=y, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Resolve an array into symmetric & anti-symmetric components.'
	  print,' symasym, in, sym, asym'
	  print,'   in = input array (1-d or 2-d).          in'
	  print,'   sym = symmetric component of in.        out'
	  print,'   asym = anti-symmetric component of in.  out'
	  print,' Keywords:'
	  print,'   /X  means do symmetry/antisymmetry in X dimension.'
	  print,'   /Y  means do symmetry/antisymmetry in Y dimension.'
	  print,'      These keywords only apply to 2-d data.'
	  print,' Notes: A set of radially sym/asym components for a'
	  print,'   2-d array may be obtained as follows:'
	  print,'   symasym,z,sx,sy,/x'
	  print,'   symasym,z,sy,sy,/y'
	  print,'   sym  = (sx+sy)-(ax+ay)'
	  print,'   asym = (sx-sy)-(ax-ay)'
	  return
	endif
 
	sz = size(in)
	if keyword_set(x) then goto, resx
	if keyword_set(y) then goto, resy
 
	inr = reverse(in)	; Reverse.
	sym  = (in + inr)/2	; Symmetric component.
	asym = (in - inr)/2	; Anti-symmetric component.
	return
 
resx:	if sz(0) ne 2 then begin
	  print,' Error in symasym: must have a 2-d array to use /X.'
	  return
	endif
	inr = reverse(in,1)	; Reverse in X.
	sym  = (in + inr)/2	; Symmetric component.
	asym = (in - inr)/2	; Anti-symmetric component.
	return
 
resy:	if sz(0) ne 2 then begin
	  print,' Error in symasym: must have a 2-d array to use /Y.'
	  return
	endif
	inr = reverse(in,2)	; Reverse in Y.
	sym  = (in + inr)/2	; Symmetric component.
	asym = (in - inr)/2	; Anti-symmetric component.
	return
 
	end
