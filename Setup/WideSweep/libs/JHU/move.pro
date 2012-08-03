;-------------------------------------------------------------
;+
; NAME:
;       MOVE
; PURPOSE:
;       Graphics move to a point.
; CATEGORY:
; CALLING SEQUENCE:
;       move, x, y
; INPUTS:
;       x,y = scalar coordinates of point to move to.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       move_com
; NOTES:
;       Note: see draw.
; MODIFICATION HISTORY:
;       R. Sterner, 22 Jan, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro move, x, y, help=hlp
 
	common move_com, lstx, lsty
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Graphics move to a point.'
	  print,' move, x, y'
	  print,'   x,y = scalar coordinates of point to move to.   in'
	  print,' Note: see draw.'
	  return
	endif
 
	lstx = x
	lsty = y
	return
	end
