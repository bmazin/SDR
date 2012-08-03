;-------------------------------------------------------------
;+
; NAME:
;       TVCRS2
; PURPOSE:
;       Like tvcr but allows data, device, & normal coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       tvcrs2, [on_off] or tvcrs2, x, y
; INPUTS:
;       on_off = 0: turn cursor off, 1: turn cursor on.      in
;       x, y = Position cursor at x,y and turn on.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA    x and y are in data coordinates.
;         /DEVICE  x and y are in device coordinates (default).
;         /NORMAL  x and y are in normal coordinates.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Feb 26
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro tvcrs2, x0, y0, data=dat0, device=dev0, normal=nrm0, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Like tvcr but allows data, device, & normal coordinates.'
	  print,' tvcrs2, [on_off] or tvcrs2, x, y'
	  print,'   on_off = 0: turn cursor off, 1: turn cursor on.      in'
 	  print,'   x, y = Position cursor at x,y and turn on.           in'
	  print,' Keywords:'
	  print,'   /DATA    x and y are in data coordinates.'
	  print,'   /DEVICE  x and y are in device coordinates (default).'
	  print,'   /NORMAL  x and y are in normal coordinates.'
	  return
	endif
 
	if n_params(0) eq 1 then begin
	  tvcrs, x0
	  return
	endif
 
	dat = keyword_set(dat0)
	dev = keyword_set(dev0)
	nrm = keyword_set(nrm0)
 
	if (dat eq 0) and (dev eq 0) and (nrm eq 0) then dev=1
 
	if keyword_set(dat) then begin
	  tmp = round(convert_coord(x0,y0,/data,/to_dev))
          x=tmp(0,0) & y=tmp(1,0)
	  tvcrs,x,y
	  return
        endif
 
	if keyword_set(dev) then begin
	  tvcrs,x0,y0
	  return
        endif
 
	if keyword_set(nrm) then begin
	  tmp = round(convert_coord(x0,y0,/norm,/to_dev))
          x=tmp(0,0) & y=tmp(1,0)
	  tvcrs,x,y
	  return
        endif
 
	end
