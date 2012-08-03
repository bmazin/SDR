;-------------------------------------------------------------
;+
; NAME:
;       SUNCLOCK
; PURPOSE:
;       Show world map with day, twilight, and night.
; CATEGORY:
; CALLING SEQUENCE:
;       sunclock, plat, plong
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:  map_set keywords may be given to control the map
;         display.
;         TIME=dt_tm  Specify a date and time.
;           Format is flexible but requires month name (3 char min).
;           Default is current system time. Ex: "1994 jun 22 13:45"
;         ZONE=n  Specify a time zone as hours ahead of GMT.
;           Default is local time zone.  Ex: zone=-4 for EDT.
;           Only needed if in another time zone.
;         /USA plots U.S. states.
;         LNG=tlng, LAT=tlat Lat and Long array to plot.
;         COLOR=clr  Plot color [r,g,b].
;         /QUIET means suppress status messages.
;         /SAME_WINDOW means use last window instead of a new one.
; OUTPUTS:
; COMMON BLOCKS:
;       sunclock_com
; NOTES:
;       Notes: The meaning of the colors is as follows:
;         Subsolar point: Red.
;         Daylight: Yellow-Orange.
;         Sun rise/set line: Red.
;         Twilights: Pink, Blue, and Darker Blue bands.
;           Civil:        Sun is   0 to  -6 degrees below horizon.
;           Nautical:     Sun is  -6 to -12 degrees below horizon.
;           Astronomical: Sun is -12 to -18 degrees below horizon.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Apr 5
;       R. Sterner, 2003 Oct 29 --- Fixed to work for 24-bit color display.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro sunclock, time=dt0, plat, plong, help=hlp, usa=usa, _extra=extra, $
	  zone=zone, quiet=quiet, same=same, lng=tlng, lat=tlat, color=tclr
 
	;-------  Save constants in common  --------
	common sunclock_com, wlng, wlat, win, r, g, b
 
	if keyword_set(hlp) then begin
	  print,' Show world map with day, twilight, and night.'
	  print,' sunclock, plat, plong'
	  print,'   plat = map projection central latitude (deg).'
	  print,'   plong = map projection central longitude (deg).'
	  print,'     West longitude < 0: 90 W = -90.'
	  print,' Keywords:  map_set keywords may be given to control the map'
	  print,'   display.'
	  print,'   TIME=dt_tm  Specify a date and time.'
	  print,'     Format is flexible but requires month name (3 char min).'
	  print,'     Default is current system time. Ex: "1994 jun 22 13:45"'
	  print,'   ZONE=n  Specify a time zone as hours ahead of GMT.'
	  print,'     Default is local time zone.  Ex: zone=-4 for EDT.'
	  print,'     Only needed if in another time zone.'
	  print,'   /USA plots U.S. states.'
	  print,'   LNG=tlng, LAT=tlat Lat and Long array to plot.'
	  print,'   COLOR=clr  Plot color [r,g,b].'
	  print,'   /QUIET means suppress status messages.'
	  print,'   /SAME_WINDOW means use last window instead of a new one.'
	  print,' Notes: The meaning of the colors is as follows:'
	  print,'   Subsolar point: Red.'
	  print,'   Daylight: Yellow-Orange.'
	  print,'   Sun rise/set line: Red.'
	  print,'   Twilights: Pink, Blue, and Darker Blue bands.'
	  print,'     Civil:        Sun is   0 to  -6 degrees below horizon.'
	  print,'     Nautical:     Sun is  -6 to -12 degrees below horizon.'
	  print,'     Astronomical: Sun is -12 to -18 degrees below horizon.'
	  return
	endif
 
	device, get_decomp=decomp
	device, decomp=0
 
	;--------  Color check  ----------------
	window,xs=50,ys=50,colors=185,/pixmap
	wdelete
	if topc() lt 184 then begin
	  print,' Error in sunclock: not enough colors.'
	  print,' Need 185, have '+strtrim(topc()+1,2)
	  return
	endif
 
	;--------  Init common  ----------------
	if n_elements(wlng) eq 0 then begin
	  makexy,-180,180,.5, -90, 90, .5, wlng, wlat
	  ;-----  Sun Symbol  -----------
	  a=maken(0,360,17)
	  r=maken(1,1,17)+(1-findgen(17) mod 2) 
	  polrec,r,a,x,y,/deg
	  usersym,x,y,color=90,/fill
	  ;------  Also make CT  --------
	  r=bytarr(256) & g=r & b=r
	  r(0)=255 & g(0)=255 & b(0)=0
	  r(90)=200 & g(90)=60 & b(90)=60
	  r(91)=120 & g(91)=120 & b(91)=160
	  r(180)=0 & g(180)=0 & b(180)=130
	  ctint,r,g,b,0,90,2
	  ctint,r,g,b,91,180,2
	  r(90)=255 & g(90)=0 & b(90)=0
	  r(91:96)=210 & g(91:96)=125 & b(91:96)=255
	  r(97:102)=150 & g(97:102)=115 & b(97:102)=230
	  r(103:108)=100 & g(103:108)=100 & b(103:108)=200
	  r(182)=0 & g(182)=255 & b(182)=180	; Background.
	  r(183)=0 & g(183)=221 & b(183)=151	; Background shadow.
	  r(184)=204 & g(184)=250 & b(184)=239	; Background lighter.
	  r(0)=0 & g(0)=191 & b(0)=130		; 0 color.
	endif
 
	tvlct,r,g,b 
	!p.background=182
 
	;--------  Handle  time  ---------------
	if n_elements(dt0) eq 0 then dt0 = systime()	; Current time is def.
	dt = dt0			; Copy date/time string.
	off = gmt_offsec()		; Find correction from local to UT.
	if n_elements(zone) ne 0 then off = -3600.*zone		; Zone given.
	dt_tm_inc, dt, off		; Convert to UT.
	dt_tm_brk, dt, dd, tt		; Break input into date and time.
	date2ymd, dd, y, m, d		; Break date into y,m,d.
	jd = ymd2jd(y,m,d)		; Find Julian Day number.
	ut = secstr(tt)/3600.		; Convert time to UT in hours.
 
	;--------  Solar RA/Dec  ---------------
	sun, y, m, d, ut, app_ra=ra, app_dec=dec
 
	;--------  GMST (Greenwich Mean Sidereal Time)  -----
	st = lmst(jd,ut/24.,0)*24
 
	;------  Subsolar point  ------------
	lat = dec
	lng = 15.0*(ra-st)
 
	;--------  Do image  -------------------
	if not keyword_set(quiet) then $
	  print,' Computing solar altitudes around the world . . .'
	if n_elements(plat) eq 0 then plat=0.
	if n_elements(plong) eq 0 then plong=0.
	ll2rb,lng,lat,wlng,wlat,rr,bb		; Compute subsolar point range.
	rr = rr*!radeg				; Range in degrees (0-180).
	z = scalearray(rr,0,180,0,180)		; Scale to color table.
	if n_elements(win) ne 0 then begin
	  if not keyword_set(same) then begin
	    if !d.window ge 0 then wdelete, win
	    window,xs=640,ys=640,/free,title=' '
	    win = !d.window
	  endif
	endif else begin
	  window,xs=640,ys=640,/free,title=' '
	  win = !d.window
	endelse
	;--------  Dynamic text size  ----------
	szf = !d.x_size/640.
	;--------  Set map position  --------
	pos = [.01,.17,.99,.88]
	pflag = 0
	if n_elements(extra) gt 0 then begin
	  tg = strmid(tag_names(extra),0,3)	; Deal with circular maps.
	  po = strpos(tg,'ORT')
	  ps = strpos(tg,'SAT')
	  if max([po,ps]) ge 0 then begin
	    dy = pos([1,3])*!d.y_size
	    dx = (dy(1)-dy(0))/2.
	    pos([0,2]) = ([-dx,dx]+!d.x_size/2.)/!d.x_size
	    pflag = 1		; Projection flag (1=circular map).
	  endif
	endif
	map_set, plat, plong, pos=pos, color=181, _extra=extra
	img = map_image(z,x,y,/bilin,compress=1,/whole,miss=0)	; Warp to map.
	tv, img, x, y
	ymn = pos(1)-.002
	polyfill,/norm,[0,1,.98,.02],[0,0,.02,.02],col=183
	polyfill,/norm,[.98,1,1,.98],[.02,0,ymn,ymn-.02],col=183
	polyfill,/norm,[.98,1,0,.02],ymn-[.02,0,0,.02],col=184
	polyfill,/norm,[0,.02,.02,0],[0,.02,ymn-.02,ymn],col=184
	map_set, /cont, plat, plong, _extra=extra, usa=usa, /noerase, $
	  color=181, pos=pos
	;-------  Sun symbol  ----------
	ll2rb,plong,plat,lng,lat,dist,azi
	dist = dist/!pi
	if pflag eq 0 then dist = 0
	if dist le .5 then plots, lng, lat, psym=8, symsize=1.5*szf
	;-----  Track plot  ----------
	if n_elements(tlng) gt 1 then begin
	  if n_elements(tclr) eq 0 then tclr=[255,255,255]
	  tcol = tarclr(tclr)
	  plots,tlng,tlat,col=tcol
	endif
	;-----  Title  ---------
	xyoutb,.5+.01,.91-.01,/norm,align=.5,'!8Sunclock!X',chars=5.5*szf,$
	  col=183,bold=5*szf
	c=maken(150,1,10)
	d = maken(0,.01,10)
	for i=0,9 do xyoutb,.5+d(i),.91+d(i),/norm,align=.5,'!8Sunclock!X',$
	  chars=5.5*szf,col=c(i),bold=2*szf
	;--------  Info  --------------
	js = dt_tm_tojs(dt0)
	tt = '!8'+dt_tm_fromjs(js,form='Y$ N$ d$ h$:m$')
	tt = tt+'   '+string(-off/3600.,form='("(",f6.2," hours from GMT)")')
	xyoutb,.5,.0984,tt+'!X',col=181,align=.5,/norm,chars=2.*szf,bold=2*szf
	tt = '!8Subsolar point: Latitude '+string(lat,form='(f6.2)')+$
	  '  Longitude '+string(lng,form='(f7.2)')+'!X'
	xyoutb,.5,.0516,tt,col=181,align=.5,/norm,chars=2.*szf,bold=2*szf
 
	device, decomp=decomp
 
	return
	end
