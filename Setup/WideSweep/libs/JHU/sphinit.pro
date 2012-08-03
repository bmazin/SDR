;-------------------------------------------------------------
;+
; NAME:
;       SPHINIT
; PURPOSE:
;       Initialize sphere drawing package.
; CATEGORY:
; CALLING SEQUENCE:
;       sphinit
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         --- Set values:
;         LONG = central longitude (East is +, def=0).
;         LAT = central latitude (def=0).
;         PA = position angle of north pole (def=0).
;         X = X position of sphere center (def=0).
;         Y = Y position of sphere center (def=0).
;         INC = angle increment (def=1).
;         VPA = Position angle of visible hemisphere center (def=0).
;         VAZ = Line of sight ang. of vis. hemisphere center (def=0).
;         VIS_STYLE = def linestyle for sphere visible part (def=0).
;         HID_STYLE = def linestyle for sphere hidden part (def=1).
;         --- Actions:
;         /LIST  list values.
;         /FRONT set visible hemisphere to front of sphere.
;         /TOP   set visible hemisphere to top of sphere.
;         /DEVICE  work in device coordinates.
;         RADIUS = r.  Plot outline of radius r.
;         COLOR = c.  Outline plot color.
;	  FILL = f. Fill color for inside radius (def = no fill).
;         LINESTYLE = s.  Outline linestyle.
;         THICK = t.  Outline plot thickness.
; OUTPUTS:
; COMMON BLOCKS:
;       sph_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 25 Jan, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro sphinit, long=long, lat=lat, pa=pa, $
	   x=x, y=y, inc=inc, list=list, radius=radius, $
	   color=color, linestyle=linestyle, thick=thick, $
	   vpa=vpa, vaz=vaz, front=front, top=top, fill=fill, $
	   vis_style=vis, hid_style=hid, device=device, help=hlp
 
        common sph_com, lng0,lat0,pa0,x0,y0,inc0,vpa0,vaz0,ls_v,ls_h
 
	if keyword_set(hlp) then begin
	  print,' Initialize sphere drawing package.'
	  print,' sphinit'
	  print,' Keywords:'
	  print,'   --- Set values:'
	  print,'   LONG = central longitude (East is +, def=0).'
	  print,'   LAT = central latitude (def=0).'
	  print,'   PA = position angle of north pole (def=0).'
	  print,'   X = X position of sphere center (def=0).'
	  print,'   Y = Y position of sphere center (def=0).'
	  print,'   INC = angle increment (def=1).'
	  print,'   VPA = Position angle of visible hemisphere center (def=0).'
	  print,'   VAZ = Line of sight ang. of vis. hemisphere center (def=0).'
	  print,'   VIS_STYLE = def linestyle for sphere visible part (def=0).'
	  print,'   HID_STYLE = def linestyle for sphere hidden part (def=1).'
	  print,'   --- Actions:
	  print,'   /LIST  list values.'
	  print,'   /FRONT set visible hemisphere to front of sphere.'
	  print,'   /TOP   set visible hemisphere to top of sphere.'
	  print,'   /DEVICE  work in device coordinates.'
	  print,'   RADIUS = r.  Plot outline of radius r.'
	  print,'   COLOR = c.  Outline plot color.'
	  print,'   FILL = f. Fill color for inside radius (def = no fill).'
	  print,'   LINESTYLE = s.  Outline linestyle.'
	  print,'   THICK = t.  Outline plot thickness.'
	  return
	endif
 
	if n_elements(long) ne 0 then lng0 = long
	if n_elements(lat) ne 0 then lat0 = lat
	if n_elements(pa) ne 0 then pa0 = pa
	if n_elements(x) ne 0 then x0 = x
	if n_elements(y) ne 0 then y0 = y
	if n_elements(vpa) ne 0 then vpa0 = vpa
	if n_elements(vaz) ne 0 then vaz0 = vaz
	if n_elements(inc) ne 0 then inc0 = inc
	if n_elements(vis) ne 0 then ls_v = vis
	if n_elements(hid) ne 0 then ls_h = hid
	if n_elements(fill) eq 0 then fill = -1
 
	if n_elements(lng0) eq 0 then lng0 = 0.
	if n_elements(lat0) eq 0 then lat0 = 0.
	if n_elements(pa0) eq 0 then pa0 = 0.
	if n_elements(x0) eq 0 then x0 = 0.
	if n_elements(y0) eq 0 then y0 = 0.
	if n_elements(inc0) eq 0 then inc0 = 1.
	if n_elements(vpa0) eq 0 then vpa0 = 0.
	if n_elements(vaz0) eq 0 then vaz0 = 0.
	if n_elements(ls_v) eq 0 then ls_v = 0
	if n_elements(ls_h) eq 0 then ls_h = 1
 
	if keyword_set(list) then begin
	  print,' '
	  print,' Current sphere draw parameters:'
	  print,' Central longitude = ',lng0
	  print,' Central latitude = ',lat0
	  print,' North pole position angle = ',pa0
	  print,' Sphere center = ',x0, y0
	  print,' Draw step size (deg) = ',inc0
	  print,' Visible hemisphere position angle = ',vpa0
	  print,' Visible hemisphere angle to line of sight = ',vaz0
	  print,' Sphere visible linestyle = ',ls_v
	  print,' Sphere hidden linestyle = ',ls_h
	  print,' '
	endif
 
	if keyword_set(front) then begin
	  vpa0 = 0.
	  vaz0 = 0.
	endif
 
	if keyword_set(top) then begin
	  vpa0 = 0.
	  vaz0 = 90. - lat0
	endif
 
	if keyword_set(device) then begin
	  lx = !d.x_size - 1	; Last device x and y.
	  ly = !d.y_size - 1
	  !p.position = [0, 0, lx, ly]	; Set viewport to full window.
	  ;---  Set data scaling to be same as device coordinates  ----
	  plot, [0,lx], [0, ly], /nodata, /noerase, xsty=5, ystyl=5
	endif
 
	if n_elements(radius) ne 0 then begin
          if n_elements(color) eq 0 then color = !p.color
          if n_elements(linestyle) eq 0 then linestyle = !p.linestyle
          if n_elements(thick) eq 0 then thick = !p.thick
	  a = makex(0., 360.+inc0, inc0)/!radeg
	  polrec, radius, a, xx, yy
	  if fill ne (-1) then polyfill, xx+x0, yy+y0, color=fill
	  plots, xx+x0, yy+y0, color=color, linestyle=linestyle,$
	    thick=thick
	endif
 
	return
	end
