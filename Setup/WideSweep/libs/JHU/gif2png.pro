;-------------------------------------------------------------
;+
; NAME:
;       GIF2PNG
; PURPOSE:
;       GIF to PNG converter
; CATEGORY:
; CALLING SEQUENCE:
;       gif2png, file
; INPUTS:
;       file = Input GIF image.       in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Saves image with same name but extension .png
;         Saves as an 8-bit PNG image.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Oct 25
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro gif2png, file, help=hlp
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' GIF to PNG converter'
	  print,' gif2png, file'
	  print,'   file = Input GIF image.       in'
	  print,' Notes: Saves image with same name but extension .png'
	  print,'   Saves as an 8-bit PNG image.'
	  return
	endif
 
	;--------  Check that file exists  ------------
	f = findfile(file,count=c)
	if c eq 0 then begin
	  print,' GIF file not found: '+file
	  return
	endif
 
	;---------  Output PNG file name  --------------
	filebreak, file, dir=dir, name=name
	out = filename(dir,name+'.png',/nosym)
 
	;---------  Read GIF image  --------------------
	read_gif, file, img, r, g, b
 
	;---------  Flip to correct IDL error  ---------
	if !version.release le 5.3 then img=rotate(img,7)
 
	;---------  Write PNG image  -------------------
	write_png, out, img, r, g, b
	print,' PNG image written: '+out
 
	end
