;-------------------------------------------------------------
;+
; NAME:
;       IMG_STRETCH
; PURPOSE:
;       Stretch a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_stretch(in,lo,hi)
; INPUTS:
;       in = Input image.           in
;       lo = low cutoff (def=0).    in
;       hi = high cutoff (def=255). in
; KEYWORD PARAMETERS:
;       Keywords:
;         OUTLO=lo2  lo maps to lo2 (default=0).
;         OUTHI=hi2  hi maps to hi2 (default=255).
;         /NOCLIP means do not clip output to lo2, hi2.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       out = Stretched image.      out
; COMMON BLOCKS:
; NOTES:
;       Notes: Remaps image values lo and hi to lo2 and hi2.
;         Returned image is same type is input image.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jan 08
;       R. Sterner, 2001 Sep 20 --- Fixed a bug for the no-op case.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_stretch, img, lo, hi, outlo=lo2, outhi=hi2, $
	  noclip=noclip, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Stretch a 2-D or 3-D image array.'
	  print,' out = img_stretch(in,lo,hi)'
	  print,'   in = Input image.           in'
	  print,'   lo = low cutoff (def=0).    in'
	  print,'   hi = high cutoff (def=255). in'
	  print,'   out = Stretched image.      out'
	  print,' Keywords:'
	  print,'   OUTLO=lo2  lo maps to lo2 (default=0).'
	  print,'   OUTHI=hi2  hi maps to hi2 (default=255).'
	  print,'   /NOCLIP means do not clip output to lo2, hi2.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Notes: Remaps image values lo and hi to lo2 and hi2.'
	  print,'   Returned image is same type is input image.'
	  return, ''
	endif
	err = 0
 
	if n_elements(lo) eq 0 then lo=0
	if n_elements(hi) eq 0 then hi=255
	if n_elements(lo2) eq 0 then lo2=0
	if n_elements(hi2) eq 0 then hi2=255
	if (lo eq lo2) and (hi eq hi2) then return, img	; No op.
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_stretch: given array must 2-D or 3-D.'
	  return, img
	endif
	dtyp = sz(sz(0)+1)	; Incoming data type.
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then begin
	  nx = round(sz(1)*mag)
	  ny = round(sz(2)*mag)
	  c = (double(hi2-lo2))/(hi-lo)
	  out = (in-lo)*c + lo2
	  if not keyword_set(noclip) then out=out>lo2<hi2
	  return, fix(out,type=dtyp)
	endif
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_stretch: given array must have a dimension of 3.'
	  return, img
	endif
 
	c = (double(hi2-lo2))/(hi-lo)
 
	case typ of
1:	begin
	  r = (reform(img(0,*,*))-lo)*c + lo2
	  g = (reform(img(1,*,*))-lo)*c + lo2
	  b = (reform(img(2,*,*))-lo)*c + lo2
	  if not keyword_set(noclip) then begin
	    r = r>lo2<hi2
	    g = g>lo2<hi2
	    b = b>lo2<hi2
	  endif
	  sz=size(r) & nx=sz(1) & ny=sz(2)
	  out = make_array(3,nx,ny,type=dtyp)
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  r = (reform(img(*,0,*))-lo)*c + lo2
	  g = (reform(img(*,1,*))-lo)*c + lo2
	  b = (reform(img(*,2,*))-lo)*c + lo2
	  if not keyword_set(noclip) then begin
	    r = r>lo2<hi2
	    g = g>lo2<hi2
	    b = b>lo2<hi2
	  endif
	  sz=size(r) & nx=sz(1) & ny=sz(2)
	  out = make_array(nx,3,ny,type=dtyp)
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  r = (reform(img(*,*,0))-lo)*c + lo2
	  g = (reform(img(*,*,1))-lo)*c + lo2
	  b = (reform(img(*,*,2))-lo)*c + lo2
	  if not keyword_set(noclip) then begin
	    r = r>lo2<hi2
	    g = g>lo2<hi2
	    b = b>lo2<hi2
	  endif
	  sz=size(r) & nx=sz(1) & ny=sz(2)
	  out = make_array(nx,ny,3,type=dtyp)
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
