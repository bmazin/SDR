;-------------------------------------------------------------
;+
; NAME:
;       STDDEV2
; PURPOSE:
;       Standard deviation of an array, optionally over a dimension.
; CATEGORY:
; CALLING SEQUENCE:
;       sd = stddev2(x, [dim])
; INPUTS:
;       x = array to process.                in
;       dim = optional dimension (def=all).  in
;         dim=1 for x, 2 for y, ... 0 for all.
; KEYWORD PARAMETERS:
;       Keywords:
;         /DOUBLE use double precision.
;         /NAN treat NaN as missing data.
;         MEAN=mn returned means over given dimension.
;         EXP_MEAN=mn_ex returned expanded means over given dimension.
;         NUMBER=n returned number of samples along dimension.
; OUTPUTS:
;       sd = returned standard deviation.    out
; COMMON BLOCKS:
; NOTES:
;       Note: If a dimension is specified then the array is
;       collapsed in that dimension.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Feb 12
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function stddev2, x, dim, double=double, nan=nan, $
	  mean=mn, exp_mean=mn_ex, number=n, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Standard deviation of an array, optionally over a dimension.'
	  print,' sd = stddev2(x, [dim])'
	  print,'   x = array to process.                in'
	  print,'   dim = optional dimension (def=all).  in'
	  print,'     dim=1 for x, 2 for y, ... 0 for all.'
	  print,'   sd = returned standard deviation.    out'
	  print,' Keywords:'
 	  print,'   /DOUBLE use double precision.'
	  print,'   /NAN treat NaN as missing data.'
	  print,'   MEAN=mn returned means over given dimension.'
	  print,'   EXP_MEAN=mn_ex returned expanded means over given dimension.'
	  print,'   NUMBER=n returned number of samples along dimension.'
	  print,' Note: If a dimension is specified then the array is'
	  print,' collapsed in that dimension.'
	  return,''
	endif
 
	if n_elements(dim) eq 0 then dim=0
 
	;----------------------------------------------------------
	;  Total Standard Deviation
	;----------------------------------------------------------
	if dim le 0 then begin
	  n = n_elements(x)
	  mn = mean(x,double=double,nan=nan)
	  mn_ex = mn
	  sd = sqrt(total((x-mn)^2,double=double,nan=nan)/(n-1))
	  return, sd
	endif
 
	;----------------------------------------------------------
	;  Standard Deviation over a dimension
	;
	;  The dimension of mn is 1 less than the dimension of x.
	;  It must be expanded to match shape of x to take diff.
	;----------------------------------------------------------
	d = size(x,/dimensions)		; Array with dimensions of x.
	if dim gt n_elements(d) then begin
	  print,' Error in stddev2: given array dimension out of range.'
	  return,-1.
	endif
	d2=d & d2(dim-1)=1		; Use d2 to reshape mean.
	n = d(dim-1)			; Number of samples in dimension dim.
	mn = mean2(x,dim,double=double,nan=nan)	; Mean over dimension dim.
	mn_ex = rebin(reform(mn,d2),d)	; Mean expanded to match shape of x.
	sd = sqrt(total((x-mn_ex)^2,dim,double=double,nan=nan)/(n-1))  
 
	return, sd
 
	end
