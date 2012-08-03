;-------------------------------------------------------------
;+
; NAME:
;       LATEXOFF
; PURPOSE:
;       Close the encapsulated Postscript file opened by LATEXON.
; CATEGORY:
; CALLING SEQUENCE:
;       latexoff
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       latex_com
; NOTES:
;       Notes: keep track of the plot shape listed by latexoff.
;         To avoid distortion use this same shape for LaTeX figures.
; MODIFICATION HISTORY:
;       R. Sterner, 14 Sep 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro latexoff, help=hlp
 
	common latex_com, file, dname, x, y, p, s1
 
	if keyword_set(hlp) then begin
	  print,' Close the encapsulated Postscript file opened by LATEXON.'
	  print,' latexoff'
	  print,' Notes: keep track of the plot shape listed by latexoff.'
	  print,'   To avoid distortion use this same shape for LaTeX figures.'
	  return
	endif
 
	;------  Get new plot shape  ---------
	if (!x.window(0) eq 0.) and (!x.window(1) eq 0.) then begin
	  print,' Warning in latexoff: you really should plot something.'
	  txt = ' But file contains no plots.'
	endif else begin
	  dx2 = !d.x_size*(!x.window(1) - !x.window(0))/!d.x_px_cm
	  dy2 = !d.y_size*(!y.window(1) - !y.window(0))/!d.y_px_cm
	  s2 = dx2/dy2
	  txt = ' Use the following shape for LaTeX \insertplot '+$
	    '(graphs only): '+strtrim(1.4*s1/s2,2)+' X 1'
	endelse
 
	;------  Close plot file  -------
	device, /close
	print,' '
	print,' The encapsulated PS file '+file+' is complete.'
	print, txt
	print,' '
 
	;-------  Restore graphics setup  --------
	set_plot,dname
	!x = x
	!y = y
	!p = p
 
	return
	end
