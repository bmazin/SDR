;-------------------------------------------------------------
;+
; NAME:
;       IMG_POINT
; PURPOSE:
;       Plot a filled point at given position on 24-bit image.
; CATEGORY:
; CALLING SEQUENCE:
;       img2 = img_point(img, x, y, [z])
; INPUTS:
;       img = Input image.                         in
;       x,y = position of point.  May be arrays.   in
;       z = optional z coordinate (def=0).         in
;         If z is given /T3D must also be used.
; KEYWORD PARAMETERS:
;       Keywords:
;         /ANTIALIAS  Antialias plotted points.
;         SIZE=sz     Size of point symbol (like symsize).
;         COLOR=clr   Fill color.
;         OCOLOR=oclr Outline color (def=COLOR).
;         THICK=thk   Outline thickness (def=1).
;         SIDES=n     Number of sides in symbol (def=many).
;         ANGLE=ang   Angle of symbol (def=0).
;         /DATA       Use data coordinates (default).
;         /DEVICE     Use device coordinates.
;         /NORMAL     Use normalized coordinates.
;         /CLIP	clip to clipping window.
;         /T3D        Use 3-d coordinate system.
; OUTPUTS:
;       img2 = returned image.                     out
; COMMON BLOCKS:
;       point_com
; NOTES:
;       Note: very similar to point but plots on given image
;         not on screen.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jul 12
;       R. Sterner, 2002 Jul 24 --- Had to add empty to flush graphics.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function img_point, img,x,y,z,t3d=t3d,size=sz, color=clr, $
	  ocolor=oclr, thick=thk, data=data, device=dev, $
	  normal=norm, clip=clip, sides=sides, angle=ang, $
	  antialias=anti, help=hlp
 
	common point_com, xx, yy
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot a filled point at given position on 24-bit image.'
	  print,' img2 = img_point(img, x, y, [z])'
	  print,'   img = Input image.                         in'
	  print,'   x,y = position of point.  May be arrays.   in'
	  print,'   z = optional z coordinate (def=0).         in'
	  print,'     If z is given /T3D must also be used.'
	  print,'   img2 = returned image.                     out'
	  print,' Keywords:'
	  print,'   /ANTIALIAS  Antialias plotted points.'
	  print,'   SIZE=sz     Size of point symbol (like symsize).'
	  print,'   COLOR=clr   Fill color.'
	  print,'   OCOLOR=oclr Outline color (def=COLOR).'
	  print,'   THICK=thk   Outline thickness (def=1).'
	  print,'   SIDES=n     Number of sides in symbol (def=many).'
	  print,'   ANGLE=ang   Angle of symbol (def=0).'
	  print,'   /DATA       Use data coordinates (default).'
	  print,'   /DEVICE     Use device coordinates.'
	  print,'   /NORMAL     Use normalized coordinates.'
	  print,'   /CLIP	clip to clipping window.'
	  print,'   /T3D        Use 3-d coordinate system.'
	  print,' Note: very similar to point but plots on given image'
	  print,'   not on screen.'
	  return, ''
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
 
	;------  Convert to dev coordinates  ---------
	tmp = convert_coord(x,y,z,data=data,dev=dev,norm=norm,/to_dev, $
	  t3d=t3d)
	ix = round(tmp(0,*))
	iy = round(tmp(1,*))
 
	img2 = img
 
	;------  Plot solid symbol  --------
	if n_elements(clr) ne 0 then begin
	  usersym,xx,yy,color=255,/fill
	  img2 = img_plotp(img2,/dev,ix,iy,symsize=sz,psym=8,clip=clip, $
	    color=clr, anti=anti)
	endif
	empty
 
	;------  Plot symbol outline  --------
	if n_elements(oclr) ne 0 then begin
	  usersym,xx,yy,color=255,thick=1
	  img2 = img_plotp(img2,/dev,ix,iy,symsize=sz,psym=8,clip=clip, $
	    color=oclr, anti=anti, thick=thk)
	endif
 
	return, img2
	end
