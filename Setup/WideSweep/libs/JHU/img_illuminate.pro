;-------------------------------------------------------------
;+
; NAME:
;       IMG_ILLUMINATE
; PURPOSE:
;       Apply color illumination to an image (24 bit color).
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_illuminate(base, ill)
; INPUTS:
;       base = Base image.          in
;       ill = Color illumination.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         WT=wt illumination weight, 0 to 1 (def=1).
;           Smaller values give weaker illumination.
;         /DESAT means allow desaturation (def=do not).
;           With desaturation on any overflow in a color
;           channel will flow into the other 2 channels.  This
;           will make the pixel brighter, but less saturated.
;         ERROR=err Error flag: 0=ok, 1=error.
; OUTPUTS:
;       out = illuminated image.    out.
; COMMON BLOCKS:
; NOTES:
;       Note: The illumination image is a color image.
;         This is a color image used as illumination.  This works
;         as if projecting a slide of the illumination image
;         onto the base image (both must be the same size).
;         This is an additive process.  Pure black is no
;         illumination, pure white is complete illumantion and
;         will give saturation in all 3 channels, R,G,B.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 20
;       R. Sterner, 2005 Jul 20 --- Used temporary() to reduce memory.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_illuminate, base, ill, wt=wt, error=err, $
	  desat=desat, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Apply color illumination to an image (24 bit color).'
	  print,' out = img_illuminate(base, ill)'
	  print,'   base = Base image.          in'
	  print,'   ill = Color illumination.   in'
	  print,'   out = illuminated image.    out.'
	  print,' Keywords:'
	  print,'   WT=wt illumination weight, 0 to 1 (def=1).'
	  print,'     Smaller values give weaker illumination.'
	  print,'   /DESAT means allow desaturation (def=do not).'
	  print,'     With desaturation on any overflow in a color'
	  print,'     channel will flow into the other 2 channels.  This'
	  print,'     will make the pixel brighter, but less saturated.'
	  print,'   ERROR=err Error flag: 0=ok, 1=error.'
	  print,' Note: The illumination image is a color image.'
	  print,'   This is a color image used as illumination.  This works'
	  print,'   as if projecting a slide of the illumination image'
	  print,'   onto the base image (both must be the same size).'
	  print,'   This is an additive process.  Pure black is no'
	  print,'   illumination, pure white is complete illumantion and'
	  print,'   will give saturation in all 3 channels, R,G,B.'
	  return, ''
	endif
 
	;-----  Split base image into RGB components  -------
	img_split, base, r, g, b, true=tr, nx=nx1, ny=ny1
 
	;-----  Split illumination into RGB components  -----------
	img_split, ill, r2, g2, b2, nx=nx2, ny=ny2
 
	;-----  Make sure sizes are equal  ------------------
	if (nx1 ne nx2) or (ny1 ne ny2) then begin
	  print,' Error in img_illuminate: base image and illumination image'
	  print,' must be the same size.'
	  err = 1
	  return, base
	endif
 
	;-----  Apply weight  -------------------------
	if n_elements(wt) eq 0 then wt = 1.
	r2 = wt*r2
	g2 = wt*g2
	b2 = wt*b2
 
	;-----  Add illumination  ---------------------
	r3 = temporary(r) + temporary(r2)
	g3 = temporary(g) + temporary(g2)
	b3 = temporary(b) + temporary(b2)
 
	;-----  Distribute any overflow to other two channels  --------
	if keyword_set(desat) then begin
	  wr = where(r3 gt 255,cr)  ; Find where each channel is maxed.
	  wg = where(g3 gt 255,cg)
	  wb = where(b3 gt 255,cb)
	  if cr gt 0 then begin     ; Distribute R overflow between G and B.
	    g3(wr) = g3(wr) + (r3(wr)-255)/2
	    b3(wr) = b3(wr) + (r3(wr)-255)/2
	  endif
	  if cg gt 0 then begin
	    r3(wg) = r3(wg) + (g3(wg)-255)/2
	    b3(wg) = b3(wg) + (g3(wg)-255)/2
	  endif
	  if cb gt 0 then begin
	    r3(wb) = r3(wb) + (b3(wb)-255)/2
	    g3(wb) = g3(wb) + (b3(wb)-255)/2
	  endif
	endif
 
	;-------  Clip to channel max  ---------------
	r3 = r3<255	; Clip each channel to max independently.
	g3 = g3<255
	b3 = b3<255
	
	;-----  Reconstitute image  ------
	err = 0
	return, img_merge(r3,g3,b3, true=tr)
 
	end
