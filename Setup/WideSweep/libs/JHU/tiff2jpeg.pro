;-------------------------------------------------------------
;+
; NAME:
;       TIFF2JPEG
; PURPOSE:
;       Convert a TIFF image to a JPEG image.
; CATEGORY:
; CALLING SEQUENCE:
;       tiff2jpeg, file
; INPUTS:
;       file = TIFF image file name.       in
;         Prompted for if not given.
; KEYWORD PARAMETERS:
;       Keywords:
;         QF=qf  JPEG quality factor (def=100).
;           Since color improvement is the goal here qf is
;           set to the max value of 100 by default.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Intended to convert 24 bit TIFF images to JPEG
;         format since they display better.
;         Output file name is same as input but with .jpg as type.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 May 19
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro tiff2jpeg, file, qf=qf, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Convert a TIFF image to a JPEG image.'
	  print,' tiff2jpeg, file'
	  print,'   file = TIFF image file name.       in'
	  print,'     Prompted for if not given.'
	  print,' Keywords:'
	  print,'   QF=qf  JPEG quality factor (def=100).'
	  print,'     Since color improvement is the goal here qf is'
	  print,'     set to the max value of 100 by default.'
	  print,' Notes: Intended to convert 24 bit TIFF images to JPEG'
	  print,'   format since they display better.'
	  print,'   Output file name is same as input but with .jpg as type.'
	  return
	endif
 
	if n_elements(file) eq 0 then begin
	  print,' Convert a TIFF image to a JPEG image.'
	  file = ''
	  read,' Enter name of TIFF image file: ',file
	  if file eq '' then return
	endif
 
	;-------  Read TIFF image  -----------
	print,' Reading TIFF image '+file+' . . .'
	img = tiff_read(file, r, g, b, order=order)
	sz = size(img)
        if sz(0) eq 3 then begin
          print,' Handling 24 bit image . . .'
          rr = reform(img(0,*,*))
          gg = reform(img(1,*,*))
          bb = reform(img(2,*,*))
	endif
	if order eq 1 then begin
	  print,' Reversing in Y . . .'
	  rr = reverse(rr,2)
	  gg = reverse(gg,2)
	  bb = reverse(bb,2)
	endif
 
	;-------  Write JPEG  -----------
	if n_elements(qf) eq 0 then qf=100
	filebreak, file, dir=dir, name=name
	out = filename(dir,name+'.jpg',/nosym)
	print,' Writing JPEG image '+out+' . . .'
        cc = [[[rr]],[[gg]],[[bb]]]
        write_jpeg, out, cc, true=3, quality=qf
 
	print,' Converted TIFF image '+file+' to JPEG image '+out
 
	return
	end
