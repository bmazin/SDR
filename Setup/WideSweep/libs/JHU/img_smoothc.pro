;-------------------------------------------------------------
;+
; NAME:
;       IMG_SMOOTHC
; PURPOSE:
;       Convolution smooth a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_smoothc(in,sm)
; INPUTS:
;       in = Input image.                in
;       sm = smoothing value (def=none)  in
;         1.0 is strong, 0.1 is mild smoothing for default width.
; KEYWORD PARAMETERS:
;       Keywords:
;         WIDTH=w  Width of convolution smoothing kernel (def=5).
;           Make sure w is odd to avoid shifting the image.
;         /ZERO means zero edge effect pixels instead of assuming
;           repeated pixels at image edge.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       out = Smoothed image.            out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays and smooths
;         correct image planes.  Output data type is same as input.
;         Uses convolution smoothing with a gaussian kernel.
;         Wider kernels give more edge effect.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jan 05
;       R. Sterner, 2001 Jun 04 --- changed name to img_smoothc.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_smoothc, img, sm, width=width, error=err, $
	  zero=zero, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convolution smooth a 2-D or 3-D image array.'
	  print,' out = img_smoothc(in,sm)'
	  print,'   in = Input image.                in'
	  print,'   sm = smoothing value (def=none)  in'
	  print,'     1.0 is strong, 0.1 is mild smoothing for default width.'
	  print,'   out = Smoothed image.            out'
	  print,' Keywords:'
	  print,'   WIDTH=w  Width of convolution smoothing kernel (def=5).'
	  print,'     Make sure w is odd to avoid shifting the image.'
	  print,'   /ZERO means zero edge effect pixels instead of assuming'
	  print,'     repeated pixels at image edge.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Note: deals with 2-D or 3-D image arrays and smooths'
	  print,'   correct image planes.  Output data type is same as input.'
	  print,'   Uses convolution smoothing with a gaussian kernel.'
	  print,'   Wider kernels give more edge effect.'
	  return, ''
	endif
 
	err = 0
 
	if n_elements(sm) eq 0 then sm=0.
	if sm eq 0 then return, img	; No op.
 
	if keyword_set(zero) then trnc=0 else trnc=1  ; Deal with edge pixels.
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_smoothc: given array must 2-D or 3-D.'
	  return, img
	endif
	dtyp = sz(sz(0)+1)	; Incoming data type.
 
	;--------  Make smoothing kernel  --------------
	if n_elements(width) eq 0 then width=5
	makenxy,-1,1,width,-1,1,width,x,y
	except = !except
	!except = 0
	k = exp(-(x^2+y^2)/sm)
	tmp = check_math()
	!except = except
	sc = total(k)
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then begin
	  return, fix(type=dtyp,convol(float(img),k,sc,/center,edge_trunc=trnc))
	endif
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_smoothc: given array must have a dimension of 3.'
	  return, img
	endif
 
	case typ of
1:	begin
	  r = convol(float(reform(img(0,*,*))),k,sc,/center,edge_trunc=trnc)
	  g = convol(float(reform(img(1,*,*))),k,sc,/center,edge_trunc=trnc)
	  b = convol(float(reform(img(2,*,*))),k,sc,/center,edge_trunc=trnc)
	  sz=size(r) & nx=sz(1) & ny=sz(2)
	  out = make_array(3,nx,ny,type=dtyp)
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  r = convol(float(reform(img(*,0,*))),k,sc,/center,edge_trunc=trnc)
	  g = convol(float(reform(img(*,1,*))),k,sc,/center,edge_trunc=trnc)
	  b = convol(float(reform(img(*,2,*))),k,sc,/center,edge_trunc=trnc)
	  sz=size(r) & nx=sz(1) & ny=sz(2)
	  out = make_array(nx,3,ny,type=dtyp)
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  r = convol(float(reform(img(*,*,0))),k,sc,/center,edge_trunc=trnc)
	  g = convol(float(reform(img(*,*,1))),k,sc,/center,edge_trunc=trnc)
	  b = convol(float(reform(img(*,*,2))),k,sc,/center,edge_trunc=trnc)
	  sz=size(r) & nx=sz(1) & ny=sz(2)
	  out = make_array(nx,ny,3,type=dtyp)
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
