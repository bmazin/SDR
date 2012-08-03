;-------------------------------------------------------------
;+
; NAME:
;       IMG_MAP_IMAGE
; PURPOSE:
;       Do map_image for a 24 bit color image.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_map_image(img,ix,iy, xsz, ysz)
; INPUTS:
;       img = input image.                           in
; KEYWORD PARAMETERS:
;       Keywords:
;         Any map_image keywords map be given.
;         /NODISPLAY means just return results, do not display
;           them.  Otherwise the image will be displayed.
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
;       ix,iy = optionally returned startx, starty.  out
;       xsz,ysz = optionally returned xsize, ysize.  out
;       out = returned remapped image.               out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Oct 30
;       R. Sterner, 2004 Jan 06 --- Now returns result without /NODISPLAY.
;       R. Sterner, 2006 Nov 06 --- Handled 2-D image case.
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_map_image, img, startx, starty, xsize, ysize, $
	  error=err,_extra=extra, nodisplay=nodisp, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Do map_image for a 24 bit color image.'
	  print,' out = img_map_image(img,ix,iy, xsz, ysz)'
	  print,'   img = input image.                           in'
	  print,'   ix,iy = optionally returned startx, starty.  out'
	  print,'   xsz,ysz = optionally returned xsize, ysize.  out'
	  print,'   out = returned remapped image.               out'
	  print,' Keywords:'
	  print,'   Any map_image keywords map be given.'
	  print,'   /NODISPLAY means just return results, do not display'
	  print,'     them.  Otherwise the image will be displayed.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  return,''
	endif
 
	;------  2-D or 3-D ?  ---------------------
	img_shape, img, true=tr
 
	;------  Handle 2-D case  -----------------
	if tr eq 0 then begin
	  out = map_image(img, startx, starty, xsize, ysize, _extra=extra)
	  if keyword_set(nodisp) then return, out
	  tv, out, startx, starty, true=tr
	  return, out
	endif
 
	;------  Split input images  ---------------
	img_split, img, r, g, b, tr=tr, err=err
	if err ne 0 then return, -1
 
	;-------  Do map_image on components  -------
	rr = map_image(r, startx, starty, xsize, ysize, _extra=extra)
	gg = map_image(g, startx, starty, xsize, ysize, _extra=extra)
	bb = map_image(b, startx, starty, xsize, ysize, _extra=extra)
 
	;-------  Merge color channels back into a 24-bit image  -------
	out = img_merge(rr,gg,bb,true=tr)
	if keyword_set(nodisp) then return, out
 
	;-------  Display result  ---------
	tv, out, startx, starty, true=tr
	return, out
 
	end
