;-------------------------------------------------------------
;+
; NAME:
;       CONGRID2
; PURPOSE:
;       Alternate (and limited) congrid using interpolate.
; CATEGORY:
; CALLING SEQUENCE:
;       z2 = congrid2(z,mx,my)
; INPUTS:
;       z = input 2-d array.                   in
;       mx, my = requested output array size.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /INTERPOLATE means do bilinear interpolation.
;           Default is nearest neighbor.
;         /CENTERED means assume pixels centered.  This means
;           the pixel at (0,0) is clipped to 1/4 size.
;           Default is that pixel start (not center) is at index.
; OUTPUTS:
;       z2 = resulting array.                  out
; COMMON BLOCKS:
; NOTES:
;       Notes: tries to correct problems in congrid.  Result may
;         look odd due to extrapolation.  For example, using
;         /CENT and /INTERP gives results with magnified pixels
;         not all the same size.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Dec 2
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function congrid2, z, mx, my, centered=centered, $
	  interpolate=interp, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Alternate (and limited) congrid using interpolate.'
	  print,' z2 = congrid2(z,mx,my)'
	  print,'   z = input 2-d array.                   in'
	  print,'   mx, my = requested output array size.  in'
	  print,'   z2 = resulting array.                  out'
	  print,' Keywords:'
	  print,'   /INTERPOLATE means do bilinear interpolation.'
	  print,'     Default is nearest neighbor.'
 	  print,'   /CENTERED means assume pixels centered.  This means'
	  print,'     the pixel at (0,0) is clipped to 1/4 size.'
	  print,'     Default is that pixel start (not center) is at index.'
	  print,' Notes: tries to correct problems in congrid.  Result may'
	  print,'   look odd due to extrapolation.  For example, using'
	  print,'   /CENT and /INTERP gives results with magnified pixels'
	  print,'   not all the same size.'
	  return,''
	endif
 
	sz=size(z) & nx=sz(1) & ny=sz(2)
	cflag = keyword_set(centered)	; 0=start, 1=centered.
	iflag = keyword_set(interp)	; 0=NN,    1=BIL
 
	;-----  Pixel starts at index, NN  -----------
	if (cflag eq 0) and (iflag eq 0) then begin
	  ix = long((maken(0,nx,mx+1))(0:mx-1))
	  iy = long((maken(0,ny,my+1))(0:my-1))
	endif
 
	;-----  Pixel starts at index, BIL  -----------
	if (cflag eq 0) and (iflag eq 1) then begin
	  ix = (maken(0,nx,mx+1))(0:mx-1)-.5
	  iy = (maken(0,ny,my+1))(0:my-1)-.5
	endif
 
	;-----  Pixel centered at index, NN  -----------
	if (cflag eq 1) and (iflag eq 0) then begin
	  ix = long((maken(0,nx,mx+1))(0:mx-1)+.5)
	  iy = long((maken(0,ny,my+1))(0:my-1)+.5)
	endif
 
	;-----  Pixel centered at index, BIL  ---------
	if (cflag eq 1) and (iflag eq 1) then begin
	  ix = (maken(0,nx,mx+1))(0:mx-1)
	  iy = (maken(0,ny,my+1))(0:my-1)
	endif
 
	z2 = interpolate(z,ix,iy,/grid)
 
	return,z2
 
	end
