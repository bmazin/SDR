;-------------------------------------------------------------
;+
; NAME:
;       MAPLATLONG
; PURPOSE:
;       Find complete lat/long range covered by map.
; CATEGORY:
; CALLING SEQUENCE:
;       maplatlong
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         RANGE=[long_min, long_max, lat_min, lat_max].
;         /QUIET means do not display range.
;         /NOEXPAND do not expand range using floor and ceil.
;         STEP=step  Step size in pixels for lat/long search (def=3).
;           May need 1 for highly distorted maps like /ortho.
;         SPACE=spc  Returned structure giving points off the map.
;           Structure elements are:
;             in = 1-d indices of points off map for image in window.
;             ix, iy = starting pixel of map window.
;             nx, ny = size of map window in pixels.
;           To use, after maplatlong,space=space do (example):
;             z = tvrd(space.ix, space.iy, space.nx, space.ny)
;             z(space.in) = 255
;             tv,z,space.ix, space.iy
;           Forces step=1.
;         ERROR=err Error flag: 0=no valid map points found.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: An array of device coordinates covering the map
;         window is converted to lat/long.  By default the
;         range found is expanded using floor and ceil, useful
;         when the map includes a pole or the -180/+180 long.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Feb 01
;       R. Sterner, 2001 Dec 27 --- Handled NaN.  Also check more points.
;       R. Sterner, 2002 Jan 09 --- Tried to handle the -180/+180 break.
;       R. Sterner, 2002 Jan 22 --- Added SPACE keyword.
;       R. Sterner, 2005 Feb 21 --- Relaxed last plot restriction.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro maplatlong, help=hlp, range=rng, error=err, quiet=quiet, $
	  noexpand=noexpand, step=step, space=space
 
	if keyword_set(hlp) then begin
	  print,' Find complete lat/long range covered by map.'
	  print,' maplatlong'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   RANGE=[long_min, long_max, lat_min, lat_max].'
	  print,'   /QUIET means do not display range.'
	  print,'   /NOEXPAND do not expand range using floor and ceil.'
	  print,'   STEP=step  Step size in pixels for lat/long search (def=3).'
	  print,'     May need 1 for highly distorted maps like /ortho.'
	  print,'   SPACE=spc  Returned structure giving points off the map.'
	  print,'     Structure elements are:'
	  print,'       in = 1-d indices of points off map for image in window.'
	  print,'       ix, iy = starting pixel of map window.'
	  print,'       nx, ny = size of map window in pixels.'
	  print,'     To use, after maplatlong,space=space do (example):'
	  print,'       z = tvrd(space.ix, space.iy, space.nx, space.ny)'
	  print,'       z(space.in) = 255'
	  print,'       tv,z,space.ix, space.iy'
	  print,'     Forces step=1.'
	  print,'   ERROR=err Error flag: 0=no valid map points found.'
	  print,' Notes: An array of device coordinates covering the map'
	  print,'   window is converted to lat/long.  By default the'
	  print,'   range found is expanded using floor and ceil, useful'
	  print,'   when the map includes a pole or the -180/+180 long.'
	  return
	endif
 
	if n_elements(step) eq 0 then step=3.
	if arg_present(space) then step=1.
 
	;------  Check last plot type  -----------------
	if !x.type ne 3 then begin
;	  print,' Error in mapwindow: last plot was not a map.'
	  print,' Warning in mapwindow: last plot was not a map.'
;	  err = 1
;	  return
	endif
 
	;------  Find map window on screen  ------------
	x = !d.x_size*!x.window
	y = !d.y_size*!y.window
	x1=x(0) & x2=x(1)
	y1=y(0) & y2=y(1)
	dx=x2-x1+1 & dy=y2-y1+1
 
	;------  Make a set of pixels covering map window  ---------
	makexy,x1,x2,step,y1,y2,step,x,y
	x = round(x)
	y = round(y)
 
	;------  Convert to lat/long  ---------------
	t = convert_coord(x,y,/dev,/to_data)
	xx = t(0,*)
	yy = t(1,*)
 
	;------  Deal with points that fall off map (NaN)  -----------
	in = where(finite(xx) eq 0)	; 1-D indices of points off map.
	ix = fix(x1) & iy = fix(y1)
	nx = fix(dx) & ny = fix(dy)
	space = {in:in, ix:ix, iy:iy, nx:nx, ny:ny}
 
	w = where(finite(xx),cnt)
	if cnt eq 0 then begin
	  print,' Error in maplatlong: no valid map points found.'
	  err = 1
	  return
	endif
	err = 0
	xx=xx(w) & yy=yy(w)
 
	;-------  Try to correct -180/+180 long break  ----------
	if max(abs(yy)) lt 89 then begin	  ; If a pole not included.
	  if (max(xx)-min(xx)) gt 180 then begin  ; If -180/+180 break occurs.
	    wn = where(xx lt 0, cntn)		  ; All vals<0.
	    wp = where(xx gt 0, cntp)		  ; All vals>0.
	    if cntn gt cntp then begin		  ; Convert to < 0.
	      xx(wp) = xx(wp)-360.
	    endif else begin			  ; Convert to > 0.
	      xx(wn) = xx(wn)+360.
	    endelse
	  endif
	endif
 
	;-------  Find lat/long range  -------------
	xmn = min(xx, max=xmx)
	ymn = min(yy, max=ymx)
 
	;--------  Expand range  --------------------
	if not keyword_set(noexpand) then begin
	  xmn = floor(xmn)
	  xmx =  ceil(xmx)
	  ymn = floor(ymn)
	  ymx =  ceil(ymx)
	endif
 
	if not keyword_set(quiet) then begin
	  print,' Map longitude range: ',xmn,xmx
	  print,' Map latitude range: ',ymn,ymx
	endif
 
	rng = [xmn,xmx,ymn,ymx]
 
	end
