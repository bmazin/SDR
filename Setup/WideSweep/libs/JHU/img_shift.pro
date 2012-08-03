;-------------------------------------------------------------
;+
; NAME:
;       IMG_SHIFT
; PURPOSE:
;       Shifts a 2-D or 3-D image array in x and y.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_shift(in,dx,dy)
; INPUTS:
;       in = Input image.    in
;       dx = shift in x      in
;       dy = shift in y.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       out = Shifted image. out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays and shifts
;         correct image planes.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Mar 21
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_shift, img, dx, dy, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Shifts a 2-D or 3-D image array in x and y.'
	  print,' out = img_shift(in,dx,dy)'
	  print,'   in = Input image.    in'
	  print,'   dx = shift in x      in'
	  print,'   dy = shift in y.     in'
	  print,'   out = Shifted image. out'
	  print,' Keywords:'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Note: deals with 2-D or 3-D image arrays and shifts'
	  print,'   correct image planes.'
	  return, ''
	endif
 
	err = 0
	if n_elements(dx) eq 0 then dx=0
	if n_elements(dy) eq 0 then dy=0
 
	;-------  No Op  -----------------------
	if (dx eq 0) and (dy eq 0) then return, img
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_resize: given array must 2-D or 3-D.'
	  return, img
	endif
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then begin
	  return, shift(img,dx,dy)
	endif
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_shift: given array must have a dimension of 3.'
	  return, img
	endif
 
	out = img
 
	case typ of
1:	begin
	  r = shift(reform(img(0,*,*)),dx,dy)
	  g = shift(reform(img(1,*,*)),dx,dy)
	  b = shift(reform(img(2,*,*)),dx,dy)
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  r = shift(reform(img(*,0,*)),dx,dy)
	  g = shift(reform(img(*,1,*)),dx,dy)
	  b = shift(reform(img(*,2,*)),dx,dy)
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  r = shift(reform(img(*,*,0)),dx,dy)
	  g = shift(reform(img(*,*,1)),dx,dy)
	  b = shift(reform(img(*,*,2)),dx,dy)
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
