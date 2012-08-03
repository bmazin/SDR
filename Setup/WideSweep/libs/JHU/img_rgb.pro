;-------------------------------------------------------------
;+
; NAME:
;       IMG_RGB
; PURPOSE:
;       Returns the R,G,B components of a color image.
; CATEGORY:
; CALLING SEQUENCE:
;       img_rgb, img, r, g, b
; INPUTS:
;       img = Input image.         in
; KEYWORD PARAMETERS:
;       Keywords:
;         TRUE=tr Interleave dimension (0 means 2-D image).
;         NX=nx, NY=ny Image dimensions.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       r = red component image.   out
;       g = green component image. out
;       b = blue component image.  out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Mar 27
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro img_rgb, img, r, g, b, true=typ, nx=nx, ny=ny, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Returns the R,G,B components of a color image.'
	  print,' img_rgb, img, r, g, b'
	  print,'   img = Input image.         in'
	  print,'   r = red component image.   out'
	  print,'   g = green component image. out'
	  print,'   b = blue component image.  out'
	  print,' Keywords:'
	  print,'   TRUE=tr Interleave dimension (0 means 2-D image).'
	  print,'   NX=nx, NY=ny Image dimensions.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Note: deals with 2-D or 3-D image arrays.'
	  return
	endif
 
	err = 0
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_rgb: given array must 2-D or 3-D.'
	  return
	endif
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then begin
	  r = img	; Assume gray scale, all same.
	  g = img
	  b = img
	  typ = 0
	  nx = sz(1)
	  ny = sz(2)
	  return
	endif
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_rgb: given array must have a dimension of 3.'
	  return
	endif
 
	case typ of
1:	begin
	  r = reform(img(0,*,*))
	  g = reform(img(1,*,*))
	  b = reform(img(2,*,*))
	  nx = sz(2)
	  ny = sz(3)
	end
2:	begin
	  r = reform(img(*,0,*))
	  g = reform(img(*,1,*))
	  b = reform(img(*,2,*))
	  nx = sz(1)
	  ny = sz(3)
	end
3:	begin
	  r = reform(img(*,*,0))
	  g = reform(img(*,*,1))
	  b = reform(img(*,*,2))
	  nx = sz(1)
	  ny = sz(2)
	end
	endcase
 
	return
 
	end
