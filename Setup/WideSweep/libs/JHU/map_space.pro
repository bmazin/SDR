;-------------------------------------------------------------
;+
; NAME:
;       MAP_SPACE
; PURPOSE:
;       Set any points off a generated map to white.
; CATEGORY:
; CALLING SEQUENCE:
;       map_space
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Works for maps made using map_set.
;         Only changes points inside map window.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jan 29
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_space, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Set any points off a generated map to white.'
	  print,' map_space'
	  print,'   No args.'
	  print,' Notes: Works for maps made using map_set.'
	  print,'   Only changes points inside map window.'
	  return
	endif
 
	maplatlong,space=space
	if space.in(0) ge 0 then begin
	  print,' Processing points off map.'
	  tmp = tvrd(space.ix, space.iy, space.nx, space.ny,tr=3)
	  img_split,tmp,r,g,b
	  r(space.in)=255 & g(space.in)=255 & b(space.in)=255
	  tmp2 = img_merge(r,g,b)
	  tv,tmp2,tr=3,space.ix, space.iy
	endif
 
	end
