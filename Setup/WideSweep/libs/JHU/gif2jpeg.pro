;-------------------------------------------------------------
;+
; NAME:
;       GIF2JPEG
; PURPOSE:
;       Convert a GIF image to a JPEG image.
; CATEGORY:
; CALLING SEQUENCE:
;       gif2jpeg, file
; INPUTS:
;       file = GIF image file name.       in
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
;       R. Sterner, 1996 May 4
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro gif2jpeg, file, qf=qf, mag=mag, jpeg=out, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Convert a GIF image to a JPEG image.'
	  print,' gif2jpeg, file'
	  print,'   file = GIF image file name.       in'
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
	  print,' Convert a GIF image to a JPEG image.'
	  file = ''
	  read,' Enter name of GIF image file: ',file
	  if file eq '' then return
	endif
 
	;-------  Defaults  -----------
	if n_elements(qf) eq 0 then qf=100
	if n_elements(mag) eq 0 then mag=1
 
	;-------  Read GIF image  -----------
	print,' Reading GIF image '+file+' . . .'
	read_gif, file, img, r, g, b
	sz = size(img)
	if mag ne 1 then begin
	  print,' Changing size by a factor of '+strtrim(mag,2)
	  img = congrid(img,sz(1)*mag,sz(2)*mag)
	endif
        rr = r(img)
        gg = g(img)
        bb = b(img)
 
	;-------  Write JPEG  -----------
	filebreak, file, dir=dir, name=name
	out = filename(dir,name+'.jpg',/nosym)
	print,' Writing JPEG image '+out+' . . .'
        cc = [[[rr]],[[gg]],[[bb]]]
        write_jpeg, out, cc, true=3, quality=qf
 
	print,' Converted GIF image '+file
	print,'   to JPEG image '+out
 
	return
	end
