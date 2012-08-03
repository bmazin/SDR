;-------------------------------------------------------------
;+
; NAME:
;       SPHLAT
; PURPOSE:
;       Draw parallels of latitude on a sphere.
; CATEGORY:
; CALLING SEQUENCE:
;       sphlat, lat, rad, [lng1, lng2]
; INPUTS:
;       lat = latitude of parallel.                in
;       rad = radius of sphere.                    in
;       lng1, lng2 = longitude range of parallel.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c  plot color.
;         LINESTYLE=s  plot linestyle.
;           Over-rides defaults for visible and hidden points.
;         THICK=t  plot thickness.
;         /HIDDEN plot hidden points.
;         MAXRAD=r clip points using a sphere of radius r.
; OUTPUTS:
; COMMON BLOCKS:
;       sph_com
; NOTES:
;       Notes: Call SPHINIT first to set sphere orientation and
;         point clipping to the visible hemisphere (def=front).
;         Point clipping may alternatively be done using a
;         clipping sphere defined by MAXRAD.
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
 
	pro sphlat, lat, rad, lng1, lng2, help=hlp, $
	  color=color, linestyle=linestyle, thick=thick, $
	  hidden=hidden, maxrad=maxrad
 
        common sph_com, lng0,lat0,pa0,x0,y0,inc0,vpa0,vaz0,ls_v,ls_h
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Draw parallels of latitude on a sphere.
	  print,' sphlat, lat, rad, [lng1, lng2]'
	  print,'   lat = latitude of parallel.                in'
	  print,'   rad = radius of sphere.                    in'
	  print,'   lng1, lng2 = longitude range of parallel.  in'
          print,' Keywords:'
          print,'   COLOR=c  plot color.'
          print,'   LINESTYLE=s  plot linestyle.'
	  print,'     Over-rides defaults for visible and hidden points.'
          print,'   THICK=t  plot thickness.'
          print,'   /HIDDEN plot hidden points.'
	  print,'   MAXRAD=r clip points using a sphere of radius r.'
          print,' Notes: Call SPHINIT first to set sphere orientation and'
          print,'   point clipping to the visible hemisphere (def=front).'
	  print,'   Point clipping may alternatively be done using a'
	  print,'   clipping sphere defined by MAXRAD.'
	  return
	endif
 
        ;--------------------------------------;
        ;          Set default values          ;
        ;--------------------------------------;
	if n_elements(lng1) eq 0 then lng1 = 0.
	if n_elements(lng2) eq 0 then lng2 = 360.
	if n_elements(color) eq 0 then color = !p.color
        if keyword_set(hidden) then begin
          if n_elements(linestyle) eq 0 then linestyle = ls_h
        endif else begin
          if n_elements(linestyle) eq 0 then linestyle = ls_v
        endelse
	if n_elements(thick) eq 0 then thick = !p.thick
 
        ;--------------------------------------------------;
        ;   Set up points in spherical plar coordinates    ;
        ;--------------------------------------------------;
	lnga = makex(lng1<lng2, lng1>lng2, inc0)
	n = n_elements(lnga)
	lata = maken(lat, lat, n)
	rada = maken(rad, rad, n)
 
        ;--------------------------------------------;
        ;   Transform points to sphere orientation   ;
        ;--------------------------------------------;
	polrec3d, rada, (90.-lata)/!radeg, lnga/!radeg, x, y, z
	rot_3d, 3, x, y, z, lng0/!radeg, x1, y1, z1
	rot_3d, 2, x1, y1, z1, -lat0/!radeg, x, y, z
	rot_3d, 1, x, y, z, -pa0/!radeg, x1, y1, z1
 
	;---------------------------------;
	;   Clip to find desired points   ;
	;---------------------------------;
	if n_elements(maxrad) ne 0 then begin
          ;-------------------------------------------------;
          ;    Handle points selected by clipping sphere    ;
          ;-------------------------------------------------;
	  r3 = x1^2 + y1^2 + z1^2
	  r2 = y1^2 + z1^2
	  r2mx = maxrad^2
	  if keyword_set(hidden) then begin
	    w = where(((r3 lt r2mx) and (x1 gt 0)) or $
	              ((r2 lt r2mx) and (x1 lt 0)), cnt)
	  endif else begin
	    w = where(((r3 gt r2mx) and (x1 gt 0)) or $
	              ((r2 gt r2mx) and (x1 lt 0)), cnt)
	  endelse
	endif else begin
          ;------------------------------------------------------;
          ;    Handle points selected by visible hemisphere.     ;
	  ;    Rotate points based on visible hemisphere center. ;
          ;------------------------------------------------------;
	  rot_3d, 2, 1., 0., 0., vaz0/!radeg, x, y, z
	  rot_3d, 1, x, y, z, -vpa0/!radeg, xv, yv, zv
	  sdist = vect_angle(x1,y1,z1, xv, yv, zv, /deg)
          if keyword_set(hidden) then begin
            w = where(sdist ge 90.01, cnt)
          endif else begin
            w = where(sdist le 90.01, cnt)
          endelse
	endelse
 
        ;--------------------------------------;
        ;        Plot desired points           ;
        ;--------------------------------------;
	if cnt eq 0 then return
	nr = nruns(w)
	for i = 0, nr-1 do begin
	  ind = getrun(w, i)
	  oplot, y1(ind)+x0, z1(ind)+y0, color=color, $
	    linestyle=linestyle, thick=thick, /noclip
	endfor
 
	return
	end
