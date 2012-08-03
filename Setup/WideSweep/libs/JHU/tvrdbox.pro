;-------------------------------------------------------------
;+
; NAME:
;       TVRDBOX
; PURPOSE:
;       Read part of screen image into a byte array.
; CATEGORY:
; CALLING SEQUENCE:
;       tvrdbox, a
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr Set box color (-2 for dotted).
;         /NOERASE prevents last box from being erased first.
;           Good when a new image covers up last box.
;         /EXITERASE means erase box on exit.
;         CODE=c  returns exit code: 4=normal, 2=alternate.
;         X=x, Y=y  Returned device coordinates of LL corner.
; OUTPUTS:
;       a = image read from screen.   out
; COMMON BLOCKS:
;       tvrdbox_com
; NOTES:
;       Notes: See also tvwrbox
; MODIFICATION HISTORY:
;       R. Sterner, 19 Nov, 1989
;       R. Sterner, 1994 Dec 1 --- Added keywords X and Y.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
 
	pro tvrdbox, a, help=hlp, noerase=noer, exiterase=exiterase,$
	  code=code, color=clr, x=x0, y=y0
 
	common tvrdbox_com, xr, yr, dxr, dyr, xw, yw, dxw, dyw
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Read part of screen image into a byte array.'
	  print,' tvrdbox, a'
	  print,'   a = image read from screen.   out'
	  print,' Keywords:'
	  print,'   COLOR=clr Set box color (-2 for dotted).'
	  print,'   /NOERASE prevents last box from being erased first.'
	  print,'     Good when a new image covers up last box.'
	  print,'   /EXITERASE means erase box on exit.'
	  print,'   CODE=c  returns exit code: 4=normal, 2=alternate.'
	  print,'   X=x, Y=y  Returned device coordinates of LL corner.'
	  print,' Notes: See also tvwrbox'
	  return
	endif
 
	if n_elements(xr) eq 0 then xr = 100
	if n_elements(yr) eq 0 then yr = 100
	if n_elements(dxr) eq 0 then dxr = 100
	if n_elements(dyr) eq 0 then dyr = 100
 
	print,' Use right mouse button to read box image.'
	print,' Use middle mouse button for options menu.'
	print,' Use left mouse button to change box size.'
	movbox, xr, yr, dxr, dyr, code, noerase=noer, exiterase=exiterase, $
	  color=clr
	if code eq 4 then a = tvrd(xr,yr,dxr,dyr)
	x0 = xr		; Return lower left corner coordinates.
	y0 = yr
	return
 
	end
