;-------------------------------------------------------------
;+
; NAME:
;       CLR_SCALE
; PURPOSE:
;       Clear image scaling values embedded by put_scale.
; CATEGORY:
; CALLING SEQUENCE:
;       clr_scale, [img]
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Pixel value 90 is used to overwrite pixels 0 to 89
;         if 1234567890 is found in the first 10 pixels.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Feb 28
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro clr_scale, img, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Clear image scaling values embedded by put_scale.'
	  print,' clr_scale, [img]'
	  print,'   img = optional image array (def=screen image).   in,out'
 	  print,' Notes: Pixel value 90 is used to overwrite pixels 0 to 89'
	  print,'   if 1234567890 is found in the first 10 pixels.'
	  return
	endif
 
	if n_elements(img) eq 0 then begin
	  t = tvrd(0,0,90,1)
	endif else begin
	  t = img(0:89, 0)
	endelse
 
	m = string(t(0:9))
 
	if m ne '1234567890' then return
 
	if n_elements(img) eq 0 then begin
	  t90 = tvrd(90,0,1,1)	; Read next pixel.
	endif else begin
          t90 = img(90, 0)
        endelse
 
	t(*) = t90		; Fill 90 pixel array
 
	if n_elements(img) eq 0 then begin
	  tv,t			;   and overwrite scaling.
	endif else begin
          img(0,0) = t
        endelse
 
	return
	end
