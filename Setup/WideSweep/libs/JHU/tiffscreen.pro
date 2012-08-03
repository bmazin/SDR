;-------------------------------------------------------------
;+
; NAME:
;       TIFFSCREEN
; PURPOSE:
;       Save current screen image and color table to a TIFF file.
; CATEGORY:
; CALLING SEQUENCE:
;       tiffscreen, [file]
; INPUTS:
;       file = name of TIFF file.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Prompts for file if called with no args.
; MODIFICATION HISTORY:
;       R. Sterner, 1 Jun, 1993
;       R. Sterner, 2003 Mar 21 --- Upgraded for 24-bit color.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro tiffscreen, file, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Save current screen image and color table to a TIFF file.'
	  print,' tiffscreen, [file]'
	  print,'   file = name of TIFF file.   in'
	  print,' Notes: Prompts for file if called with no args.'
	  return
	endif
 
	if n_elements(file) eq 0 then begin
	  print,' '
	  print,' Save current screen image and color table to a TIFF file.'
	  file = ''
	  read,' Enter name of TIFF file: ',file
	  if file eq '' then return
	endif
 
	;---------  Handle file name  -------------
	filebreak,file,dir=dir,name=name,ext=ext
	if ext eq '' then begin
	  print,' Adding .tif as the file extension.'
	  ext = 'tif'
	endif
	if ext ne 'tif' then begin
	  print,' Warning: non-standard extension: '+tif
	  print,' Standard extension is tif.'
	endif
	name = name + '.' + ext
	fname = filename(dir,name,/nosym)
 
	;--------  Read screen image  -----------
	a = tvrd(tr=1)
 
	;--------  Write tiff file  -------------
	write_tiff,fname,a,orient=0
 
	print,' Image saved in TIFF file '+fname+'.'
	return
 
	end
