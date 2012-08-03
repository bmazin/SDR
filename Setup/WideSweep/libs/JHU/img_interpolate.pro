;-------------------------------------------------------------
;+
; NAME:
;       IMG_INTERPOLATE
; PURPOSE:
;       Do interpolate on a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_interpolate(img,x,y)
; INPUTS:
;       img = Input image.             in
;       x,y = X and Y indices to use.  in
;         Same as for IDL interpolate.
; KEYWORD PARAMETERS:
;       Keywords:
;         All keywords to the builtin interpolate function.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       out = interpolated image.      out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays and interpolates
;         correct image planes.
; MODIFICATION HISTORY:
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_interpolate, img, x, y, _extra=extra, error=err, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Do interpolate on a 2-D or 3-D image array.'
	  print,' out = img_interpolate(img,x,y)'
	  print,'   img = Input image.             in'
	  print,'   x,y = X and Y indices to use.  in'
	  print,'     Same as for IDL interpolate.'
	  print,'   out = interpolated image.      out'
	  print,' Keywords:'
	  print,'   All keywords to the builtin interpolate function.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Note: deals with 2-D or 3-D image arrays and interpolates'
	  print,'   correct image planes.'
	  return, ''
	endif
 
	err = 0
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_interpolate: given array must 2-D or 3-D.'
	  return, img
	endif
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then return, interpolate(img,x,y,_extra=extra)
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_interpolate: given array must have a dimension of 3.'
	  return, img
	endif
 
	case typ of
1:	begin
	  r = interpolate(reform(img(0,*,*)),x,y,_extra=extra)
	  g = interpolate(reform(img(1,*,*)),x,y,_extra=extra)
	  b = interpolate(reform(img(2,*,*)),x,y,_extra=extra)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(3,nx,ny,type=dtyp)
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  r = interpolate(reform(img(*,0,*)),x,y,_extra=extra)
	  g = interpolate(reform(img(*,1,*)),x,y,_extra=extra)
	  b = interpolate(reform(img(*,2,*)),x,y,_extra=extra)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(nx,3,ny,type=dtyp)
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  r = interpolate(reform(img(*,*,0)),x,y,_extra=extra)
	  g = interpolate(reform(img(*,*,1)),x,y,_extra=extra)
	  b = interpolate(reform(img(*,*,2)),x,y,_extra=extra)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(nx,ny,3,type=dtyp)
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
