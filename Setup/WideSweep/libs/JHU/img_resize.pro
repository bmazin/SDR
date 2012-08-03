;-------------------------------------------------------------
;+
; NAME:
;       IMG_RESIZE
; PURPOSE:
;       Resize a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_resize(in)
; INPUTS:
;       in = Input image.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         MAG=mag  Mag factor (def=1).  mag may be [magx,magy].
;         SMAG=smag  Like MAG but smooth image first if smag<1.
;         IMGMAX=max Instead of MAG may give new length of max side.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
;         /REBIN use rebin to resize, else congrid.  Mag factor
;           must be exact multiple or submultiple for /REBIN.
;         May also use the keywords allowed by CONGRID or REBIN.
; OUTPUTS:
;       out = Resized image.        out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays and resizes
;         correct image planes.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Sep 21
;       R. Sterner, 2001 Jan 29 --- Allowed x and y mag.
;       R. Sterner, 2001 Jul 03 --- Added IMGMAX keyword.
;       R. Sterner, 2002 Jul 10 --- Simplified.  Added /REBIN.
;       R. Sterner, 2007 Mar 19 --- Added SMAG=smag.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_resize, img, mag=mag, smag=smag, imgmax=imgmax, $
	  _extra=extra, error=err, rebin=rbin, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Resize a 2-D or 3-D image array.'
	  print,' out = img_resize(in)'
	  print,'   in = Input image.           in'
	  print,'   out = Resized image.        out'
	  print,' Keywords:'
	  print,'   MAG=mag  Mag factor (def=1).  mag may be [magx,magy].'
	  print,'   SMAG=smag  Like MAG but smooth image first if smag<1.'
	  print,'   IMGMAX=max Instead of MAG may give new length of max side.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,'   /REBIN use rebin to resize, else congrid.  Mag factor'
	  print,'     must be exact multiple or submultiple for /REBIN.'
	  print,'   May also use the keywords allowed by CONGRID or REBIN.'
	  print,' Note: deals with 2-D or 3-D image arrays and resizes'
	  print,'   correct image planes.'
	  return, ''
	endif
 
	err = 0
 
	if n_elements(smag) ne 0 then begin
	  mag = smag
	  sflag = 1
	endif else begin
	  sflag = 0
	endelse
 
	;-------  For for no op  -----------------------
	nmag = n_elements(mag)
	case nmag of
0:	begin
	end
1:	begin
	  if mag(0) eq 1 then return, img
	end
2:	begin
	  if (mag(0) eq 1) and (mag(1) eq 1) then return, img
	end
else:	begin
	  print,' Error in img_resize: invalid mag factor.'
	  err = 3
	  return, img
	end
	endcase
 
	;--------  Smooth if smag given  -----------------------------
	if sflag eq 1 then begin
	  sm = round(1./min(smag))
	  img2 = img_smooth(img,sm)
	endif else begin
	  img2 = img
	endelse
 
	;--------  Split image.  Find image dimensions  --------------
	img_split, img2, r, g, b, true=tr, nx=nx0, ny=ny0, err=err
	if err ne 0 then return, img
 
	;--------  Deal with max image size  -----------
	if n_elements(imgmax) ne 0 then mag=min(float(imgmax)/[nx0,ny0])
	if n_elements(mag) eq 0 then mag=1.0
	nx = round(nx0*(mag([0]))(0))
	ny = round(ny0*(mag([1]))(0))
 
	;--------  2-D image  --------------------------
	if tr eq 0 then begin
	  if keyword_set(rbin) then begin
	    return, rebin(img2,nx,ny,_extra=extra)
	  endif else begin
	    return, congrid(img2,nx,ny,_extra=extra)
	  endelse
	endif
 
	;--------  3-D image  --------------------------
	if keyword_set(rbin) then begin
	  r = rebin(r,nx,ny,_extra=extra)
	  g = rebin(g,nx,ny,_extra=extra)
	  b = rebin(b,nx,ny,_extra=extra)
	endif else begin
	  r = congrid(r,nx,ny,_extra=extra)
	  g = congrid(g,nx,ny,_extra=extra)
	  b = congrid(b,nx,ny,_extra=extra)
	endelse
 
	out = img_merge(r,g,b,true=tr)
 
	return, out
 
	end
