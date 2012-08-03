;-------------------------------------------------------------
;+
; NAME:
;       PSPAPER
; PURPOSE:
;       Plot a postscript layout sheet. Gives normalized coordinate system.
; CATEGORY:
; CALLING SEQUENCE:
;       pspaper
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Call psinit with desired page format and margin.
;       Then call pspaper.
; MODIFICATION HISTORY:
;       R. Sterner, 31 Aug, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro pspaper, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Plot a postscript layout sheet. Gives normalized '+$
	    'coordinate system.'
	  print,' pspaper'
	  print,'   No args.'
	  print,' Note: Call psinit with desired page format and margin.'
	  print,' Then call pspaper.'
	  return
	endif
 
	for x = 0., 1.01, .1 do begin
	  plots,[x,x],[0.,1.], /normal
	  xyouts, x, -.01, string(x,format='(f4.2)'),alignment=.5,size=.5, $
	    /normal
	endfor
 
	for y = 0., 1.01, .1 do begin
	  plots,[0.,1.],[y,y], /normal
	  xyouts, 1.01, y, string(y,format='(f4.2)'),size=.5, /normal
	endfor
 
	for x = 0., 1., .02 do plots,[x,x],[0.,1.], linestyle=1, /normal
	for y = 0., 1., .02 do plots,[0.,1.],[y,y], linestyle=1, /normal
 
	xyouts, .5, 1.01, 'Normalized coordinate system', alignment=.5,/normal
 
	psterm
 
	return
	end
