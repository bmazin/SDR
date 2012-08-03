;-------------------------------------------------------------
;+
; NAME:
;       PNG2JPEG
; PURPOSE:
;       Convert a PNG image to a JPEG image.
; CATEGORY:
; CALLING SEQUENCE:
;       png2jpeg, file
; INPUTS:
;       file = PNG image file name.       in
;         Prompted for if not given.
; KEYWORD PARAMETERS:
;       Keywords:
;         QF=qf  JPEG quality factor (def=75).
;         MAG=m  Mag factor (def=1).
;         JPEG=jpg  returned JPEG file name.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: 
;         Output file name is same as input but with .jpg as type.
; MODIFICATION HISTORY:
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro png2jpeg, file, qf=qf, mag=mag, jpeg=out, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Convert a PNG image to a JPEG image.'
	  print,' png2jpeg, file'
	  print,'   file = PNG image file name.       in'
	  print,'     Prompted for if not given.'
	  print,' Keywords:'
	  print,'   QF=qf  JPEG quality factor (def=75).'
	  print,'   MAG=m  Mag factor (def=1).'
	  print,'   JPEG=jpg  returned JPEG file name.'
	  print,' Notes: 
	  print,'   Output file name is same as input but with .jpg as type.'
	  return
	endif
 
	if n_elements(file) eq 0 then begin
	  print,' Convert a PNG image to a JPEG image.'
	  file = ''
	  read,' Enter name of PNG image file: ',file
	  if file eq '' then return
	endif
 
	;-------  Defaults  -----------
	if n_elements(qf) eq 0 then qf=100
	if n_elements(mag) eq 0 then mag=1
 
	;-------  Read GIF image  -----------
	print,' Reading PNG image '+file+' . . .'
	img = read_png(file, r, g, b)
	if (!version.release+0.) le 5.3 then begin
	  img = img_rotate(img,7)
	endif
	if mag ne 1 then begin
	  print,' Changing size by a factor of '+strtrim(mag,2)
	  img = img_resize(img,mag=mag)
	endif
	if (size(img))(0) eq 2 then begin
          rr = r(img)
          gg = g(img)
          bb = b(img)
	endif else begin
	  img_split, img, rr, gg, bb
	endelse
	cc = img_merge(rr,gg,bb,tr=3)
 
	;-------  Write JPEG  -----------
	filebreak, file, dir=dir, name=name
	out = filename(dir,name+'.jpg',/nosym)
	print,' Writing JPEG image '+out+' . . .'
        write_jpeg, out, cc, true=3, quality=qf
 
	print,' Converted PNG image '+file
	print,'   to JPEG image '+out
 
	return
	end
