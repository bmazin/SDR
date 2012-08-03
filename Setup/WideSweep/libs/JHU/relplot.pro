;-------------------------------------------------------------
;+
; NAME:
;       RELPLOT
; PURPOSE:
;       Relative plot with rotation, scaling, translation.
; CATEGORY:
; CALLING SEQUENCE:
;       relplot, xarr, yarr
; INPUTS:
;       xarr, yarr = x and y arrays in device coordinates.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         ANG=ang  Rotation angle (def=0).
;         SCALE=sc Scale factor (def=1).
;         CENTER=[xc,yc] x and y of center of rotation and
;            scaling.  Center can be in the following coordinates:
;         /DEVICE  Center given in device coordinates (default).
;         /NORMAL  Center given in normalized coordinates.
;         /DATA  Center given in data coordinates.
;         COLOR=clr Plot color (def=!p.color).
;         LINESTYLE=sty Linestyle (def=!p.linestyle).
;         THICKNESS=thk Thickness (def=!p.thick).
;         /NOCLIP means do not clip plot to clipping window.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Dec 10
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro relplot, xarr, yarr, ang=ang, scale=sc, center=cen, $
	  device=dev, normal=norm, data=data, color=clr, linestyle=sty, $
	  thickness=thk, noclip=noclip, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Relative plot with rotation, scaling, translation.'
	  print,' relplot, xarr, yarr'
	  print,'   xarr, yarr = x and y arrays in device coordinates.  in'
	  print,' Keywords:'
	  print,'   ANG=ang  Rotation angle (def=0).'
	  print,'   SCALE=sc Scale factor (def=1).'
	  print,'   CENTER=[xc,yc] x and y of center of rotation and'
	  print,'      scaling.  Center can be in the following coordinates:'
	  print,'   /DEVICE  Center given in device coordinates (default).'
	  print,'   /NORMAL  Center given in normalized coordinates.'
	  print,'   /DATA  Center given in data coordinates.'
	  print,'   COLOR=clr Plot color (def=!p.color).'
	  print,'   LINESTYLE=sty Linestyle (def=!p.linestyle).'
	  print,'   THICKNESS=thk Thickness (def=!p.thick).'
	  print,'   /NOCLIP means do not clip plot to clipping window.'
	  return
	endif
 
	;-------------------------------------------------------
	;  Defaults
	;-------------------------------------------------------
	if n_elements(ang) eq 0 then ang=0.
	if n_elements(sc) eq 0 then sc=1.
	if n_elements(cen) ne 2 then cen=[0.,0.]
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(sty) eq 0 then sty=!p.linestyle
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(noclip) eq 0 then noclip=0
 
	;-------------------------------------------------------
	;  Deal with center
	;-------------------------------------------------------
	xc = cen(0)
	yc = cen(1)
	if keyword_set(norm) then begin
	  tmp = convert_coord(xc,yc,/norm,/to_dev)
	  ixc = tmp(0)
	  iyc = tmp(1)
	endif else if keyword_set(data) then begin
	  tmp = convert_coord(xc,yc,/data,/to_dev)
	  ixc = tmp(0)
	  iyc = tmp(1)
	endif else begin
	  ixc = xc
	  iyc = yc
	endelse
 
	;-------------------------------------------------------
	;  Transform coordinates
	;-------------------------------------------------------
	rotate_xy, xarr*sc, yarr*sc, ang, /deg, 0, 0, x, y	; Scale/Rotate.
	x = round(x + ixc)					; Shift.
	y = round(y + iyc)
 
	;-------------------------------------------------------
	;  Plot
	;-------------------------------------------------------
	plots, /dev, x, y, noclip=noclip, color=clr, linestyle=sty, thick=thk
 
	end
