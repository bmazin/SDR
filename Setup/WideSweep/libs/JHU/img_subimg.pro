;-------------------------------------------------------------
;+
; NAME:
;       IMG_SUBIMG
; PURPOSE:
;       Returns a subimage from a color image.
; CATEGORY:
; CALLING SEQUENCE:
;       subimg = img_subimg(img, ix, iy, dx, dy).
; INPUTS:
;       img = Input image.                            in
;       ix,iy = Starting x and y pixel for subimage.  in
;       dx,dy = Size of subimage to extract.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         TRUE=tr Returned interleave dimension (0 means 2-D image).
;         NX=nx, NY=ny Input image dimensions.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D.
; OUTPUTS:
;       subimg = Returned subimage.                   out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jun 14
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_subimg, img, ix, iy, dx, dy, $
	  true=typ, nx=nx, ny=ny, error=err, help=hlp
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' Returns a subimage from a color image.'
	  print,' subimg = img_subimg(img, ix, iy, dx, dy).'
	  print,'   img = Input image.                            in'
	  print,'   ix,iy = Starting x and y pixel for subimage.  in'
	  print,'   dx,dy = Size of subimage to extract.          in'
	  print,'   subimg = Returned subimage.                   out'
	  print,' Keywords:'
	  print,'   TRUE=tr Returned interleave dimension (0 means 2-D image).'
	  print,'   NX=nx, NY=ny Input image dimensions.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D.'
	  print,' Note: deals with 2-D or 3-D image arrays.'
	  return,''
	endif
 
	err = 0
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_subimg: given array must 2-D or 3-D.'
	  return,img
	endif
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then begin
	  typ = 0
	  nx = sz(1)
	  ny = sz(2)
	  lox = ix>0<(nx-1)
	  loy = iy>0<(ny-1)
	  hix = (lox+dx-1)<(nx-1)
	  hiy = (loy+dy-1)<(ny-1)
	  sub = img(lox:hix,loy:hiy)
	  return,sub
	endif
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_subimg: given array must have a dimension of 3.'
	  return,img
	endif
 
	case typ of
1:	begin
	  nx = sz(2)
	  ny = sz(3)
	  lox = ix>0<(nx-1)
	  loy = iy>0<(ny-1)
	  hix = (lox+dx-1)<(nx-1)
	  hiy = (loy+dy-1)<(ny-1)
	  sub = img(*,lox:hix,loy:hiy)
	end
2:	begin
	  nx = sz(1)
	  ny = sz(3)
	  lox = ix>0<(nx-1)
	  loy = iy>0<(ny-1)
	  hix = (lox+dx-1)<(nx-1)
	  hiy = (loy+dy-1)<(ny-1)
	  sub = img(lox:hix,*,loy:hiy)
	end
3:	begin
	  nx = sz(1)
	  ny = sz(2)
	  lox = ix>0<(nx-1)
	  loy = iy>0<(ny-1)
	  hix = (lox+dx-1)<(nx-1)
	  hiy = (loy+dy-1)<(ny-1)
	  sub = img(lox:hix,loy:hiy,*)
	end
	endcase
 
	return,sub
 
	end
