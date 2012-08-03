;-------------------------------------------------------------
;+
; NAME:
;       PNG_MAG
; PURPOSE:
;       Change PNG image size.
; CATEGORY:
; CALLING SEQUENCE:
;       png_mag, list
; INPUTS:
;       list = list of PNG images to process.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         MAG=mag  Mag factor (def=0.5).
;         ROTATE=r Optional rotate code (def=none).
;         SMOOTH=sm Optional smoothing window size.
;           Applied before resizing.
;         PREFIX=pre  Output image prefix (def='_').
;         /QUIET suppress messages.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: keywords to img_resize may also be given.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Apr 28
;       R. Sterner, 2004 Jun 11 --- Added ROTATE=r keyword.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro png_mag, list, prefix=prefix, mag=mag, _extra=extra, $
	  quiet=quiet, smooth=sm, rotate=rot, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Change PNG image size.'
	  print,' png_mag, list'
	  print,'   list = list of PNG images to process.  in'
	  print,' Keywords:'
	  print,'   MAG=mag  Mag factor (def=0.5).'
	  print,'   ROTATE=r Optional rotate code (def=none).'
	  print,'   SMOOTH=sm Optional smoothing window size.'
	  print,'     Applied before resizing.'
	  print,"   PREFIX=pre  Output image prefix (def='_')."
	  print,'   /QUIET suppress messages.'
	  print,' Note: keywords to img_resize may also be given.'
	  return
	endif
 
	if n_elements(mag) eq 0 then mag=0.5
	if n_elements(preix) eq 0 then prefix='_'
 
	n = n_elements(list)
	
	for i=0, n-1 do begin
	  fname = list(i)
	  img = read_png(fname,rr,gg,bb)
	  if n_elements(rot) ne 0 then img=img_rotate(img,rot)
	  if n_elements(sm) ne 0 then img=img_smooth(img,sm)
	  img = img_resize(img,mag=mag, _extra=extra)
	  write_png,prefix+fname,img
	  if not keyword_set(quiet) then begin
	    print,' Resized '+fname+' to '+prefix+fname
	  endif
	endfor
 
	end
