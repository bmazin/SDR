;-------------------------------------------------------------
;+
; NAME:
;       PLOT_POSBOX
; PURPOSE:
;       Plot position box in window.
; CATEGORY:
; CALLING SEQUENCE:
;       plot_posbox, pos
; INPUTS:
;       pos = Position array = [xmn,ymn,xmx,ymx].   in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr  Plot color.
;         THICK=thk  Plot thickness.
;         /DEVICE  pos is in device coordinates (else normalzied).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Feb 28
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro plot_posbox, pos, device=dev, color=clr, thick=thk, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot position box in window.'
	  print,' plot_posbox, pos'
	  print,'   pos = Position array = [xmn,ymn,xmx,ymx].   in'
	  print,' Keywords:'
	  print,'   COLOR=clr  Plot color.'
	  print,'   THICK=thk  Plot thickness.'
	  print,'   /DEVICE  pos is in device coordinates (else normalzied).'
	  return
	endif
 
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(thk) eq 0 then thk=!p.thick
 
	xmn = pos[0]
	ymn = pos[1]
	xmx = pos[2]
	ymx = pos[3]
	if not keyword_set(dev) then begin
	  xmn = fix(xmn*!d.x_size)
	  ymn = fix(ymn*!d.y_size)
	  xmx = fix(xmx*!d.x_size)
	  ymx = fix(ymx*!d.y_size)
	endif
 
	plots,[xmn,xmx,xmx,xmn,xmn],[ymn,ymn,ymx,ymx,ymn], $
	  /device,col=clr,thick=thk
 
	end
