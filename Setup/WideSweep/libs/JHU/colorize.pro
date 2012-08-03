;-------------------------------------------------------------
;+
; NAME:
;       COLORIZE
; PURPOSE:
;       Colorize an image.
; CATEGORY:
; CALLING SEQUENCE:
;       colorize
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         IMAGE=img  Name of GIF image to colorize.
;         COLORS=clr Name of GIF image with color areas to overlay.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Result is displayed on screen.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Aug 17
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro colorize, image=img, colors=clr, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Colorize an image.'
	  print,' colorize'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   IMAGE=img  Name of GIF image to colorize.'
	  print,'   COLORS=clr Name of GIF image with color areas to overlay.'
	  print,' Notes: Result is displayed on screen.'
	  return
	endif
 
	;---  Read image image to process and image with color areas  -----
	print,' Raeding images . . .'
	read_gif, img, aa, r, g, b & ra=r(aa) & ga=g(aa) & ba=b(aa)
	read_gif, clr, bb, r, g, b & rb=r(bb) & gb=g(bb) & bb=b(bb)
 
	;---  Work in HSV space  ----------------------
	print,' Converting to HSV . . .'
	color_convert, ra, ga, ba, ha, sa, va, /rgb_hsv
	color_convert, rb, gb, bb, hb, sb, vb, /rgb_hsv
 
	;---  Find areas to replace  ------------------
	w = where(vb gt 0, cnt)
	if cnt eq 0 then begin
	  print,' No colored areas found in color image '+clr
	  return
	endif
 
	;-----  Colorize  --------------------
	print,' Colorizing . . .'
	ha(w) = hb(w)		; Copy hue
	sa(w) = sb(w)		; and Sat.
 
	;-----  Convert back to final image  --------
	color_convert, ha, sa, va, ra2, ga2, ba2, /hsv_rgb
 
	;-----  Save as a JPEG  ---------------
	filebreak, img, name=out1
	filebreak, clr, name=out2
	out = out1+'_'+out2+'.jpg'
	print,' Saving as '+out+' . . .'
	write_jpeg,out, [[[ra2]],[[ga2]],[[ba2]]], true=3
 
	;------  Display  ----------------
	print,' Displaying . . .'
	screenjpeg, out
 
	end
