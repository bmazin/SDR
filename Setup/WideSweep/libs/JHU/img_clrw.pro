;-------------------------------------------------------------
;+
; NAME:
;       IMG_CLRW
; PURPOSE:
;       Set specified pixels to a given color in a 24-bit image.
; CATEGORY:
; CALLING SEQUENCE:
;       img2 = img_clrw(img1,w)
; INPUTS:
;       img1 = Original image.               in
;       w = Array of 1-d indices to modify.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr Replacement color.
;           May also be a 3 element array: [R,G,B].
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
;       img2 = Modified image.               out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 26
;       R. Sterner, 2002 Jun 18 --- Fixed to work for bw.
;       R. Sterner, 2002 Jun 25 --- Allowed 24-bit color value.
;       R. Sterner, 2002 Jul 11 --- Made COLOR keyword more standard.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_clrw, img, w, color=clr0, error=err,help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Set specified pixels to a given color in a 24-bit image.'
	  print,' img2 = img_clrw(img1,w)'
	  print,'   img1 = Original image.               in'
	  print,'   w = Array of 1-d indices to modify.  in'
	  print,'   img2 = Modified image.               out'
	  print,' Keywords:'
	  print,'   COLOR=clr Replacement color.'
	  print,'     May also be a 3 element array: [R,G,B].'
	  print,'   ERROR=err Error flag: 0=ok.'
	  return,''
	endif
 
	;-------  Check for valid input values  --------------
	if w(0) eq -1 then return, img
 
	if n_elements(clr0) eq 0 then return, img	; No replacement.
	clr = clr0					; Copy color.
	if n_elements(clr) eq 1 then begin
	   c2rgb, clr, c1,c2,c3
	   clr = [c1,c2,c3]
	endif
 
	if n_elements(clr) ne 3 then begin
	  print,' Error in img_clrw: Must give a 3 elements replacement color'
	  print,'   array: [r,g,b], or a 24-bit color value.'
	  err = 1
	  return,''
	endif
 
	mn = min(clr,max=mx)
	if (mn lt 0) or (mx gt 255) then begin
	  print,' Error in img_clrw: Replacement color value out of range (0-255).'
	  err = 1
	  return,''
	endif
 
	;------  Split input image  ---------------
	img_split, img, r, g, b, tr=tr
 
	;------  Replace pixles specified by index array  -----------
	r(w) = clr(0)
	if tr gt 0 then begin	; Color image.
	  g(w) = clr(1)
	  b(w) = clr(2)
	endif else begin	; BW image.
	  return, r
	endelse
 
	;-------  Merge color channels back into a 24-bit image  -------
	return, img_merge(r,g,b,true=tr)
 
	end
