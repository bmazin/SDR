;-------------------------------------------------------------
;+
; NAME:
;       ONE2THREE
; PURPOSE:
;       Convert from 1-d indices to 3-d indices.
; CATEGORY:
; CALLING SEQUENCE:
;       one2three, in, arr, ix, iy, iz
; INPUTS:
;       in = 1-d indices (may be a scalar).   in
;       arr = array to use (for size only).   in
;         Alternatively, arr can be [nx, ny, nz]
;         where nx, ny, and nz are the array sizes
;         in x, y, and z (saves space).
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ix, iy, iz = equivalent 3-d indices.  out
; COMMON BLOCKS:
; NOTES:
;       Note: works for 2-d arrays also, just returns iz=0.
;       May give [nx,ny] instead of arr for the 2-d case.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Oct 01
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro one2three, in, arr, inx, iny, inz, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Convert from 1-d indices to 3-d indices.'
	  print,' one2three, in, arr, ix, iy, iz'
	  print,'   in = 1-d indices (may be a scalar).   in'
	  print,'   arr = array to use (for size only).   in'
	  print,'     Alternatively, arr can be [nx, ny, nz]'
	  print,'     where nx, ny, and nz are the array sizes'
	  print,'     in x, y, and z (saves space).'
	  print,'   ix, iy, iz = equivalent 3-d indices.  out'
	  print,' Note: works for 2-d arrays also, just returns iz=0.'
	  print,' May give [nx,ny] instead of arr for the 2-d case.'
	  return
	endif
 
	s = size(arr)
	if n_elements(arr) le 3 then s = [0,arr,1]
 
	nxny = s(1)*s(2)
	rem = in mod nxny
 
	inx = rem mod s(1)
	iny = rem/s(1)
	inz = in/nxny
 
	if n_elements(inx) eq 1 then begin
	  inx = inx(0)
	  iny = iny(0)
	  inz = inz(0)
	endif
 
	return
 
	end
