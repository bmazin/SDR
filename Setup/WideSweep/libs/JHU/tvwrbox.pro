;-------------------------------------------------------------
;+
; NAME:
;       TVWRBOX
; PURPOSE:
;       Display byte array on screen using box for position & size.
; CATEGORY:
; CALLING SEQUENCE:
;       tvwrbox, a
; INPUTS:
;       a = byte array to write to screen.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /BILINEAR uses bilinear interp. to change array size.
;            Default is nearest neighbor interpolation.
;         /NOERASE prevents last box from being erased.
;            Good when a new image covers up last box.
; OUTPUTS:
; COMMON BLOCKS:
;       tvrdbox_com
; NOTES:
;       Notes: See also tvrdbox
; MODIFICATION HISTORY:
;       R. Sterner, 19 Nov, 1989
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro tvwrbox, a, help=hlp, bilinear=bi, noerase=noer
 
	common tvrdbox_com, xr, yr, dxr, dyr, xw, yw, dxw, dyw
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display byte array on screen using box for position & size.'
	  print,' tvwrbox, a'
	  print,'   a = byte array to write to screen.   in'
	  print,' Keywords:'
	  print,'   /BILINEAR uses bilinear interp. to change array size.'
	  print,'      Default is nearest neighbor interpolation.'
	  print,'   /NOERASE prevents last box from being erased.'
	  print,'      Good when a new image covers up last box.'
	  print,' Notes: See also tvrdbox'
	  return
	endif
 
	if n_elements(xr) eq 0 then xr = 100	; If no read box set default.
	if n_elements(yr) eq 0 then yr = 100
	if n_elements(dxr) eq 0 then dxr = 100
	if n_elements(dyr) eq 0 then dyr = 100
	
	if n_elements(xw) eq 0 then xw = xr	; If no write box, use read box.
	if n_elements(yw) eq 0 then yw = yr
	if n_elements(dxw) eq 0 then dxw = dxr
	if n_elements(dyw) eq 0 then dyw = dyr
 
	print,' Use right mouse button to write box image.'
	print,' Use middle mouse button for options menu.'
	print,' Use left mouse button to change box size.'
	movbox, xw, yw, dxw, dyw, code, noerase=noer
	if code eq 2 then begin			; Was abort write.
	  tvbox, xw, yw, dxw, dyw, -1		; Erase box.
	  return
	endif
 
	if (dxw eq dxr) and (dyw eq dyr) then begin	; Keep same size.
	  tv, a, xw, yw
	  return
	endif
 
	if keyword_set(bi) then begin			; Change size.
	  tv, congrid(a, dxw, dyw, /interp), xw, yw	; Bilinearly interp.
	endif else begin
	  tv, congrid(a, dxw, dyw), xw, yw		; Nearest nbr interp.
	endelse
 
	return
 
	end
