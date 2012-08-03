;-------------------------------------------------------------
;+
; NAME:
;       REGIONSBAR
; PURPOSE:
;       Plot a color bar for a regions type image.
; CATEGORY:
; CALLING SEQUENCE:
;       regionsbar, v
; INPUTS:
;       v = array of region breakpoints.     in
; KEYWORD PARAMETERS:
;       Keywords:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 6 Mar, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro regionsbar, v, help=hlp
 
	if (n_params() lt 1) or keyword_set(help) then begin
	  print,' Plot a color bar for a regions type image.'
	  print,' regionsbar, v'
	  print,'   v = array of region breakpoints.     in'
	  print,' Keywords:'
	  return
	endif
 
	n = n_elements(v)
 
	print,' Use mouse to position box.'
	print,' Button 1 toggles between move box/change box size.'
	print,' Button 2 aborts.'
	print,' Button 3 draws color bar.'
 
	movbox, x, y, dx, dy, c
	if c eq 2 then return
 
	dbx = dx
	dby = dy/(n+1.)
	t = bytscl(makei(0,n,1))
 
	tv, bytarr(dx+2,dy+2)+255, x-1, y-1
	for i = 0, n do begin
	  tv, bytarr(dbx, dby)+t(i), x, y+dby*i
	endfor
 
	for i = 0, n-1 do begin
	  xyouts, x+dbx+5, y+dby*(i+1), /dev, strtrim(v(i),2)
	endfor
 
	return
	end
	
