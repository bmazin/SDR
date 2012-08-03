;-------------------------------------------------------------
;+
; NAME:
;       IMG_SPLIT
; PURPOSE:
;       Returns the color components of a color image.
; CATEGORY:
; CALLING SEQUENCE:
;       img_split, img, c1, c2, c3
; INPUTS:
;       img = Input image.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /HSV means return HSV color components (def RGB).
;         TRUE=tr Interleave dimension (0 means 2-D image).
;         NX=nx, NY=ny Image dimensions.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       c1 = component 1.   out
;       c2 = component 2.   out
;       c3 = component 3.   out
;          By default c1,c2,c3 = Red, Green, Blue.
;          /HSV requests Hue, Saturation, Value.
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Mar 27
;       R. Sterner, 2001 Jun 18 --- Renamed from img_rgb.pro
;       R. Sterner, 2001 Jun 21 --- Renamed from img_splitrgb.pro
;       R. Sterner, 2001 Jun 21 --- Added new keyword /HSV.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro img_split, img, r, g, b, true=typ, nx=nx, ny=ny, $
	  hsv=hsv, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Returns the color components of a color image.'
	  print,' img_split, img, c1, c2, c3'
	  print,'   img = Input image.  in'
	  print,'   c1 = component 1.   out'
	  print,'   c2 = component 2.   out'
	  print,'   c3 = component 3.   out'
	  print,'      By default c1,c2,c3 = Red, Green, Blue.'
	  print,'      /HSV requests Hue, Saturation, Value.'
	  print,' Keywords:'
	  print,'   /HSV means return HSV color components (def RGB).'
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
	  print,' Error in img_split: given array must 2-D or 3-D.'
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
	  goto, done
	endif
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_split: given array must have a dimension of 3.'
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
 
done:	if keyword_set(hsv) then begin
	  color_convert, r, g, b, h, s, v, /rgb_hsv
	  r = h		; Copy HSV into returned variables.
	  g = s
	  b = v
	endif
 
	return
 
	end
