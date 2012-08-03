;-------------------------------------------------------------
;+
; NAME:
;       IMG_ROT
; PURPOSE:
;       Rotate a 2-D or 3-D image array by any angle.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_rot(in,ang,mag,x0,y0)
; INPUTS:
;       in = Input image.                       in
;       ang = rotation angle (deg)              in
;       mag = Mag factor (def=1.0)              in
;       x0,y0 = x,y subscript to rotate about.  in
;         Same as for IDL rot.
; KEYWORD PARAMETERS:
;       Keywords:
;         Same keywords as the IDL rot routine.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       out = Rotated image.                    out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays and rotates
;         correct image planes.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jun 03
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_rot, img, ang, mag, x0, y0, _extra=extra, $
	  error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Rotate a 2-D or 3-D image array by any angle.'
	  print,' out = img_rot(in,ang,mag,x0,y0)'
	  print,'   in = Input image.                       in'
	  print,'   ang = rotation angle (deg)              in'
	  print,'   mag = Mag factor (def=1.0)              in'
	  print,'   x0,y0 = x,y subscript to rotate about.  in'
	  print,'     Same as for IDL rot.'
	  print,'   out = Rotated image.                    out'
	  print,' Keywords:'
	  print,'   Same keywords as the IDL rot routine.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Note: deals with 2-D or 3-D image arrays and rotates'
	  print,'   correct image planes.'
	  return, ''
	endif
 
	err = 0
 
	img_shape, img, nx=nx, ny=ny, true=tr
 
	;-------  Defaults  -------------------------
	if n_elements(ang) eq 0 then ang=0.0
	if n_elements(mag) eq 0 then mag=1.0
	if n_elements(x0) eq 0 then x0=nx/2
	if n_elements(y0) eq 0 then y0=ny/2
 
	if (ang eq 0) and (mag eq 1) then return, img	; No op.
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_rot: given array must 2-D or 3-D.'
	  return, img
	endif
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then return, rot(img,ang,mag,x0,y0,_extra=extra)
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_rot: given array must have a dimension of 3.'
	  return, img
	endif
 
	case typ of
1:	begin
	  r = rot(reform(img(0,*,*)),ang,mag,x0,y0,_extra=extra)
	  g = rot(reform(img(1,*,*)),ang,mag,x0,y0,_extra=extra)
	  b = rot(reform(img(2,*,*)),ang,mag,x0,y0,_extra=extra)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(3,nx,ny,type=dtyp)
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  r = rot(reform(img(*,0,*)),ang,mag,x0,y0,_extra=extra)
	  g = rot(reform(img(*,1,*)),ang,mag,x0,y0,_extra=extra)
	  b = rot(reform(img(*,2,*)),ang,mag,x0,y0,_extra=extra)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(nx,3,ny,type=dtyp)
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  r = rot(reform(img(*,*,0)),ang,mag,x0,y0,_extra=extra)
	  g = rot(reform(img(*,*,1)),ang,mag,x0,y0,_extra=extra)
	  b = rot(reform(img(*,*,2)),ang,mag,x0,y0,_extra=extra)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(nx,ny,3,type=dtyp)
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
