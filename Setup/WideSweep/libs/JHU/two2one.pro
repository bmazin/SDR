;-------------------------------------------------------------
;+
; NAME:
;       TWO2ONE
; PURPOSE:
;       Convert from 2-d indices to 1-d indices.
; CATEGORY:
; CALLING SEQUENCE:
;       two2one, ix, iy, arr, in
; INPUTS:
;       ix, iy = 2-d indices.                 in
;       arr = array to use (for size only).   in
;         Alternatively, arr can be [nx, ny]
;         where nx and ny are the image sizes
;         in x and y (saves space).
; KEYWORD PARAMETERS:
; OUTPUTS:
;       in = equivalent 1-d indices.          out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 7 May, 1986.
;       Johns Hopkins Applied Physics Lab.
;       R. Sterner, 19 Nov, 1989 --- converted to SUN
;       R. Sterner, 15 Feb, 1993 --- fixed a bug in the [nx,ny] case.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro two2one, inx, iny, arr, in, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Convert from 2-d indices to 1-d indices.'	
	  print,' two2one, ix, iy, arr, in'
	  print,'   ix, iy = 2-d indices.                 in'
	  print,'   arr = array to use (for size only).   in'
	  print,'     Alternatively, arr can be [nx, ny]'
	  print,'     where nx and ny are the image sizes'
	  print,'     in x and y (saves space).'
	  print,'   in = equivalent 1-d indices.          out'
	  return
	endif
 
	s = size(arr)
	if n_elements(arr) eq 2 then s = [0,arr]
 
	in = long(.5+iny)*s(1) + long(.5+inx)
	return
 
	end
