;-------------------------------------------------------------
;+
; NAME:
;       SPHRAD
; PURPOSE:
;       Draw sphere radius.
; CATEGORY:
; CALLING SEQUENCE:
;       sphrad, lng, lat, [r1, r2]
; INPUTS:
;       lng = longitude of radius.     in
;       lat = latitude of radius.      in
;       r1, r2 = range of radius.      in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c  plot color.
;         LINESTYLE=s  plot linestyle.
;           Over-rides defaults for visible and hidden points.
;         THICK=t  plot thickness.
;         /HIDDEN  Plot hidden points.
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
 
 
	pro sphrad, lng, lat, r10, r20, help=hlp, $
	  color=color, linestyle=linestyle, thick=thick, $
	  hidden=hidden, maxrad=maxrad
 
        common sph_com, lng0,lat0,pa0,x0,y0,inc0,vpa0,vaz0,ls_v,ls_h
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Draw sphere radius.'
	  print,' sphrad, lng, lat, [r1, r2]'
	  print,'   lng = longitude of radius.     in'
	  print,'   lat = latitude of radius.      in'
	  print,'   r1, r2 = range of radius.      in'
          print,' Keywords:'
          print,'   COLOR=c  plot color.'
          print,'   LINESTYLE=s  plot linestyle.'
          print,'     Over-rides defaults for visible and hidden points.'
          print,'   THICK=t  plot thickness.'
	  print,'   /HIDDEN  Plot hidden points.'
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
	if n_elements(r10) eq 0 then r10 = 0.
	if n_elements(r20) eq 0 then r20 = 1.
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(thick) eq 0 then thick = !p.thick
	if n_elements(maxrad) eq 0 then maxrad = 0.
        if keyword_set(hidden) then begin
          if n_elements(linestyle) eq 0 then linestyle = ls_h
        endif else begin
          if n_elements(linestyle) eq 0 then linestyle = ls_v
        endelse
 
	;--------------------------------------------------;
	;   Set up points in spherical plar coordinates    ;
	;   and segment radius at clipping sphere surface  ;
	;   if that surface is crossed or touched.         ;
	;--------------------------------------------------;
	rmn = r10<r20
	rmx = r10>r20
	if (rmn ge maxrad) or (rmx lt maxrad) then begin  ; All in or out.
	  rada = [rmn, rmx]
	endif else begin				  ; Cross (or Touch).
	  rada = [rmn, .999*maxrad, 1.001*maxrad, rmx]
	endelse
	lnga = [lng, lng, lng, lng]		; Allow for up to 4 pts.
	lata = [lat, lat, lat, lat]
 
	;--------------------------------------------;
	;   Transform points to sphere orientation   ;
	;--------------------------------------------;
	polrec3d, rada, (90.-lata)/!radeg, lnga/!radeg, x, y, z
	rot_3d, 3, x, y, z, lng0/!radeg, x1, y1, z1
	rot_3d, 2, x1, y1, z1, -lat0/!radeg, x, y, z
	rot_3d, 1, x, y, z, -pa0/!radeg, x1, y1, z1
 
	;------------------------------------------;
	;    2-D and 3-D distances for clipping    ;
	;------------------------------------------;
	r3 = x1^2 + y1^2 + z1^2		; 3-D dist^2 from center.
	r2 = y1^2 + z1^2		; 2-D dist^2 from center.
	r2mx = maxrad^2			; Max allowed dist^2.
 
	;---------------------------------------;
	;    Handle radius clipped by horizon   ;
	;---------------------------------------;
	if (min(r2) lt r2mx) and (max(r2) gt r2mx) and $
	  (min(x1) lt 0.) then begin	; Radius crosses horizon on back side.
	  lst = n_elements(y1)-1
	  t = x1(lst)/sqrt(max(r2))
	  x1 = [x1(0), t*(maxrad-.001), t*(maxrad+.001), x1(lst)]  ; New X.
	  t = y1(lst)/sqrt(max(r2))
	  y1 = [y1(0), t*(maxrad-.001), t*(maxrad+.001), y1(lst)]  ; New Y.
	  t = z1(lst)/sqrt(max(r2))
	  z1 = [z1(0), t*(maxrad-.001), t*(maxrad+.001), z1(lst)]  ; New Z.
	  r3 = x1^2 + y1^2 + z1^2   	; Dist^2 for new points.
	  r2 = y1^2 + z1^2
	endif
 
	;--------------------------------------;
	;    Find visible or hidden points     ;
	;--------------------------------------;
	if keyword_set(hidden) then begin
	  w = where(((r3 le r2mx) and (x1 ge 0)) or $
	            ((r2 le r2mx) and (x1 le 0)), cnt)
	endif else begin
	  w = where(((r3 ge r2mx) and (x1 ge 0)) or $
		    ((r2 ge r2mx) and (x1 le 0)), cnt)
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
