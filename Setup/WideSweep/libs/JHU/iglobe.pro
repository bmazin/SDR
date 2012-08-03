;-------------------------------------------------------------
;+
; NAME:
;       IGLOBE
; PURPOSE:
;       Plot a globe.
; CATEGORY:
; CALLING SEQUENCE:
;       iglobe, y0, x0, a0
; INPUTS:
;       y0 = Central latitude (deg).  Def=0.        in
;       x0 = Central longitude (deg). Def=0.        in
;       a0 = Angle to rotate globe CW (deg). Def=0. in
; KEYWORD PARAMETERS:
;       Keywords:
;         WATER=c24 or [r,g,b]  Color for water as R,G,B.
;         LAND =c24 or [r,g,b]  Color for land as R,G,B.
;         BACK =c24 or [r,g,b]  Color for background as R,G,B.
;         COAST=c24 or [r,g,b]  Color for Coastlines as R,G,B.
;         CGRID=c24 or [r,g,b]  Color for Grid as R,G,B.
;           Colors may be 24-bit values or [r,g,b] arrays.
;         /GRID  display a grid.
;         HOR=0  do not plot horizon (def is plot horizon).
;         /COUNTRIES Plot boundaries for countries.
;         /NOCOLOR Draw black on white background.
;         NAME=proj_name Can give map projection name to over-ride
;           the default orthographic project.  Can find names from:
;           map_proj_info, proj_names=names
;         SCALE=sc Map scale (def=0).  Try 2E8.
;         SAT_P=sp 3 element satellite parameter array.
;           See IDL help for map_set.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Oct 06 as an ION example routine
;       R. Sterner, 1999 Oct 10 --- Fixed GRID and added /NOCOLOR.
;       R. Sterner, 2006 Dec 01 --- Allowed 24-bit color values for colors.
;       R. Sterner, 2006 Dec 05 --- Added NAME=name to allow projection name.
;       R. Sterner, 2006 Dec 05 --- Added SCALE=sc.
;       R. Sterner, 2007 May 23 --- Fixed typo in hor=hor.
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro iglobe, y00, x00, a00, water=wtrc, land=lndc, back=bckc, $
	  coast=cstc, countries=countries, grid=grid, nocolor=nocolor, $
	  cgrid=grdc, hor=hor, name=name, scale=sc, sat_p=sat_p, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Plot a globe.'
	  print,' iglobe, y0, x0, a0'
	  print,'   y0 = Central latitude (deg).  Def=0.        in'
	  print,'   x0 = Central longitude (deg). Def=0.        in'
	  print,'   a0 = Angle to rotate globe CW (deg). Def=0. in'
	  print,' Keywords:'
	  print,'   WATER=c24 or [r,g,b]  Color for water as R,G,B.'
	  print,'   LAND =c24 or [r,g,b]  Color for land as R,G,B.'
	  print,'   BACK =c24 or [r,g,b]  Color for background as R,G,B.'
	  print,'   COAST=c24 or [r,g,b]  Color for Coastlines as R,G,B.'
	  print,'   CGRID=c24 or [r,g,b]  Color for Grid as R,G,B.'
	  print,'     Colors may be 24-bit values or [r,g,b] arrays.'
	  print,'   /GRID  display a grid.'
	  print,'   HOR=0  do not plot horizon (def is plot horizon).'
	  print,'   /COUNTRIES Plot boundaries for countries.'
	  print,'   /NOCOLOR Draw black on white background.'
	  print,'   NAME=proj_name Can give map projection name to over-ride'
	  print,'     the default orthographic project.  Can find names from:'
	  print,'     map_proj_info, proj_names=names'
	  print,'   SCALE=sc Map scale (def=0).  Try 2E8.'
	  print,'   SAT_P=sp 3 element satellite parameter array.'
	  print,'     See IDL help for map_set.'
	  return
	endif
 
	;--------  Define view  ------------------------
	if n_elements(x00) eq 0 then x00=0
	if n_elements(y00) eq 0 then y00=0
	if n_elements(a00) eq 0 then a00=0
	x0 = pmod(x00,360)
	y0 = y00>(-90)<90
	a0 = a00 mod 360
	if n_elements(hor) eq 0 then hor=1
	if n_elements(sc) eq 0 then sc=0
	if n_elements(sat_p) eq 0 then sat_p=[2,0,0]
 
	;---------  Define colors  ---------------------
	if n_elements(bckc) eq 0 then bckc=[255,255,255]	; 0
	if n_elements(cstc) eq 0 then cstc=[000,000,000]	; 1
	if n_elements(wtrc) eq 0 then wtrc=[180,255,255]	; 2
	if n_elements(lndc) eq 0 then lndc=[255,225,205]	; 3
	if n_elements(grdc) eq 0 then grdc=[200,200,200]	; 4
 
	if keyword_set(nocolor) then begin
	  bck = tarclr([255,255,255],set=0)
	  cst = tarclr([0,0,0],set=1)
	  wtr = tarclr([255,255,255],set=2)
	  lnd = tarclr([255,255,255],set=3)
	  grd = tarclr([200,200,200],set=4)
	endif else begin
	  if n_elements(bckc) eq 3 then bck=tarclr(bckc,set=0) else bck=bckc
	  if n_elements(cstc) eq 3 then cst=tarclr(cstc,set=1) else cst=cstc
	  if n_elements(wtrc) eq 3 then wtr=tarclr(wtrc,set=2) else wtr=wtrc
	  if n_elements(lndc) eq 3 then lnd=tarclr(lndc,set=3) else lnd=lndc
	  if n_elements(grdc) eq 3 then grd=tarclr(grdc,set=4) else grd=grdc
	endelse
 
	;---------  Plot globe  ------------------------
	erase, bck
	map_set,y0,x0,a0,hor=hor,/iso,/cont,/orth, col=cst,/nobord,/noerase, $
            e_hor={fill:1,color:wtr},e_cont={fill:1,color:lnd}, name=name, $
	    scale=sc,sat_p=sat_p
	map_set,y0,x0,a0,hor=hor,/iso,/cont,/orth, col=cst,/nobord,/noerase, $
	    name=name, scale=sc,sat_p=sat_p
 
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
          map_set,y0,x0,a0,hor=hor,/iso,/orth,/nobord,/noerase,/cont, $
	    color=cst, name=name, scale=sc,sat_p=sat_p
	endif
 
	if keyword_set(countries) then begin
          map_continents,/coasts, color=cst
          map_continents,/countries,/usa, color=cst
	endif
 
	end
