;-------------------------------------------------------------
;+
; NAME:
;       SECTOR
; PURPOSE:
;       Plot and fill a sector of a circle.
; CATEGORY:
; CALLING SEQUENCE:
;       sector, a1, a2
; INPUTS:
;       a1 = Start angle of arc (deg CCW from X axis).  in
;       a2 = End angle of arc (deg CCW from X axis).    in
; KEYWORD PARAMETERS:
;       Keywords:
;         RADIUS=r  Radius of circle (def=1).
;         XCENTER=xc  Circle center x coord. (def=0).
;         YCENTER=yc  Circle center y coord. (def=0).
;         FRAC=fr Offset sector start outward by fr*r (def=0).
;         /DEVICE means use device coordinates .
;         /DATA means use data coordinates (default).
;         /NORM means use normalized coordinates.
;         /NOCLIP means do not clip arcs to the plot window.
;         /FILL means fill sector.
;         COLOR=c  sector fill color (def=!p.color).
;         OCOLOR=oc  sector outline color (def=c).
;         LINESTYLE=l  outline linestyle (def=!p.linestyle).
;         THICKNESS=t  outline line thickness (def=!p.thick).
;         TX=tx, TY=ty Returned (x,y) of sector center.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Feb 15
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro sector, a1, a2, radius=r, xcenter=xx, ycenter=yy, help=hlp,$
	  color=clr, linestyle=lstyl, thickness=thk, $
	  ocolor=oclr, fill=fill, frac=frac, $
	  device=device, data=data, norm=norm, noclip=noclip, $
	  tx=tx, ty=ty
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot and fill a sector of a circle.'
	  print,' sector, a1, a2'
	  print,'   a1 = Start angle of arc (deg CCW from X axis).  in'
	  print,'   a2 = End angle of arc (deg CCW from X axis).    in'
	  print,' Keywords:'
	  print,'   RADIUS=r  Radius of circle (def=1).'
	  print,'   XCENTER=xc  Circle center x coord. (def=0).'
	  print,'   YCENTER=yc  Circle center y coord. (def=0).'
	  print,'   FRAC=fr Offset sector start outward by fr*r (def=0).'
	  print,'   /DEVICE means use device coordinates .'
          print,'   /DATA means use data coordinates (default).'
          print,'   /NORM means use normalized coordinates.'
	  print,'   /NOCLIP means do not clip arcs to the plot window.'
	  print,'   /FILL means fill sector.'
	  print,'   COLOR=c  sector fill color (def=!p.color).'
	  print,'   OCOLOR=oc  sector outline color (def=c).'
	  print,'   LINESTYLE=l  outline linestyle (def=!p.linestyle).'
	  print,'   THICKNESS=t  outline line thickness (def=!p.thick).'
	  print,'   TX=tx, TY=ty Returned (x,y) of sector center.'
	  return
	endif
 
	;----------------------------------------
	;  Defaults
	;----------------------------------------
	if n_elements(r) eq 0 then r=1.		      ; Circle radius.
	if n_elements(xx) eq 0 then xx=0.	      ; Circle center.
	if n_elements(yy) eq 0 then yy=0.
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(oclr) eq 0 then oclr=clr
	if n_elements(lstyl) eq 0 then lstyl = !p.linestyle
	if n_elements(thk) eq 0 then thk = !p.thick
	if keyword_set(clip) then noclip=0	      ; Clip to plot window.
	if n_elements(frac) eq 0 then frac = 0.	      ; Fractional offset.
	if n_elements(device) eq 0 then device = 0    ; Define flags.
        if n_elements(data)   eq 0 then data   = 0
        if n_elements(norm)   eq 0 then norm   = 0
        if device+data+norm eq 0 then data = 1        ; Default to data.
 
	;----------------------------------------
	;  Deal with frac
	;
	;  Frac can be used to offset a sector
	;  outward from center.  0.25 works
	;  well for a start.
	;----------------------------------------
	if frac eq 0. then begin		; No offset.
	  xoff = 0.
	  yoff = 0.
	endif else begin			; Offset outward.
	  polrec, r*frac, /deg, (a1+a2)/2., xoff, yoff
	endelse
 
	;----------------------------------------
	;  Deal with sector center
	;
	;  [tx,ty] is useful for adding a label
	;  to the sector.  For acute sectors
	;  (central angle < 180) the sector
	;  centroid is returned, else the
	;  midpoint of the central radius is
	;  returned.
	;----------------------------------------
	if arg_present(tx) then begin
	  da = abs(a1-a2)
	  if da ge 180 then begin	; More than half circle, use half.
	    fact = .5
	  endif else begin		; Acute sector, Use sector centroid.
	    alph = (da/2.)/!radeg
	    fact = ((2./3.)*sin(alph))/alph
	  endelse
	  polrec, fact*r, /deg, (a1+a2)/2., tx1, ty1
	  tx = tx1 + xoff
	  ty = ty1 + yoff
	endif
 
	;----------------------------------------
	;  Make plot
	;
	;  To fill the setcor only the first
	;  radii and arc are needed.  The second
	;  radii is used for the outline.
	;  Plotting the entire outline at once
	;  gives spikes at the corners, so it is
	;  plotted in 3 sections.
	;----------------------------------------
	radii,0,r,a1,xx+xoff,yy+yoff, x=xr,y=yr	; Plot radius 1.
	radii,0,r,a2,xx+xoff,yy+yoff,x=xr2,y=yr2; Plot radius 2.
	arcs,r,a1,a2,xx+xoff,yy+yoff, x=xa,y=ya	; Plot arc.
	x = [xr,xa]				; Polygon: radius, arc.
	y = [yr,ya]
 
	if keyword_set(fill) then begin		; Fill sector.
	  polyfill,x,y,data=data, col=clr, $
	    device=device, norm=norm, noclip=noclip
	endif
 
	plots, xa, ya, color=oclr, $		; Outline: arc.
	  linestyle=lstyl, thick=thk, data=data, $
	  device=device, norm=norm, noclip=noclip
	plots, xr, yr, color=oclr, $		; Outline: radii 1.
	  linestyle=lstyl, thick=thk, data=data, $
	  device=device, norm=norm, noclip=noclip
	plots, xr2, yr2, color=oclr, $		; Outline: radii 2.
	  linestyle=lstyl, thick=thk, data=data, $
	  device=device, norm=norm, noclip=noclip
 
	end
	
