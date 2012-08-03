;-------------------------------------------------------------
;+
; NAME:
;       IMG_REDIM
; PURPOSE:
;       Change the interleave dimension of a 3-D image.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_redim(in).
; INPUTS:
;       in = Input 3-D image.      in
; KEYWORD PARAMETERS:
;       Keywords:
;         TRUE=tr Desired interleave dimension.
;         NX=nx, NY=ny Returned image dimensions.
;         ERROR=err error flag: 0=ok, else error.
; OUTPUTS:
;       out = Returned 3-D image.  out
; COMMON BLOCKS:
; NOTES:
;       Note: Input image must be 3-D.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jun 15
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_redim, img, true=true, nx=nx, ny=ny, $
	  error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Change the interleave dimension of a 3-D image.'
	  print,' out = img_redim(in).'
	  print,'   in = Input 3-D image.      in'
	  print,'   out = Returned 3-D image.  out'
	  print,' Keywords:'
	  print,'   TRUE=tr Desired interleave dimension.'
	  print,'   NX=nx, NY=ny Returned image dimensions.'
	  print,'   ERROR=err error flag: 0=ok, else error.'
	  print,' Note: Input image must be 3-D.'
	  return,''
	endif
 
	err = 0
 
	;--------  Find input image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if ndim gt 3 then begin
	  err = 1
	  print,' Error in img_redim: given array must be 3-D.'
	  return,img
	endif
	dtyp = sz(sz(0)+1)	; Incoming data type.
 
	;--------  3-D image: find input interleave dimension  ----------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_redim: given array must have a dimension of 3.'
	  return,img
	endif
 
	;--------  Split input image into RGB components  ------------
	case typ of
1:	begin
	  nx = sz(2)
	  ny = sz(3)
	  if true eq 1 then return, img
	  r = reform(img(0,*,*))
	  g = reform(img(1,*,*))
	  b = reform(img(2,*,*))
	end
2:	begin
	  nx = sz(1)
	  ny = sz(3)
	  if true eq 2 then return, img
	  r = reform(img(*,0,*))
	  g = reform(img(*,1,*))
	  b = reform(img(*,2,*))
	end
3:	begin
	  nx = sz(1)
	  ny = sz(2)
	  if true eq 3 then return, img
	  r = img(*,*,0)
	  g = img(*,*,1)
	  b = img(*,*,2)
	end
	endcase
 
	;-------  Recombine as requested  --------------
	case true of
1:	begin
	  out = make_array(3,nx,ny,type=dtyp)
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  out = make_array(nx,3,ny,type=dtyp)
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  out = make_array(nx,ny,3,type=dtyp)
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
