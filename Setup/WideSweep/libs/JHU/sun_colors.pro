;-------------------------------------------------------------
;+
; NAME:
;       SUN_COLORS
; PURPOSE:
;       Load sun color table
; CATEGORY:
; CALLING SEQUENCE:
;       sun_colors
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEEPER means use deeper colors.
;         /QUANTIZED means show day colors in 10 degree bands.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: loads color table from sun_colors.txt
;         or sun_colors0.txt (more saturated)
;         in routine source directory.
;         Colors above index 185 are untouched.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Sep 17
;       R. Sterner, 1997 Dec 30 --- converted color table to a text file.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;       R. Sterner, 1999 Oct 14 --- Added original more saturated colors.
;       R. Sterner, 2000 Sep 19 --- Added 10 degree banded color tables.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro sun_colors, deeper=deep, quantized=quant, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Load sun color table'
	  print,' sun_colors'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   /DEEPER means use deeper colors.'
	  print,'   /QUANTIZED means show day colors in 10 degree bands.'
	  print,' Notes: loads color table from sun_colors.txt'
	  print,'   or sun_colors0.txt (more saturated)'
	  print,'   in routine source directory.'
	  print,'   Colors above index 185 are untouched.'
	  return	
	endif
 
	whoami, dir
	if keyword_set(deep) then begin
	  if keyword_set(quant) then $
	    f = filename(dir,'sun_colors0_10.txt',/nosym) else $
	    f = filename(dir,'sun_colors0.txt',/nosym)
	endif else begin
	  if keyword_set(quant) then $
	    f = filename(dir,'sun_colors_10.txt',/nosym) else $
	    f = filename(dir,'sun_colors.txt',/nosym)
	endelse
	openr,lun,f,/get_lun
	a = bytarr(3,181)
	readf,lun,a
	free_lun,lun
	tvlct,a(0,*),a(1,*),a(2,*)
	tvlct,0,0,0,topc()		; Make last color black.
 
	return
	end
