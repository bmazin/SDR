;-------------------------------------------------------------
;+
; NAME:
;       TOPCOLORS
; PURPOSE:
;       Reserve and define some colors at top of color table.
; CATEGORY:
; CALLING SEQUENCE:
;       topcolors
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         TOP=top  Returned top available image color.
;         PUT_HUE=s  Specified starting index for reserved colors.
;           By default reserved colors start at top+1.
;         /REMAP   Means remap current color table to new range.
;         HUE=hue  Returned index table of hues. The pure colors are:
;           color=hue(0) gives white.
;           color=hue(1) gives red.
;           color=hue(2) gives yellow.
;           color=hue(3) gives green.
;           color=hue(4) gives cyan.
;           color=hue(5) gives blue.
;           color=hue(6) gives magenta.
;           Hue-1: darker, Hue-2: darkest, Hue+1: pale, Hue+2: palest
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Example use:
;         Load desired color table: loadct, 4
;         Remap and reserve colors: topcolors,top=top,hue=hue,/remap
;         Display image using bytscl: tv,bytscl(img,top=top).
;         Make a dark blue background: erase, hue(5)-2
;         Make a pale red plot: plot,x,y,color=hue(1)+1,/noerase
; MODIFICATION HISTORY:
;       R. Sterner, 9 Dec, 1993
;       R. Sterner, 1994 Jan 12 --- Added PUT_HUE keyword.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro topcolors, top=top, hue=hue, remap=remap, put_hue=put, help=hlp
 
	if keyword_set(hlp) then begin 
	  print,' Reserve and define some colors at top of color table.'
	  print,' topcolors'
	  print,'   All args are keywords.'
 	  print,' Keywords:'
	  print,'   TOP=top  Returned top available image color.'
	  print,'   PUT_HUE=s  Specified starting index for reserved colors.'
	  print,'     By default reserved colors start at top+1.'
	  print,'   /REMAP   Means remap current color table to new range.'
	  print,'   HUE=hue  Returned index table of hues. The pure colors are:'
	  print,'     color=hue(0) gives white.'
	  print,'     color=hue(1) gives red.'
	  print,'     color=hue(2) gives yellow.'
	  print,'     color=hue(3) gives green.'
	  print,'     color=hue(4) gives cyan.'
	  print,'     color=hue(5) gives blue.'
	  print,'     color=hue(6) gives magenta.'
	  print,'     Hue-1: darker, Hue-2: darkest, Hue+1: pale, Hue+2: palest'
	  print,' Notes: Example use:'
	  print,'   Load desired color table: loadct, 4'
	  print,'   Remap and reserve colors: topcolors,top=top,hue=hue,/remap'
	  print,'   Display image using bytscl: tv,bytscl(img,top=top).'
	  print,'   Make a dark blue background: erase, hue(5)-2'
	  print,'   Make a pale red plot: plot,x,y,color=hue(1)+1,/noerase'
	  return
	endif
 
	top = !d.table_size - 35	; There are 35 reserved colors.
	if n_elements(put) eq 0 then put=top+1
	hue = indgen(7)*5 + put + 2	; Color indices of the 7 pure colors.
 
	;-------  Remap current color table  -----------
	if keyword_set(remap) then begin
	  tvlct,r,g,b,/get		; read back current table.
	  rr = congrid(r,top+1)
	  gg = congrid(g,top+1)
	  bb = congrid(b,top+1)
	  tvlct,rr,gg,bb
	endif
 
	;-------  Generate reserved colors  ------------
	h = fltarr(5)			; White.
	s = fltarr(5)
	v = [1./3.,2./3.,1.,1.,1.]
	hc = [0,findgen(6)*60.]
	for i = 1, 6 do begin		; Handle colors.
	  h = [h,findgen(5)+hc(i)]
	  s = [s,1.,1.,1.,2./3.,1./3.]
	  v = [v,1./3.,2./3.,1.,1.,1.]
	endfor
	tvlct,h,s,v,/hsv,put
 
	return
	end
