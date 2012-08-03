;-------------------------------------------------------------
;+
; NAME:
;       SPHTEXT
; PURPOSE:
;       Write text on a sphere.
; CATEGORY:
; CALLING SEQUENCE:
;       sphtext, text, rad, lng1, lng2, lat1, lat2
; INPUTS:
;       text = text string to write.               in
;       rad = radius of sphere.                    in
;       lng1, lng2 = longitude range of text.      in
;       lat1, lat2 = latitude range of text.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         ANG=A text angle (deg CCW).
;         COLOR=c  text color.
;         LINESTYLE=s  text linestyle.
;         /BACK  plot text on back of sphere.
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
 
	pro sphtext, text, r, lng1, lng2, lat1, lat2, ang=ang, $
	  help=hlp, color=color, linestyle=linestyle, $
	  back=back
 
        common sph_com, lng0,lat0,pa0,x0,y0,inc0,vpa0,vaz0,ls_v,ls_h
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' Write text on a sphere.
	  print,' sphtext, text, rad, lng1, lng2, lat1, lat2'
	  print,'   text = text string to write.               in'
	  print,'   rad = radius of sphere.                    in'
	  print,'   lng1, lng2 = longitude range of text.      in'
	  print,'   lat1, lat2 = latitude range of text.       in'
	  print,' Keywords:'
	  print,'   ANG=A text angle (deg CCW).'
          print,'   COLOR=c  text color.'
          print,'   LINESTYLE=s  text linestyle.'
          print,'   /BACK  plot text on back of sphere.'
	  return
	endif
 
	;---------  Set default values  -------------
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(linestyle) eq 0 then linestyle = !p.linestyle
	if n_elements(ang) eq 0 then ang = 0.
 
	;--------  Get text vectors  ------------
	out = stext_xyp(text,ang=ang)
	xx = out(*,0)
	if keyword_set(back) then xx = -xx
	yy = out(*,1)
	p = out(*,2)
	;-------  Normalize text to 0-1  --------
	xx = xx - min(xx)
	xx = xx/max(xx)
	yy = yy - min(yy)
	yy = yy/max(yy)
 
	;---  Set up text points in spherical polar coordinates  ----
	lnga = lng1 + xx*(lng2-lng1)
	lata = lat1 + yy*(lat2-lat1)
	rada = lata*0. + r
 
	;-----  Transform to desired position and angle  -------
	polrec3d, rada, (90.-lata)/!radeg, lnga/!radeg, x, y, z
	rot_3d, 3, x, y, z, lng0/!radeg, x1, y1, z1
	rot_3d, 2, x1, y1, z1, -lat0/!radeg, x, y, z
	rot_3d, 1, x, y, z, -pa0/!radeg, x1, y1, z1
 
	;-----  Find visible points and plot  --------
        if keyword_set(back) then begin
          w = where(x1 le 0., cnt)
        endif else begin
          w = where(x1 ge 0., cnt)
        endelse
	if cnt eq 0 then return
	nr = nruns(w)
	for i = 0, nr-1 do begin
	  ind = getrun(w, i)
	  plotp, y1(ind)+x0, z1(ind)+y0, p(ind), color=color, $
	    linestyle=linestyle
	endfor
 
	return
	end
