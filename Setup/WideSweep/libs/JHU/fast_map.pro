;-------------------------------------------------------------
;+
; NAME:
;       FAST_MAP
; PURPOSE:
;       Make a quick IDL map.
; CATEGORY:
; CALLING SEQUENCE:
;       fast_map
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: othrographic.  Can save as a PNG image
;       with map scaling embedded.  Can later load with
;       screenpng and measure positions or plot new points.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Apr 09
;       R. Sterner, 2003 Nov 10 --- Added color edit and options.
;       R. Sterner, 2006 May 05 --- Fixed toggle USA off.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro fast_map, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Make a quick IDL map.'
	  print,' fast_map'
	  print,'   No args.'
	  print,' Notes: othrographic.  Can save as a PNG image'
	  print,' with map scaling embedded.  Can later load with'
	  print,' screenpng and measure positions or plot new points.'
	  return
	endif
 
	;-----  Initialize  -------
	window,xs=50,ys=50,/pixmap
	erase
	wdelete
	hres_flag = 1			; Hi-res coastlines on.
	usa_flag = 1			; U.S. states on (always hi-res).
	cntry_flag = 1			; Countries on.
	wht = tarclr(255,255,255)	; White.
	blk = tarclr(0,0,0)		; Black.
	wtr = tarclr(/hsv,180,.3,.7)	; Water color.
	lnd = tarclr(/hsv,30,.3,.7)	; Land color.
	cst = tarclr(/hsv,120,.3,.45)	; Coastline color.
	gclr = tarclr(/hsv,0,.4,.7)	; Grid color.
	uclr = tarclr(/hsv,0,0,0)	; U.S. states color.
	ix1 = .05
	ix2 = .95
	iy1 = .05
	iy2 = .95
	pos = [ix1,iy1,ix2,iy2]
	ixx = [ix1,ix2,ix2,ix1,ix1]
	iyy = [iy1,iy1,iy2,iy2,iy1]
	
	lldef = '39,-77'
	scdef = '4E7'
ll_loop:
	tt = ['---==< Fast Map >==---',' ',$
		'West Longitudes are < 0, South Latitudes are < 0.',$
		' ','Enter Lat, Long:']
	xtxtin,titl=tt, def=lldef,txt
	if txt eq '' then return
	lldef = txt
	txt = repchr(txt,',')
	lat = getwrd(txt,0)+0.
	lng = getwrd(txt,1)+0.
 
sc_loop:
	tt = ['Map Scale.  Large values cover a bigger area',$
		'Enter scale:']
	s1 = strtrim(scdef*0.5,2)+': Smaller area'
	s2 = strtrim(scdef*0.9,2)+': Slightly smaller area'
	s3 = strtrim(scdef*2.0,2)+': Larger area'
	s4 = strtrim(scdef*1.1,2)+': Slightly larger area'
 
	men = [s1,s2,s3,s4]
	xtxtin,titl=tt, def=scdef, menu=men, txt
	sc = txt+0.
	scdef = txt
	erase,-1
	map_set2,lat,lng,/ortho,/iso,/usa,/cont,/hor,/nobord, $
	  scale=sc,/noerase,col=0,pos=pos
	
m_loop:	menu = ['Make Map','Change Lat,Long','Change Scale', $
	  'Pick Lat,Long from above map','Quit']
	val = ['MAP','LL','SC','PK','Q']
	opt = xoption(menu,val=val,def='MAP')
 
	if opt eq 'Q' then return
	if opt eq 'LL' then goto, ll_loop
	if opt eq 'SC' then goto, sc_loop
	if opt eq 'PK' then begin
	  xcursor,x0,y0
	  if finite(x0,/nan) then goto, m_loop
	  lldef = strtrim(y0,2)+','+strtrim(x0,2)
	  goto, ll_loop
	endif
 
	;-------  Make map  --------------
make:	erase,wht
	polyfill,/norm,ixx,iyy,col=wtr
	map_set2,lat,lng,/ortho,/iso,/hor,scale=sc,/nobord,/noerase,pos=pos
	if hres_flag then begin
	  map_continents,/hires,/coast,/fill,col=lnd
	  map_continents,/hires,/coast,col=cst
	  if cntry_flag then map_continents,/hires,/countries
	endif else begin
	  map_continents,/coast,/fill,col=lnd
	  map_continents,/coast,col=cst
	  if cntry_flag then map_continents,/countries
	endelse
	if usa_flag then begin
	  if hres_flag then begin
	    map_continents,/usa,col=uclr,/hires
	  endif else begin
	    map_continents,/usa,col=uclr
	  endelse
	endif
	map_space
	map_set2,lat,lng,/ortho,/iso,/hor,scale=sc,/nobord, $
	  /noerase,col=blk,pos=pos
	plots,ixx,iyy,col=blk,/norm,thick=2
 
	;--------  Map options  -------------
op_loop:
	opt = xoption(['Save Map','Add Grid','Another map','New colors', $
	  'Options','Quit'], val=['S','G','A','C','O','Q'])
 
	if opt eq 'Q' then return
	if opt eq 'A' then goto, ll_loop
	;----  Map grid  --------
	if opt eq 'G' then begin
	  maplatlong_grid,col=gclr,/labels,lcol=blk,chars=1.
	  plots,ixx,iyy,col=blk,/norm,thick=2
	  goto, op_loop
	endif
	;----  Color edit  ------
	if opt eq 'C' then begin
	  flag = 0	; No new colors yet.
c_edit:	  opt2 = xoption(['Land','Water','Coast','Grid','USA','Done'], $
	    val=['L','W','C','G','U','DONE'], $
	    col=[lnd,wtr,cst,gclr,uclr,-1],title='Pick a color to edit')
	  if opt2 eq 'L' then begin
	    color_pick, tmp, lnd
	    if tmp ne -1 then begin lnd=tmp & flag=1 & goto,c_edit & endif
	  endif
	  if opt2 eq 'W' then begin
	    color_pick, tmp, wtr
	    if tmp ne -1 then begin wtr=tmp & flag=1 & goto,c_edit & endif
	  endif
	  if opt2 eq 'C' then begin
	    color_pick, tmp, cst
	    if tmp ne -1 then begin cst=tmp & flag=1 & goto,c_edit & endif
	  endif
	  if opt2 eq 'G' then begin
	    color_pick, tmp, gclr
	    if tmp ne -1 then begin gclr=tmp & flag=1 & goto,c_edit & endif
	  endif
	  if opt2 eq 'U' then begin
	    color_pick, tmp, uclr
	    if tmp ne -1 then begin uclr=tmp & flag=1 & goto,c_edit & endif
	  endif
	  if flag ne 0 then goto, make
	  goto, op_loop
	endif
	;----  Options  -------
	if opt eq 'O' then begin
mapo:	  opt2 = xoption(['Toggle Hi-res coastlines: '+ $
	    (['Off','On'])(hres_flag), $
	    'Toggle USA: '+ $
	    (['Off','On'])(usa_flag), $
	    'Toggle Countries: '+ $
	    (['Off','On'])(cntry_flag), $
	    'Done'], $
	    val=['H','U','C','DONE'])
	  if opt2 eq 'H' then begin
	    hres_flag = 1 - hres_flag
	    goto,mapo
	  endif
	  if opt2 eq 'U' then begin
	    usa_flag = 1 - usa_flag
	    goto,mapo
	  endif
	  if opt2 eq 'C' then begin
	    cntry_flag = 1 - cntry_flag
	    goto,mapo
	  endif
	  goto, make
	endif
	;----  Save map  ------
	if opt eq 'S' then begin
	  map_put_scale
	  xtxtin,title='Enter png image name to save map:',txt
	  if txt ne '' then pngscreen,txt
	  goto, op_loop
	endif
 
	end
