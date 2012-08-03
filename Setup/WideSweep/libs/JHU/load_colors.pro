;-------------------------------------------------------------
;+
; NAME:
;       LOAD_COLORS
; PURPOSE:
;       Load a color table with a standard range of colors.
; CATEGORY:
; CALLING SEQUENCE:
;       load_colors
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Useful when 8-bit color is being used (PostScript
;         for example).  Loads color table with a wide range of
;         hue, saturation, and value.  Can use the function tarclr
;         to pick a target color.  Grays shades from black to white
;         are 0 to 63 in the table.  Scale to this range to show a
;         B&W gray scale image.  Ex: tv,ls(img)/4
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 27
;       R. Sterner, 2004 Jun 03 --- Increased B&W area to 64 shades.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro load_colors, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Load a color table with a standard range of colors.'
	  print,' load_colors'
	  print,'   No args.'
	  print,' Notes: Useful when 8-bit color is being used (PostScript'
	  print,'   for example).  Loads color table with a wide range of'
	  print,'   hue, saturation, and value.  Can use the function tarclr'
	  print,'   to pick a target color.  Grays shades from black to white'
	  print,'   are 0 to 63 in the table.  Scale to this range to show a'
	  print,'   B&W gray scale image.  Ex: tv,ls(img)/4'
	  return
	endif
 
	in = 0				; Color table index.
 
	loadct,0			; Start with gray scale.
 
	;-----  Load 64 gray shades  ------
	vv = maken(0.,1.,64)
	for i=0,63 do begin
	  color_convert, 0,0,vv(i),r,g,b,/hsv_rgb
	  tvlct,r,g,b,in
	  in = in + 1
	endfor
 
	;-----  Load colors  -------
	hh = maken(0,330,12)		; Hues.
	ss = maken(0.25,1.00,4)		; Sats.
	vv = maken(0.25,1.00,4)		; Vals.
	for ih=0,11 do begin
	  h = hh(ih)			; Next hus.
	  for iv=0,3 do begin
	    v = vv(iv)			; Next value.
	    if v gt .25 then begin	; Sat loop only for brighter colors.
	      for is=0,3 do begin
	        s = ss(is)		; Next saturation.
		color_convert,h,s,v,r,g,b,/hsv_rgb	; Convert from HSV.
		tvlct,r,g,b,in		; Load color to color table.
		in = in + 1		; Next table index.
	      endfor ; iv
	    endif ; v gt .25
	  endfor ; is
	endfor ; ih
 
	print,' Colors loaded. B&W area: 0-63. User area from '+ $
	  strtrim(in,2)+' to 255.'
 
	end
