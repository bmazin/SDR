;-------------------------------------------------------------
;+
; NAME:
;       MULTIBAND
; PURPOSE:
;       Convert a multiband image to a 24-bit color image.
; CATEGORY:
; CALLING SEQUENCE:
;       img = multiband(in)
; INPUTS:
;       in = Multiband input image array.   in
;          Stack of images in 3-D array: nx x ny x N
;          = N images each nx by ny pixels.
; KEYWORD PARAMETERS:
;       Keywords:
;         HUE=h Array of hues for each image band.
;           Def is an array of N hues from 0 to 300.
;         /REVERSE means reverse colors.
;         WT=wt Array of weights for each band (def all 1).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Each band in the multiband input image is split into
;       R,G,B components and all summed to give the final image
;       R,G,B. Returned image will not be scaled.  To display try
;         tv,true=3,img
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 16
;       R. Sterner, 2005 Apr 20 --- Added /REVERSE.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function multiband, in, wt=wt, hue=hue, reverse=rev, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a multiband image to a 24-bit color image.'
	  print,' img = multiband(in)'
	  print,'   in = Multiband input image array.   in'
	  print,'      Stack of images in 3-D array: nx x ny x N'
	  print,'      = N images each nx by ny pixels.'
	  print,' Keywords:'
	  print,'   HUE=h Array of hues for each image band.'
	  print,'     Def is an array of N hues from 0 to 300.'
	  print,'   /REVERSE means reverse colors.'
	  print,'   WT=wt Array of weights for each band (def all 1).'
	  print,' Note: Each band in the multiband input image is split into'
	  print,' R,G,B components and all summed to give the final image'
	  print,' R,G,B. Returned image will not be scaled.  To display try'
	  print,'   tv,true=3,img'
	  return,''
	endif
 
	;------  Get input image stack dimensions  --------
	sz = size(in)
	if sz(0) ne 3 then begin
	  print,' Error in multiband: must give a 3-D array as the input'
	  print,'   multiband image.'
	  return,''
	endif
	nx=sz(1) & ny=sz(2) & n=sz(3)
 
	;------  Defaults  ----------------------------
	if n_elements(wt) eq 0 then wt=fltarr(n)+1.
	if n_elements(hue) eq 0 then hue=maken(0,300,n)
	if keyword_set(rev) then hue=reverse(hue)
 
	;------  Initialize output image arrays  ------
	rr = fltarr(nx,ny)
	gg = rr
	bb = rr
 
	;------  Loop through bands  -----------
	for i=0, n-1 do begin
	  c = in(*,*,i)*wt(i)			; i'th image band, weighted.
	  color_convert,hue(i),1,1,r,g,b,/hsv_rgb	; Hue to RGB.
	  wt_r = r/255.					; RGB weights for hue.
	  wt_g = g/255.
	  wt_b = b/255.
	  rr = rr + c*wt_r	; Merge i'th image band into output image.
	  gg = gg + c*wt_g
	  bb = bb + c*wt_b
	endfor
 
	;------  Return 3-D image  -------
	cc = [[[rr]],[[gg]],[[bb]]]
	return, cc
 
	end
