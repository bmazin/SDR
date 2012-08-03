;-------------------------------------------------------------
;+
; NAME:
;       DAYGLOBE
; PURPOSE:
;       Show the area of daylight/night on a globe.
; CATEGORY:
; CALLING SEQUENCE:
;       dayglobe, lat0, lng0, ang0
; INPUTS:
;       lat0 = Latitude at center of globe.        in
;       lng0 = Longitude at center of globe.       in
;       ang0 = Rotation angle of image (deg CCW).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         TIME=time  Time string (def=current).
;           May give as a date/time string or as Julian Seconds.
;         ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.
;         /DEEPER  means use deeper colors.
;         /QUANTIZED  means 10 degree banded day colors.
;         /FINE means use higher resolution for colors (slower).
;         /BLACK   means use black background (else white).
;         /COUNTRIES means plot countries.
;         POINT='lng lat'  Point to mark.
;         COLOR=clr Color of point as R G B like '0 255 0').
;         /GRID  display a grid.
;         CGRID=gclr  Color for Grid as R G B like '0 255 0').
;         CHARSIZE=csz  Relative character size (def=1).
;           Use 0 for no label.
;         OUTCHARSIZE=outcsz Returned internal character size factor.
;            Use outcsz*charsize to get same size outside routine.
;         /STEREO  means use Stereographic projection instead of
;            Orthographic.
;         SAT_RAD=satrad. If given must be satellite dist from center
;           of earth in earth radii (>1.01).  Gives satellite view.
;         POSITION=pos Position array like for map_set. Overrides
;            default position.  Use a portrait shaped window to show
;            normal text.  Use charsize=-1 for no text.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Oct 14
;       R. Sterner, 2000 Sep 19 --- Added quantized day colors.
;       R. Sterner, 2003 Oct 29 --- Fixed to work for 24-bit color display.
;       R. Sterner, 2003 Nov 04 --- Fixed to work for PS too.
;       R. Sterner, 2004 Mar 18 --- Added Satellite view.
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro dayglobe, lat0, lng0, ang0, time=time0, zone=zone, deeper=deep, $
	  quantized=quant, countries=count, black=black, point=pt, color=pclr, $
	  grid=grid, cgrid=grdc, charsize=csz, stereo=stereo, help=hlp, $
	  position=pos, outcharsize=outcsz, fine=fine, sat_rad=sat_rad
 
	if keyword_set(hlp) then begin
	  print,' Show the area of daylight/night on a globe.'
	  print,' dayglobe, lat0, lng0, ang0'
	  print,'   lat0 = Latitude at center of globe.        in'
	  print,'   lng0 = Longitude at center of globe.       in'
	  print,'   ang0 = Rotation angle of image (deg CCW).  in'
	  print,' Keywords:'
	  print,'   TIME=time  Time string (def=current).'
	  print,'     May give as a date/time string or as Julian Seconds.'
	  print,'   ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.'
	  print,'   /DEEPER  means use deeper colors.'
	  print,'   /QUANTIZED  means 10 degree banded day colors.'
	  print,'   /FINE means use higher resolution for colors (slower).'
	  print,'   /BLACK   means use black background (else white).'
	  print,'   /COUNTRIES means plot countries.'
	  print,"   POINT='lng lat'  Point to mark."
	  print,"   COLOR=clr Color of point as R G B like '0 255 0')."
	  print,'   /GRID  display a grid.'
	  print,"   CGRID=gclr  Color for Grid as R G B like '0 255 0')."
	  print,'   CHARSIZE=csz  Relative character size (def=1).'
	  print,'     Use 0 for no label.'
	  print,'   OUTCHARSIZE=outcsz Returned internal character size factor.'
	  print,'      Use outcsz*charsize to get same size outside routine.'
	  print,'   /STEREO  means use Stereographic projection instead of'
	  print,'      Orthographic.'
	  print,'   SAT_RAD=satrad. If given must be satellite dist from center'
	  print,'     of earth in earth radii (>1.01).  Gives satellite view.'
	  print,'   POSITION=pos Position array like for map_set. Overrides'
	  print,'      default position.  Use a portrait shaped window to show'
	  print,'      normal text.  Use charsize=-1 for no text.'
	  return
	endif
 
	;------  Get current window size and find position  ---------
	nx = !d.x_size  &  ny = !d.y_size
	if n_elements(pos) eq 0 then pos=[0,(ny-nx-1.)/ny,(nx-1.)/nx,(ny-1.)/ny]
 
	;------  Deal with PS/X related items  ------
	if n_elements(csz) eq 0 then csz=1.0
	if !d.name eq 'X' then begin
	  device, get_decomp=decomp
	  device, decomp=0
	  outcsz = nx/550.*1.8
	  csz = csz*outcsz
	  if csz lt 1.5 then cth=1 else cth=2
	  !p.font = -1
	endif else begin
	  outcsz = nx/22000.*1.8
	  csz = csz*outcsz
	  cth = 1
	endelse
 
	;------  Define coordinates  ---------------
	if n_elements(lat0) eq 0 then lat0=0
	if n_elements(lng0) eq 0 then lng0=0
	if n_elements(ang0) eq 0 then ang0=0
 
	;------  Projection  -------------------------
	if n_elements(sat_rad) then begin
	  if sat_rad lt 1.01 then begin
	    print,' Warning in dayglobe: satellite radius too low: '+$
	      strtrim(sat_rad,2)
	    print,' Must be > 1.01.  Clipping to 1.01.'
	  endif
	  extra = {satellite:1, sat_p:sat_rad>1.01}
	endif else if keyword_set(stereo) then begin
	  extra = {stereo:1}
	endif else begin
	  extra = {ortho:1}
	endelse
 
	;------  Deal with time and get sun zenith distances  --------
	if n_elements(time0) eq 0 then time0=''
	time = time0
	t = strupcase(strtrim(time,2))
	if (t eq '') or (t eq 'NOW') then begin
	  time = systime()			; If null use current.
	  zone = -gmt_offsec()/3600.		; Use local time zone.
	endif
	if n_elements(zone) eq 0 then zone=0	; GMT def.
	;------  Want to use JS  ----------------
        if datatype(time) eq 'DOU' then begin
          js = time
          err = 0
        endif else begin
          js = dt_tm_tojs(time, err=err)
          if err ne 0 then return
        endelse
	;------  Compute world altitudes  -------------
	res = 0.5
	if keyword_set(fine) then res=0.1
	a = world_sunzd(js, res, zone=zone, sunlat=slat, sunlng=slng)
 
	;------  Color table  --------------
	sun_colors, deep=deep, quant=quant
	blk = tarclr(0,0,0)
 
	;-------  Do map  ------------------
	map_set, pos=pos, /iso, /hor, _extra=extra, $
	  lat0, lng0, ang0, /noerase
	if keyword_set(black) then miss=blk else miss=0
	img = map_image(a,ix,iy,comp=1,miss=miss)
	if !d.name eq 'X' then erase, 0
	tv,img,ix,iy
 
	;-------  Grid  -----------------------
	if n_elements(grdc) eq 0 then grdc='200 200 200'
	grd = tarclr(grdc,set=183)
        if keyword_set(grid) then begin
          xx = maken(0,360,181)
          for y=-90,90,30 do begin
            yy = maken(y,y,181)
            plots,xx,yy,col=grd   
          endfor
          yy = maken(-90,90,91)
          for x=0,330,30 do begin
            xx = maken(x,x,91)
            plots,xx,yy,col=grd
          endfor
        endif
 
	;-------  Add countries  -----------------
	map_continents, /cont, col=blk
	if keyword_set(count) then $
	  map_continents, /countries, /usa, col=blk
 
	;-------  Plot reference point  ------------
	rtxt1 = ''
	rtxt2 = ''
	if n_elements(pt) ne 0 then begin
	  if strtrim(pt(0),2) ne '' then begin
	    wordarray,string(pt),txt,del=',',/white
	    plng = txt(0)+0.
	    plat = txt(1)+0.
	    if n_elements(pclr) eq 0 then pclr='0 255 0'
	    t = tarclr(pclr,set=182)
	    point,plng,plat,col=182
	    sunpos, js, plng, plat, azi, alt, zone=zone
	    rtxt1 = 'Reference point: Latitude '+string(plat,form='(F6.2)')+$
	      '  Longitude '+string(plng,form='(F7.2)')
	    rtxt2 = 'Sun at reference point: Altitude '+ $
	      string(alt,form='(F5.1)')+$
	      '  Azimuth '+string(azi,form='(F5.1)')
	  endif
	endif
 
	;------  Label plot  ---------------
	if csz gt 0 then begin
	  txt = dt_tm_fromjs(js,form='Y$ n$ d$ h$:m$') + $
	    '  ('+string(zone,form='(F6.2)')+' hours from GMT)'
	  stxt = 'Subsolar point: Latitude '+string(slat,form='(F6.2)')+$
	    '  Longitude '+string(slng,form='(F7.2)')
	  y0 = pos(1)
	  xprint,/init,.5,y0,/norm,chars=csz,charth=cth,dy=1.5
	  xprint,' '
	  clr = blk
	  xprint,txt,col=clr,align=.5
	  xprint,stxt,col=clr,align=.5
	  xprint,rtxt1,col=clr,align=.5
	  xprint,rtxt2,col=clr,align=.5
	endif
 
	if !d.name eq 'X' then device, decomp=decomp
 
	return
	end
