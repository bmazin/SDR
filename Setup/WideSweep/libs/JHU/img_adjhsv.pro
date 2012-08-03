;-------------------------------------------------------------
;+
; NAME:
;       IMG_ADJHSV
; PURPOSE:
;       Adjust Hue, Saturation, and Value for a 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_adjhsv(in)
; INPUTS:
;       in = Input image.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         HUE=off  Offset to add to Hue, which is in degrees, 0-360.
;         SAT=fct  Factor to apply to Saturation (clipped to 0-1).
;         VAL=fct  Factor to apply to Value (clipped to 0-1).
;           Defaults are no change.
;         ERROR=err error flag: 0=ok, 1=not 3-D,
;           2=wrong number of color channels for 3-D array.
; OUTPUTS:
;       out = Stretched image.      out
; COMMON BLOCKS:
; NOTES:
;       Notes: For 3-D images only.
;         Returned image is same type is input image.
;         Example: Increase saturation and brighten:
;         tv,img_adjhsv(img,hue=0,sat=1.5,val=1.5),tr=3
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jan 08
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_adjhsv, img, hue=hh, sat=ss, val=vv, $
	  error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Adjust Hue, Saturation, and Value for a 3-D image array.'
	  print,' out = img_adjhsv(in)'
	  print,'   in = Input image.           in'
	  print,'   out = Stretched image.      out'
	  print,' Keywords:'
	  print,'   HUE=off  Offset to add to Hue, which is in degrees, 0-360.'
	  print,'   SAT=fct  Factor to apply to Saturation (clipped to 0-1).'
	  print,'   VAL=fct  Factor to apply to Value (clipped to 0-1).'
	  print,'     Defaults are no change.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,' Notes: For 3-D images only.'
	  print,'   Returned image is same type is input image.'
	  print,'   Example: Increase saturation and brighten:'
	  print,'   tv,img_adjhsv(img,hue=0,sat=1.5,val=1.5),tr=3'
	  return, ''
	endif
 
	err = 0
 
	if n_elements(hh) eq 0 then hh=0
	if n_elements(ss) eq 0 then ss=1
	if n_elements(vv) eq 0 then vv=1
	if (hh eq 0) and (ss eq 1) and (vv eq 1) then return, img
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if ndim ne 3 then begin
	  err = 1
	  print,' Error in img_adjhsv: given array 3-D only.'
	  return, img
	endif
	dtyp = sz(sz(0)+1)	; Incoming data type.
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_adjhsv: given array must have a dimension of 3.'
	  return, img
	endif
 
	case typ of
1:	begin
	  r = reform(img(0,*,*))
	  g = reform(img(1,*,*))
	  b = reform(img(2,*,*))
	  sz=size(r) & nx=sz(1) & ny=sz(2)
	  out = make_array(3,nx,ny,type=dtyp)
	  color_convert,r,g,b,h,s,v,/rgb_hsv
	  h = h + hh
	  s = (s*ss)>0<1
	  v = (v*vv)>0<1
	  color_convert,h,s,v,r,g,b,/hsv_rgb
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  r = reform(img(*,0,*))
	  g = reform(img(*,1,*))
	  b = reform(img(*,2,*))
	  sz=size(r) & nx=sz(1) & ny=sz(2)
	  out = make_array(nx,3,ny,type=dtyp)
	  color_convert,r,g,b,h,s,v,/rgb_hsv
	  h = h + hh
	  s = (s*ss)>0<1
	  v = (v*vv)>0<1
	  color_convert,h,s,v,r,g,b,/hsv_rgb
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  r = reform(img(*,*,0))
	  g = reform(img(*,*,1))
	  b = reform(img(*,*,2))
	  sz=size(r) & nx=sz(1) & ny=sz(2)
	  out = make_array(nx,ny,3,type=dtyp)
	  color_convert,r,g,b,h,s,v,/rgb_hsv
	  h = h + hh
	  s = (s*ss)>0<1
	  v = (v*vv)>0<1
	  color_convert,h,s,v,r,g,b,/hsv_rgb
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
