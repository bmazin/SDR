;-------------------------------------------------------------
;+
; NAME:
;       IMG_CFILTER
; PURPOSE:
;       Apply a color filter to an image (both 24 bit color).
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_cfilter(base, filt)
; INPUTS:
;       base = Base image.     in
;       filt = Color filter.   in
;         This is a color image used as a filter.  This works
;         as if viewing the base image through a color
;         transparency of the same size on top of it.
; KEYWORD PARAMETERS:
;       Keywords:
;         WT=wt Filter weight, 0 to 1 (def=1).
;           Smaller values give weaker filters.
;         ERROR=err Error flag: 0=ok, 1=error.
; OUTPUTS:
;       out = filtered image.  out.
; COMMON BLOCKS:
; NOTES:
;       Note: The color filter is a color image.  Its coloring
;       is equivalent to viewing a white background through
;       the transparent color filter.  So pure white is completely
;       transparent, pure black is completely opaque, yellow
;       will block blue, and so on.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 20
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_cfilter, base, filt, wt=wt, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Apply a color filter to an image (both 24 bit color).'
	  print,' out = img_cfilter(base, filt)'
	  print,'   base = Base image.     in'
	  print,'   filt = Color filter.   in'
	  print,'     This is a color image used as a filter.  This works'
	  print,'     as if viewing the base image through a color'
	  print,'     transparency of the same size on top of it.'
	  print,'   out = filtered image.  out.'
	  print,' Keywords:'
	  print,'   WT=wt Filter weight, 0 to 1 (def=1).'
	  print,'     Smaller values give weaker filters.'
	  print,'   ERROR=err Error flag: 0=ok, 1=error.'
	  print,' Note: The color filter is a color image.  Its coloring'
	  print,' is equivalent to viewing a white background through'
	  print,' the transparent color filter.  So pure white is completely'
	  print,' transparent, pure black is completely opaque, yellow'
	  print,' will block blue, and so on.'
	  return, ''
	endif
 
	;-----  Split base image into RGB components  -------
	img_split, base, r, g, b, true=tr, nx=nx1, ny=ny1
 
	;-----  Split filter into RGB components  -----------
	img_split, filt, r2, g2, b2, nx=nx2, ny=ny2
 
	;-----  Make sure sizes are equal  ------------------
	if (nx1 ne nx2) or (ny1 ne ny2) then begin
	  print,' Error in img_cfilter: base image and filter image'
	  print,' must be the same size.'
	  err = 1
	  return, base
	endif
 
	;-----  Compute filter transmission factors  --------
	r2tr = r2/255.
	g2tr = g2/255.
	b2tr = b2/255.
 
	;-----  Apply filter weight  -------------------------
	if n_elements(wt) eq 0 then wt = 1.
	r2tr = 1.-wt*(1.-r2tr)
	g2tr = 1.-wt*(1.-g2tr)
	b2tr = 1.-wt*(1.-b2tr)
	
	;-----  Apply filter to base and reconstitute image  ------
	err = 0
	return, img_merge(r*r2tr, g*g2tr, b*b2tr, true=tr)
 
	end
