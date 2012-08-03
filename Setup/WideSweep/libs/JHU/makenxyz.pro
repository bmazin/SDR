;-------------------------------------------------------------
;+
; NAME:
;       MAKENXYZ
; PURPOSE:
;       Make 3-d x,y and z coordinate arrays of specified dimensions.
; CATEGORY:
; CALLING SEQUENCE:
;       makenxyz,x1,x2,nx,y1,y2,ny,z1,z1,nz,xxx,yyy,zzz
; INPUTS:
;       x1 = min x coordinate in output rectangular array.  in
;       x2 = max x coordinate in output rectangular array.  in
;       nx = Number of steps in x.                          in
;       y1 = min y coordinate in output rectangular array.  in
;       y2 = max y coordinate in output rectangular array.  in
;       ny = Number of steps in y.                          in
;       z1 = min z coordinate in output rectangular array.  in
;       z2 = max z coordinate in output rectangular array.  in
;       nz = Number of steps in z.                          in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xxx,yyy,zzz = resulting 3-D arrays.                 out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Feb 22
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro makenxyz, x1,x2,nx, y1,y2,ny, z1,z2,nz, xxx, yyy, zzz, help=hlp
 
	if (n_params(0) lt 12) or keyword_set(hlp) then begin
	  print,' Make 3-d x,y and z coordinate arrays of specified dimensions.'
	  print,' makenxyz,x1,x2,nx,y1,y2,ny,z1,z1,nz,xxx,yyy,zzz'
	  print,'   x1 = min x coordinate in output rectangular array.  in'
	  print,'   x2 = max x coordinate in output rectangular array.  in'
	  print,'   nx = Number of steps in x.                          in'
	  print,'   y1 = min y coordinate in output rectangular array.  in'
	  print,'   y2 = max y coordinate in output rectangular array.  in'
	  prinT,'   ny = Number of steps in y.                          in'
	  print,'   z1 = min z coordinate in output rectangular array.  in'
	  print,'   z2 = max z coordinate in output rectangular array.  in'
	  prinT,'   nz = Number of steps in z.                          in'
	  prinT,'   xxx,yyy,zzz = resulting 3-D arrays.                 out'
	  return
	endif
 
	x = maken(x1, x2, nx)			; Generate X array.
	xxx = rebin(x,nx,ny,nz)			; Form 3-D array.
 
	y = reform(maken(y1,y2,ny),1,ny,1)	; Generate Y array.
	yyy = rebin(y,nx,ny,nz)			; Form 3-D array.
 
	z = reform(maken(z1,z2,nz),1,1,nz)	; Generate Z array.
	zzz = rebin(z,nx,ny,nz)			; Form 3-D array.
 
	return
 
	end
