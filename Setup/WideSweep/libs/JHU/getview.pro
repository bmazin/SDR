;-------------------------------------------------------------
;+
; NAME:
;       GETVIEW
; PURPOSE:
;       Return current viewport.
; CATEGORY:
; CALLING SEQUENCE:
;       getview, vx1, vx2, vy1, vy2
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       vx1, vx2, vy1, vy2 = current viewport.	out.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 11 Nov, 1988.
;       R. Sterner, 26 Feb, 1991 --- renamed from get_viewport.pro
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro getview, vx1, vx2, vy1, vy2,help=hlp
 
	if (n_params(0) lt 4) or (keyword_set(hlp)) then begin
	  print,' Return current viewport.'
	  print,' getview, vx1, vx2, vy1, vy2'
	  print,'   vx1, vx2, vy1, vy2 = current viewport.	out.
	  return
	endif
 
	sc1 = !sc1 & sc2 = !sc2 & sc3 = !sc3 & sc4 = !sc4
 
	set_viewport, 0, 1, 0, 1
	vx1 = sc1/!sc2
	vx2 = sc2/!sc2
	vy1 = sc3/!sc4
	vy2 = sc4/!sc4
 
	set_screen, sc1, sc2, sc3, sc4
 
	return
	end
