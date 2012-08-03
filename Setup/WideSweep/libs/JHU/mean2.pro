;-------------------------------------------------------------
;+
; NAME:
;       MEAN2
; PURPOSE:
;       Do mean over speicifed dimension.
; CATEGORY:
; CALLING SEQUENCE:
;       mn = mean2(a,[dim])
; INPUTS:
;       a = Input array (may be multidimensional.  in
;       dim = optional dimension to collapse.      in
;         dim must start at 1 for x, 2 for y, ...
; KEYWORD PARAMETERS:
;       Keywords:
;         /DOUBLE use double precision.
;         /NAN treat NaN as missing data.
; OUTPUTS:
;       mn = returned mean (may be an array).      out
; COMMON BLOCKS:
; NOTES:
;       Note: if dim not given then the overall mean
;         is returned.  Works like the total function
;         but for mean.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jan 23
;       R. Sterner, 2003 Feb 13 --- Added /DOUBLE and /NAN.
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function mean2, a, dim, double=double, nan=nan, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Do mean over speicifed dimension.'
	  print,' mn = mean2(a,[dim])'
	  print,'   a = Input array (may be multidimensional.  in'
	  print,'   dim = optional dimension to collapse.      in'
	  print,'     dim must start at 1 for x, 2 for y, ...'
	  print,'   mn = returned mean (may be an array).      out'
	  print,' Keywords:'
	  print,'   /DOUBLE use double precision.'
	  print,'   /NAN treat NaN as missing data.'
	  print,' Note: if dim not given then the overall mean'
	  print,'   is returned.  Works like the total function'
	  print,'   but for mean.'
	  return,''
	endif
 
	if n_elements(dim) eq 0 then return, mean(a)
	if dim eq 0 then return, mean(a)
 
	sz = size(a)
	if dim gt sz(0) then begin
	  print,' Error in mean2: given array dimension out of range.'
	  return,''
	endif
 
	n = sz(dim)	
	
	return, total(a,dim,double=double,nan=nan)/n
 
	end
