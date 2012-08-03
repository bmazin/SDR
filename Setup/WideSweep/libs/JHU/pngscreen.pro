;-------------------------------------------------------------
;+
; NAME:
;       PNGSCREEN
; PURPOSE:
;       Save current screen image to a PNG file.
; CATEGORY:
; CALLING SEQUENCE:
;       pngscreen, [file]
; INPUTS:
;       file = name of PNG file.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Prompts for file if called with no args.
;         Only for 24-bit color displays.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Mar 21
;       R. Sterner, 2002 Mar 04 --- Worked around v5.3 png bug.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro pngscreen, file, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Save current screen image to a PNG file.'
	  print,' pngscreen, [file]'
	  print,'   file = name of PNG file.   in'
	  print,' Notes: Prompts for file if called with no args.'
	  print,'   Only for 24-bit color displays.'
	  return
	endif
 
	if n_elements(file) eq 0 then begin
	  print,' '
	  print,' Save current screen image to a PNG file.'
	  file = ''
	  read,' Enter name of PNG file: ',file
	  if file eq '' then return
	endif
 
	;---------  Handle file name  -------------
	filebreak,file,dir=dir,name=name,ext=ext
	if ext eq '' then begin
	  print,' Adding .png as the file extension.'
	  ext = 'png'
	endif
	if ext ne 'png' then begin
	  print,' Warning: non-standard extension: '+ext
	  print,' Standard extension is png.'
	endif
	name = name + '.' + ext
	fname = filename(dir,name,/nosym)
 
	;--------  Read screen image  -----------
	if (!version.release+0.) le 5.3 then order=1 else order=0
	a = tvrd(true=1, order=order)
 
	;--------  Write gif file  -------------
	write_png,fname,a
 
	print,' Image saved in PNG file '+fname
	return
 
	end
