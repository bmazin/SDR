;-------------------------------------------------------------
;+
; NAME:
;       CHECKER
; PURPOSE:
;       Return a checker board pattern array of 0 and 1.
; CATEGORY:
; CALLING SEQUENCE:
;       checker, nx, ny, pat
; INPUTS:
;       nx, ny = array size in x and y.     in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       pat = resulting array.              out
; COMMON BLOCKS:
; NOTES:
;       Note: an example 4 x 4 array:
;            0 1 0 1
;            1 0 1 0
;            0 1 0 1
;            1 0 1 0
; MODIFICATION HISTORY:
;       R. Sterner, 30 Dec, 1989
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro checker, nx, ny, msk, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Return a checker board pattern array of 0 and 1.'
	  print,' checker, nx, ny, pat'
	  print,'   nx, ny = array size in x and y.     in'
	  print,'   pat = resulting array.              out'
	  print,' Note: an example 4 x 4 array:'
	  print,'      0 1 0 1'
	  print,'      1 0 1 0'
	  print,'      0 1 0 1'
	  print,'      1 0 1 0'
	  return
	endif
 
	nx2 = nx + 1 - (nx mod 2)
	msk = lindgen(nx2, ny) mod 2
	msk = msk(0:nx-1, *)
	return
	end
