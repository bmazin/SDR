;-------------------------------------------------------------
;+
; NAME:
;       IMG_SHAPE
; PURPOSE:
;       Returns the shape of a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       img_shape, img
; INPUTS:
;       img = Input image.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         TRUE=tr Interleave dimension for true color:
;           0 = 2-D image, else dimension (1, 2, or 3).
;           Use to display image: tv,img,true=tr
;         NX=nx, NY=ny returned image size in x and y.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
;         /QUIET do not display an error message.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Mar 26
;       R. Sterner, 2007 Mar 01 --- Added /QUIET keyword.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro img_shape, img, true=true, nx=nx, ny=ny, error=err, $
	  quiet=quiet, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Returns the shape of a 2-D or 3-D image array.'
	  print,' img_shape, img'
	  print,'   img = Input image.    in'
	  print,' Keywords:'
	  print,'   TRUE=tr Interleave dimension for true color:'
	  print,'     0 = 2-D image, else dimension (1, 2, or 3).'
	  print,'     Use to display image: tv,img,true=tr'
	  print,'   NX=nx, NY=ny returned image size in x and y.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,'   /QUIET do not display an error message.'
	  print,' Note: deals with 2-D or 3-D image arrays.'
	  return
	endif
 
	err = 0
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  if not keyword_set(quiet) then $
	    print,' Error in img_shape: given array must 2-D or 3-D.'
	  return
	endif
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then begin
	  true = 0
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
	  if not keyword_set(quiet) then $
	    print,' Error in img_shape: given array must have a dimension of 3.'
	  return
	endif
 
	case typ of
1:	begin
	  true = typ
	  nx = sz(2)
	  ny = sz(3)
	end
2:	begin
	  true = typ
	  nx = sz(1)
	  ny = sz(3)
	end
3:	begin
	  true = typ
	  nx = sz(1)
	  ny = sz(2)
	end
	endcase
 
	return
 
	end
