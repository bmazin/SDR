;-------------------------------------------------------------
;+
; NAME:
;       POINT
; PURPOSE:
;       Plot a filled point at given position.
; CATEGORY:
; CALLING SEQUENCE:
;       point, x, y, [z]
; INPUTS:
;       x,y = position of point.  May be arrays.   in
;       z = optional z coordinate (def=0).         in
;         If z is given /T3D must also be used.
; KEYWORD PARAMETERS:
;       Keywords:
;         SIZE=sz     Size of point symbol (like symsize).
;         COLOR=clr   Fill color.
;         OCOLOR=oclr Outline color (def=COLOR).
;         THICK=thk   Outline thickness (def=1).
;         SIDES=n     Number of sides in symbol (def=many).
;         ANGLE=ang   Angle of symbol (def=0).
;         /NOFILL     Do not fill symbol.
;         /NOOUTLINE  Do not draw symbol outline.
;         /DATA       Use data coordinates (default).
;         /DEVICE     Use device coordinates.
;         /NORMAL     Use normalized coordinates.
;         /CLIP	clip to clipping window.
;         /T3D        Use 3-d coordinate system.
; OUTPUTS:
; COMMON BLOCKS:
;       point_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Aug 17
;       R. Sterner, 2001 Mar 28 --- Added SIDES=n, ANGLE=ang.
;       R. Sterner, 2002 Mar 06 --- Rounded dev coordinate positions.
;       R. Sterner, 2004 Mar 11 --- Added /NOFILL.
;       R. Sterner, 2004 Mar 11 --- Added /NOOUTLINE.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro point, x,y,z,t3d=t3d,size=sz, color=clr, ocolor=oclr, thick=thk, $
	  data=data, device=dev, normal=norm, clip=clip, $
	  sides=sides, angle=ang, nofill=nofill, nooutline=noout, help=hlp
 
	common point_com, xx, yy
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot a filled point at given position.'
	  print,' point, x, y, [z]'
	  print,'   x,y = position of point.  May be arrays.   in'
	  print,'   z = optional z coordinate (def=0).         in'
	  print,'     If z is given /T3D must also be used.'
	  print,' Keywords:'
	  print,'   SIZE=sz     Size of point symbol (like symsize).'
	  print,'   COLOR=clr   Fill color.'
	  print,'   OCOLOR=oclr Outline color (def=COLOR).'
	  print,'   THICK=thk   Outline thickness (def=1).'
	  print,'   SIDES=n     Number of sides in symbol (def=many).'
	  print,'   ANGLE=ang   Angle of symbol (def=0).'
	  print,'   /NOFILL     Do not fill symbol.'
	  print,'   /NOOUTLINE  Do not draw symbol outline.'
	  print,'   /DATA       Use data coordinates (default).'
	  print,'   /DEVICE     Use device coordinates.'
	  print,'   /NORMAL     Use normalized coordinates.'
	  print,'   /CLIP	clip to clipping window.'
	  print,'   /T3D        Use 3-d coordinate system.'
	  return
	endif
 
	;------  Define plot symbol on first call  ------
	if (n_elements(xx) eq 0) or (n_elements(sides) ne 0) $
	  or (n_elements(ang) ne 0)then begin
	  n = 37
	  if n_elements(sides) ne 0 then n=sides+1
	  if n_elements(ang) eq 0 then ang=0.
	  a = maken(0,360,n)+ang
	  r = maken(1,1,n)
	  polrec,r,a,/deg,xx,yy
	endif
 
	;------  Defaults  ------------
	if n_elements(sz)   eq 0 then sz=1.
	if n_elements(thk)  eq 0 then thk=1.
	if (n_elements(data) and n_elements(dev) and n_elements(norm)) $
	  eq 0 then data=1
	if n_elements(z)    eq 0 then z=0.
	if n_elements(t3d)  eq 0 then t3d=0
	noclip = 1
	if keyword_set(clip) then noclip=0
 
	;------  Convert to dev coordinates  ---------
	tmp = convert_coord(x,y,z,data=data,dev=dev,norm=norm,/to_dev,t3d=t3d)
	ix = round(tmp(0,*))
	iy = round(tmp(1,*))
 
	;------  Plot solid symbol  --------
	if n_elements(clr) ne 0 then begin
	  if not keyword_set(nofill) then begin
	    usersym,xx,yy,color=clr,/fill
	    plots,/dev,ix,iy,symsize=sz,psym=8,noclip=noclip
	  endif
	endif
 
	;------  Plot symbol outline  --------
	if n_elements(oclr) ne 0 then begin
	  if not keyword_set(noout) then begin
	    usersym,xx,yy,color=oclr,thick=thk
	    plots,/dev,ix,iy,symsize=sz,psym=8,noclip=noclip
	  endif
	endif
 
	return
	end
