;-------------------------------------------------------------
;+
; NAME:
;       COLORS8BIT
; PURPOSE:
;       Show array of 256 colors in a window.
; CATEGORY:
; CALLING SEQUENCE:
;       colors8bit
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         BLACK=blk  Specify black or dark color (def=0).
;         WHITE=wht  Specify white or bright color (def=1).
;           These are used for the index numbers.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: useful to pick colors from the window systems
;       colors in case IDL cannot control the colors.  For
;       example, when using 256 colors on a workstation and
;       a widget, the IDL colors will not show up while using
;       the widget.  This may make it impossible to use the
;       widget.  One work around is to use good window colors
;       for the IDL graphics.  For example, window color 23
;       may be white and 32 blue.  If XOR mode graphics is used
;       then XOR 55 with 23 to get 32 (32 = 23 xor 55).  If the
;       background color is bck and you want plot color clr then
;       just plot (bck XOR clr), where the plot crosses the
;       background it will be that color.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 May 12
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro colors8bit, help=hlp, black=blk, white=wht
 
	if keyword_set(hlp) then begin
	  print,' Show array of 256 colors in a window.'
	  print,' colors8bit'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   BLACK=blk  Specify black or dark color (def=0).'
	  print,'   WHITE=wht  Specify white or bright color (def=1).'
	  print,'     These are used for the index numbers.'
	  print,' Notes: useful to pick colors from the window systems'
	  print,' colors in case IDL cannot control the colors.  For'
	  print,' example, when using 256 colors on a workstation and'
	  print,' a widget, the IDL colors will not show up while using'
	  print,' the widget.  This may make it impossible to use the'
	  print,' widget.  One work around is to use good window colors'
	  print,' for the IDL graphics.  For example, window color 23'
	  print,' may be white and 32 blue.  If XOR mode graphics is used'
	  print,' then XOR 55 with 23 to get 32 (32 = 23 xor 55).  If the'
	  print,' background color is bck and you want plot color clr then'
	  print,' just plot (bck XOR clr), where the plot crosses the'
	  print,' background it will be that color.'
	  return
	endif
 
	if n_elements(blk) eq 0 then blk=0
	if n_elements(wht) eq 0 then wht=1
 
	window,/free,xs=640,ys=640
 
	b = bytarr(40,40)
	for i=0, 255 do begin
	  tv,b+i,i
	  tvpos, b, i, ix,iy
	  xyoutb,ix+20,iy+5,/dev,bold=[5,1],col=[blk,wht],strtrim(i,2), $
	    chars=1.5, align=.5
	endfor
 
	return
	end
