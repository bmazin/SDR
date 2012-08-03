;-------------------------------------------------------------
;+
; NAME:
;       ELL_PLOT_PT
; PURPOSE:
;       Plot a point or segment on current map.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_plot_pt, p1 [, p2]
; INPUTS:
;       p1 = Point to plot.                         in
;       p2 = Optional endpoint of segment to plot.  in
;         Both points are structures {lon:lon,lat:lat}.
; KEYWORD PARAMETERS:
;       Keywords:
;         PSYM=psym Plot symbol for a point (not used for a segment.
;         Other plot keywords also allowed.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: If given two points a segment along a geodesic
;         will be plotted.
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Aug 05
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_plot_pt, pt1, pt2, psym=sym, _extra=extra, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot a point or segment on current map.'
	  print,' ell_plot_pt, p1 [, p2]'
	  print,'   p1 = Point to plot.                         in'
	  print,'   p2 = Optional endpoint of segment to plot.  in'
	  print,'     Both points are structures {lon:lon,lat:lat}.'
	  print,' Keywords:'
	  print,'   PSYM=psym Plot symbol for a point (not used for a segment.'
	  print,'   Other plot keywords also allowed.'
	  print,' Notes: If given two points a segment along a geodesic'
	  print,'   will be plotted.'
	  return
	endif
 
	if n_params(0) eq 1 then begin
	  if n_elements(sym) eq 0 then sym=6
	  plots, pt1.lon, pt1.lat, psym=sym, _extra=extra
	  return
	endif
 
	ell_geo_pts,pt1,pt2,xx,yy
	plots,xx,yy, _extra=extra
 
	end
