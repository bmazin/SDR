;-------------------------------------------------------------
;+
; NAME:
;       JPEGSCREEN
; PURPOSE:
;       Save current screen image and color table to a JPEG file.
; CATEGORY:
; CALLING SEQUENCE:
;       jpegscreen, [file]
; INPUTS:
;       file = name of JPEG file.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         QUALITY=q  JPEG quality value (0=bad, 100=best, def=75).
;           Low values give better compression but poorer quality.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Prompts for file if called with no args.
;         Also works for z-buffer.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Jan 17
;       R. Sterner, 2000 Jun 29 --- Modified for 24 bit color.
;       R. Sterner, 2002 Jun 18 --- Modified to allow Z-Buffer.
;       R. Sterner, 2002 Jun 26 --- Used get_visual_name to make X independent.
;       R. Sterner, 2006 Jul 11 --- Fixed extension warning.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro jpegscreen, file, quality=q, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Save current screen image and color table to a JPEG file.'
	  print,' jpegscreen, [file]'
	  print,'   file = name of JPEG file.   in'
	  print,' Keywords:'
	  print,'   QUALITY=q  JPEG quality value (0=bad, 100=best, def=75).'
	  print,'     Low values give better compression but poorer quality.'
	  print,' Notes: Prompts for file if called with no args.'
	  print,'   Also works for z-buffer.'
	  return
	endif
 
	if n_elements(q) eq 0 then q=75
 
	if n_elements(file) eq 0 then begin
	  print,' '
	  print,' Save current screen image and color table to a JPEG file.'
	  file = ''
	  read,' Enter name of JPEG file: ',file
	  if file eq '' then return
	endif
 
	;---------  Handle file name  -------------
	filebreak,file,dir=dir,name=name,ext=ext
	if ext eq '' then begin
	  print,' Adding .jpg as the file extension.'
	  ext = 'jpg'
	endif
	if ext ne 'jpg' then begin
	  print,' Warning: non-standard extension: '+ext
	  print,' Standard extension is jpg.'
	endif
	name = name + '.' + ext
	fname = filename(dir,name,/nosym)
 
	;-------  Determine if true or pseudo color  ------
	if !d.name eq 'Z' then begin
	  vflag = 0			; Treat z-buffer like PseudoColor.
	endif else begin
;          device, get_visual_name=vis	; Get visual type.
	  get_visual_name, vis		; Get visual type.
          vflag = vis ne 'PseudoColor'	; 0 if PseudoColor.
	endelse
 
	;--------  Read screen image and color table   -----------
	if vflag eq 0 then begin	; 8 bit image.
	  a = tvrd()
	  tvlct,r,g,b,/get
	  ;---------  Repackage as 24 bit image  ----------
	  sz=size(a) & nx=sz(1) & ny=sz(2)	; Size.
	  img = bytarr(nx,ny,3)
	  img(0,0,0) = r(a)		; Extract and insert red component.
	  img(0,0,1) = g(a)		; Extract and insert grn component.
	  img(0,0,2) = b(a)		; Extract and insert blu component.
	endif else begin
	  img = tvrd(true=3)		; 24 bit color.
	endelse
 
	;--------  Write JPEG file  -------------
	write_jpeg,fname,img,true=3,quality=q
 
	print,' Image saved in JPEG file '+fname+'.'
	return
 
	end
