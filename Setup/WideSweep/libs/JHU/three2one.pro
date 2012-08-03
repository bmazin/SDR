;-------------------------------------------------------------
;+
; NAME:
;       THREE2ONE
; PURPOSE:
;       Convert from 3-d indices to 1-d indices.
; CATEGORY:
; CALLING SEQUENCE:
;       three2one, ix, iy, iz, arr, in
; INPUTS:
;       ix, iy, iz = 3-d indices.             in
;       arr = array to use (for size only).   in
;         Alternatively, arr can be [nx, ny, nz]
;         where nx, ny, and nz are the image sizes
;         in x, y, and z (saves space).
; KEYWORD PARAMETERS:
; OUTPUTS:
;       in = equivalent 1-d indices.          out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Oct 02
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro three2one, inx, iny, inz, arr, in, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Convert from 3-d indices to 1-d indices.'	
	  print,' three2one, ix, iy, iz, arr, in'
	  print,'   ix, iy, iz = 3-d indices.             in'
	  print,'   arr = array to use (for size only).   in'
	  print,'     Alternatively, arr can be [nx, ny, nz]'
	  print,'     where nx, ny, and nz are the image sizes'
	  print,'     in x, y, and z (saves space).'
	  print,'   in = equivalent 1-d indices.          out'
	  return
	endif
 
	s = size(arr)
	if n_elements(arr) eq 3 then s = [0,arr]
 
	in = long(.5+inz)*s(1)*s(2) + long(.5+iny)*s(1) + long(.5+inx)
	return
 
	end
