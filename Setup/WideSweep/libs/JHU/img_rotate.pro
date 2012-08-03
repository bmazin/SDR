;-------------------------------------------------------------
;+
; NAME:
;       IMG_ROTATE
; PURPOSE:
;       Rotate a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_rotate(in,rot)
; INPUTS:
;       in = Input image.           in
;       rot = rotation value        in
;         Same as for IDL rotate.
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       out = Rotated image.        out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays and rotates
;         correct image planes.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Sep 21
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_rotate, img, rot, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Rotate a 2-D or 3-D image array.'
	  print,' out = img_rotate(in,rot)'
	  print,'   in = Input image.           in'
	  print,'   rot = rotation value        in'
	  print,'     Same as for IDL rotate.'
	  print,'   out = Rotated image.        out'
	  print,' Keywords:'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Note: deals with 2-D or 3-D image arrays and rotates'
	  print,'   correct image planes.'
	  return, ''
	endif
 
	err = 0
 
	if rot eq 0 then return, img	; No op.
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_rotate: given array must 2-D or 3-D.'
	  return, img
	endif
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then return, rotate(img,rot)
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_rotate: given array must have a dimension of 3.'
	  return, img
	endif
 
	case typ of
1:	begin
	  r = rotate(reform(img(0,*,*)),rot)
	  g = rotate(reform(img(1,*,*)),rot)
	  b = rotate(reform(img(2,*,*)),rot)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(3,nx,ny,type=dtyp)
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  r = rotate(reform(img(*,0,*)),rot)
	  g = rotate(reform(img(*,1,*)),rot)
	  b = rotate(reform(img(*,2,*)),rot)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(nx,3,ny,type=dtyp)
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  r = rotate(reform(img(*,*,0)),rot)
	  g = rotate(reform(img(*,*,1)),rot)
	  b = rotate(reform(img(*,*,2)),rot)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(nx,ny,3,type=dtyp)
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
