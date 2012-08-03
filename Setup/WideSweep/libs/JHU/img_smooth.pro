;-------------------------------------------------------------
;+
; NAME:
;       IMG_SMOOTH
; PURPOSE:
;       Box smooth a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_smooth(in,width)
; INPUTS:
;       in = Input image.                    in
;       width = Smoothing box width (def=3). in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       out = Smoothed image.                out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays and smooths
;         correct image planes.  Output data type is same as input.
;         Uses built-in IDL box smoothing.
;         Wider smoothing box give more edge effect.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jun 04
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_smooth, img, width, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Box smooth a 2-D or 3-D image array.'
	  print,' out = img_smooth(in,width)'
	  print,'   in = Input image.                    in'
	  print,'   width = Smoothing box width (def=3). in'
	  print,'   out = Smoothed image.                out'
	  print,' Keywords:'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Note: deals with 2-D or 3-D image arrays and smooths'
	  print,'   correct image planes.  Output data type is same as input.'
	  print,'   Uses built-in IDL box smoothing.'
	  print,'   Wider smoothing box give more edge effect.'
	  return, ''
	endif
 
	err = 0
 
	if n_elements(width) eq 0 then width=3
	if width lt 2 then return, img
 
	;--------  Find image dimensions  --------------
	img_shape, img, true=tr, error=err
	if err ne 0 then return,''
	dtyp = datatype(img,2)	; Incoming data type.
 
	;--------  2-D image  --------------------------
	if tr eq 0 then begin
	  return, fix(type=dtyp,smooth(img,width))
	endif
 
	;--------  3-D image  --------------------------
	img_split, img, r, g, b
	r = fix(type=dtyp,smooth(r,width))
	g = fix(type=dtyp,smooth(g,width))
	b = fix(type=dtyp,smooth(b,width))
	return, img_merge(r,g,b,true=tr)
 
	return, out
 
	end
