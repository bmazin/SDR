;-------------------------------------------------------------
;+
; NAME:
;       VECFLD
; PURPOSE:
;       Plot a 2-d vector field.
; CATEGORY:
; CALLING SEQUENCE:
;       vecfld, u, v, [l]
; INPUTS:
;       u = 2-d array of vector x components.   in
;         If this array is complex then u and v
;         will be taken as the real and imaginary
;         parts.  v is then not needed and will be ignored.
;       v = 2-d array of vector y components.   in
;       l = Optional max length of vectors.     in
;          Can give this value using keyword VSCALE.
; KEYWORD PARAMETERS:
;       Keywords:
;         /ISO for isotropic plot scale.
;         /MAGNITUDES indicate magnitudes, else direction only.
;         /MARK mark head of vector by a colored symbol.
;         PSYM=psym  Symbol for head (def=square).
;         SYMCOLOR=sclr Symbol color (def=white).
;         SYMSIZE=ssz Symbol size (def=0.3).
;         VSCALE=vsc Scale factor for vectors (def=1).
;           This keyword is used instead of giving l above.
;           Use this keyword when viewing a complex array.
;         X0=x0 Optional x index of lower left corner (def=0).
;         Y0=y0 Optional y index of lower left corner (def=0).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Plot keywords may be given (like title, xtitle, ...).
; MODIFICATION HISTORY:
;       R. Sterner, 8 Sep, 1989.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       R. Sterner, 2004 Feb 27 --- Upgrades. Complex option.
;       R. Sterner, 2004 Mar 01 --- Added x0,y0 keywords.
;       R. Sterner, 2004 Mar 10 --- Changed a few defaults.
;       R. Sterner, 2004 Mar 23 --- Added _extra.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro vecfld, u0, v0, l, iso=iso, magnitudes=magni, mark=mark, $
	  psym=psym, symsize=smsiz, symcolor=smclr, help=hlp, $
	  vscale=vscale, x0=x0, y0=y0, _extra=extra
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot a 2-d vector field.'
	  print,' vecfld, u, v, [l]'
	  print,'   u = 2-d array of vector x components.   in'
	  print,'     If this array is complex then u and v'
	  print,'     will be taken as the real and imaginary'
	  print,'     parts.  v is then not needed and will be ignored.'
	  print,'   v = 2-d array of vector y components.   in'
	  print,'   l = Optional max length of vectors.     in'
	  print,'      Can give this value using keyword VSCALE.'
	  print,' Keywords:'
	  print,'   /ISO for isotropic plot scale.'
	  print,'   /MAGNITUDES indicate magnitudes, else direction only.'
	  print,'   /MARK mark head of vector by a colored symbol.'
	  print,'   PSYM=psym  Symbol for head (def=square).'
	  print,'   SYMCOLOR=sclr Symbol color (def=white).'
	  print,'   SYMSIZE=ssz Symbol size (def=0.3).'
	  print,'   VSCALE=vsc Scale factor for vectors (def=1).'
	  print,'     This keyword is used instead of giving l above.'
	  print,'     Use this keyword when viewing a complex array.'
	  print,'   X0=x0 Optional x index of lower left corner (def=0).'
	  print,'   Y0=y0 Optional y index of lower left corner (def=0).'
	  print,' Note: Plot keywords may be given (like title, xtitle, ...).'
	  return
	endif
 
	if keyword_set(mark) then begin
	  if n_elements(psym) ne 0 then sym=psym else sym=6	   ; Symbol.
	  if n_elements(smclr) ne 0 then sclr=smclr else sclr=!p.color ; Color.
	  if n_elements(smsiz) ne 0 then ssz=smsiz else ssz=.3	   ; Size.
	endif
 
	if n_elements(x0) eq 0 then x0=0
	if n_elements(y0) eq 0 then y0=0
 
	;------  Complex or vector components?  -----
	if datatype(u0) eq 'COM' then begin
	  u = float(u0)
	  v = imaginary(u0)
	endif else begin
	  u = u0
	  v = v0
	endelse
 
	if n_params(0) lt 3 then l = 1.
	if n_elements(vscale) ne 0 then l=vscale
 
	mag = sqrt(u^2 + v^2)
	mx = max(mag)
	w = where(mag eq 0)
	if w(0) ne -1 then mag(w) = 1.
	if keyword_set(magni) then begin	; Show magnitudes.
	  x = u/mx				; Normalize to max mag.
	  y = v/mx
	endif else begin			; Direction only.
	  x = u/mag				; Unit vectors.
	  y = v/mag
	endelse
	x = l*x					; Scale size.
	y = l*y
 
	sz = size(u)
	lx = sz(1) - 1
	ly = sz(2) - 1
 
	plot,x0+[0,lx+1],y0+[0,ly+1],/xstyl,/ystyl,/nodata, $
	  xticklen=-.02,yticklen=-.02,iso=iso, charsize=1.2, _extra=extra
 
	for iy = 0, ly do begin
	  for ix = 0, lx do begin
	    dx = x(ix,iy)/2.
	    dy = y(ix,iy)/2.
	    plots, x0+[ix-dx,ix+dx]+.5, y0+[iy-dy,iy+dy]+.5
	    if keyword_set(mark) then $
	      plots,x0+ix+dx+.5,y0+iy+dy+.5,psym=sym,col=sclr,symsize=ssz
	  endfor
	endfor
 
	return
	end
