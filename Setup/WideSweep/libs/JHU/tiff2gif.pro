;-------------------------------------------------------------
;+
; NAME:
;       TIFF2GIF
; PURPOSE:
;       Convert a TIFF image to a GIF image.
; CATEGORY:
; CALLING SEQUENCE:
;       tiff2gif, file
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         OUTPUT=gfile Override GIF file name.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Nov 01
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro tiff2gif, file, output=gfile, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a TIFF image to a GIF image.'
	  print,' tiff2gif, file'
	  print,'   file = Name of TIFF image file.'
	  print,'     GIF file name will be the same except .gif'
	  print,' Keywords:'
	  print,'   OUTPUT=gfile Override GIF file name.'
	  return
	endif
 
	img = read_tiff(file,r,g,b,orient=ori)
	if ori eq 1 then img = reverse(img,2)
 
	if n_elements(gfile) eq 0 then begin
	  filebreak,file,dir=dir,name=nam
	  gfile = filename(dir,nam+'.gif',/nosym)
	endif
 
	write_gif, gfile, img, r, g, b
 
	end
