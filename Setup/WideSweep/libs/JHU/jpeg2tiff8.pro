;-------------------------------------------------------------
;+
; NAME:
;       JPEG2TIFF8
; PURPOSE:
;       Convert a JPEG image to an 8 bit TIFF image.
; CATEGORY:
; CALLING SEQUENCE:
;       jpeg2tiff8, file
; INPUTS:
;       file = JPEG image file name.       in
;         Prompted for if not given.
; KEYWORD PARAMETERS:
;       Keywords:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Intended to convert 24 bit JPEG images to 8 bit TIFF.
;         Output file name is same as input but with *_8.tif as type.
; MODIFICATION HISTORY:
;	R. Sterner, 1995 May 19
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro jpeg2tiff8, file, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Convert a JPEG image to an 8 bit TIFF image.'
	  print,' jpeg2tiff8, file'
	  print,'   file = JPEG image file name.       in'
	  print,'     Prompted for if not given.'
	  print,' Keywords:'
	  print,' Notes: Intended to convert 24 bit JPEG images to 8 bit TIFF.'
	  print,'   Output file name is same as input but with *_8.tif as type.'
	  return
	endif
 
	if n_elements(file) eq 0 then begin
	  print,' Convert a JPEG image to an 8 bit TIFF image.'
	  file = ''
	  read,' Enter name of JPEG image file: ',file
	  if file eq '' then return
	endif
 
	;-------  Read JPEG image  -----------
	print,' Reading JPEG image '+file+' . . .'
	read_jpeg, file, img, c, colors=256,/dither,/two_pass
        r = c(*,0)
        g = c(*,1)
        b = c(*,2)
 
	;-------  Write TIFF  -----------
	filebreak, file, dir=dir, name=name
	out = filename(dir,name+'_8.tif',/nosym)
	print,' Writing 8 bit TIFF image '+out+' . . .'
	tiff_write, out, reverse(img,2),1,red=r,green=g,blue=b
 
	print,' Converted JPEG image '+file+' to 8 bit TIFF image '+out
 
	return
	end
