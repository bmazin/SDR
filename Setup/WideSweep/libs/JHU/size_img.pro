;-------------------------------------------------------------
;+
; NAME:
;       SIZE_IMG
; PURPOSE:
;       Return image size and true value.
; CATEGORY:
; CALLING SEQUENCE:
;       size_img, img
; INPUTS:
;       img = Input image.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         NX=nx, NY=ny  Image size.
;         TRUE=tr  Interleave index for 3-D true color images.
;           tr is 0 is 2-D image.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Sep 26
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro size_img, img, nx=nx, ny=ny, true=tr, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return image size and true value.'
	  print,' size_img, img'
	  print,'   img = Input image.           in'
	  print,' Keywords:'
	  print,'   NX=nx, NY=ny  Image size.'
	  print,'   TRUE=tr  Interleave index for 3-D true color images.'
	  print,'     tr is 0 is 2-D image.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  return
	endif
 
	err = 0
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in size_img: given array must 2-D or 3-D.'
	  return
	endif
 
	;--------  3-D image  --------------------------
	tr = 0
	if sz(1) eq 3 then tr=1
	if sz(2) eq 3 then tr=2
	if sz(3) eq 3 then tr=3
 
	case tr of
0:	begin
	  nx = sz(1)
	  ny = sz(2)
	end
1:	begin
	  nx = sz(2)
	  ny = sz(3)
	end
2:	begin
	  nx = sz(1)
	  ny = sz(3)
	end
3:	begin
	  nx = sz(1)
	  ny = sz(2)
	end
	endcase
 
	return
 
	end
