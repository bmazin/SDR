;-------------------------------------------------------------
;+
; NAME:
;       SHARPEN
; PURPOSE:
;       Returna sharpened version of the given image.
; CATEGORY:
; CALLING SEQUENCE:
;       out = sharpen(in)
; INPUTS:
;       in = Input image.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         SMOOTH=sm  Smoothing window size (def=3).
;         WEIGHT=wt  Weight for smoothed image (def=0.6).
; OUTPUTS:
;       out = output image.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: 8-bit images only. Use odd values for SMOOTH: 3,5,7,..
;         WEIGHT should be >0 and < 1.
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
	function sharpen, img, smooth=sm, weight=wt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Returna sharpened version of the given image.'
	  print,' out = sharpen(in)'
	  print,'   in = Input image.    in'
	  print,'   out = output image.  out'
	  print,' Keywords:'
	  print,'   SMOOTH=sm  Smoothing window size (def=3).'
	  print,'   WEIGHT=wt  Weight for smoothed image (def=0.6).'
	  print,' Notes: 8-bit images only. Use odd values for SMOOTH: 3,5,7,..'
	  print,'   WEIGHT should be >0 and < 1.'
	  return,''
	endif
 
	;------  Defaults  -------------
	if n_elements(sm) eq 0 then sm=3
	if n_elements(wt) eq 0 then wt=0.6
 
	a = float(img)
	s = a-wt*smooth(a,sm)
	s = s*sdev(a)/sdev(s)
	s = s+mean(a)-mean(s)
	return,byte(s>0<255)
 
	end
