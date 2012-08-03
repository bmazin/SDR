;-------------------------------------------------------------
;+
; NAME:
;       TODEV
; PURPOSE:
;       Convert from data or normalized to device coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       todev,x1,y1,x2,y2
; INPUTS:
;       x1,y1 = input coordinates.                in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA if x1,y1 are data coordinates (default).
;         /NORM if x1,y1 are normalized coordinates.
; OUTPUTS:
;       x2,y2 = device coordinates.               out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 21 June 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro todev, x1, y1, x2, y2, data=dt, normalized=nrm, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert from data or normalized to device coordinates.'
	  print,' todev,x1,y1,x2,y2'
	  print,'   x1,y1 = input coordinates.                in'
	  print,'   x2,y2 = device coordinates.               out'
	  print,' Keywords:'
	  print,'   /DATA if x1,y1 are data coordinates (default).'
	  print,'   /NORM if x1,y1 are normalized coordinates.'
	  return
	endif
 
 
	if keyword_set(nrm) then begin
	  x2 = x1*!d.x_size
	  y2 = y1*!d.y_size
	  return
	endif
 
;	x2 = !d.x_size*(!x.s(0) + !x.s(1)*x1)
;	y2 = !d.y_size*(!y.s(0) + !y.s(1)*y1)
 
	tmp = convert_coord(x1,y1,/data,/to_device)
	x2 = tmp(0,*)
	y2 = tmp(1,*)
 
	if n_elements(x2) eq 1 then begin
 	 x2 = x2(0)
 	 y2 = y2(0)
	endif
 
	return
 
	end
