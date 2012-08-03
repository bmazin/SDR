;-------------------------------------------------------------
;+
; NAME:
;       IMG_SHARPEN
; PURPOSE:
;       Sharpen a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_sharpen(in)
; INPUTS:
;       in = Input image.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         SMOOTH=sm  Smoothing window size (def=3).
;            Use odd values to avoid image shift: 3,5,7,...
;         WEIGHT=wt  Weight for smoothed image (def=0.6).
;           Keep between 0 and 1.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       out = sharpened image.   out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays.
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
	function img_sharpen, img, smooth=sm, weight=wt, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Sharpen a 2-D or 3-D image array.'
	  print,' out = img_sharpen(in)'
	  print,'   in = Input image.        in'
	  print,'   out = sharpened image.   out'
	  print,' Keywords:'
	  print,'   SMOOTH=sm  Smoothing window size (def=3).'
	  print,'      Use odd values to avoid image shift: 3,5,7,...'
	  print,'   WEIGHT=wt  Weight for smoothed image (def=0.6).'
	  print,'     Keep between 0 and 1.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Note: deals with 2-D or 3-D image arrays.'
	  return, ''
	endif
 
	err = 0
 
	if n_elements(sm) eq 0 then sm=3
	if sm lt 2 then return, img
	if n_elements(wt) eq 0 then wt=0.6
 
	;--------  Find image dimensions  --------------
	img_shape, img, true=tr, error=err
	if err ne 0 then return,''
 
	;--------  2-D image  --------------------------
	if tr eq 0 then begin
	  return, sharpen(img,smooth=sm, weight=wt)
	endif
 
	;--------  3-D image  --------------------------
	img_split, img, r, g, b
	r = sharpen(r,smooth=sm, weight=wt)
	g = sharpen(g,smooth=sm, weight=wt)
	b = sharpen(b,smooth=sm, weight=wt)
	return, img_merge(r,g,b,true=tr)
 
	return, out
 
	end
