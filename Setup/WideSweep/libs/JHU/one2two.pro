;-------------------------------------------------------------
;+
; NAME:
;       ONE2TWO
; PURPOSE:
;       Convert from 1-d indices to 2-d indices.
; CATEGORY:
; CALLING SEQUENCE:
;       one2two, in, arr, ix, iy
; INPUTS:
;       in = 1-d indices (may be a scalar).  in
;       arr = array to use (for size only).  in
;         Alternatively, arr can be [nx, ny]
;         where nx and ny are the image sizes
;         in x and y (saves space).
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ix, iy = equivalent 2-d indices.     out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 25 May, 1986.
;       Johns Hopkins Applied Physics Lab.
;       R. Sterner, 19 Nov, 1989 --- converted to SUN.
;       R. Sterner, 9 Jun, 1993 --- Allowed [nx,ny] instead of ARR.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro one2two, in, arr, inx, iny, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Convert from 1-d indices to 2-d indices.'
	  print,' one2two, in, arr, ix, iy'
	  print,'   in = 1-d indices (may be a scalar).  in'
	  print,'   arr = array to use (for size only).  in'
	  print,'     Alternatively, arr can be [nx, ny]'
	  print,'     where nx and ny are the image sizes'
	  print,'     in x and y (saves space).'
	  print,'   ix, iy = equivalent 2-d indices.     out'
	  return
	endif
 
	s = size(arr)
	if n_elements(arr) eq 2 then s = [0,arr]
 
	inx = in mod s(1)
	iny = in/s(1)
 
	return
 
	end
