;-------------------------------------------------------------
;+
; NAME:
;       MAP_ARRHD
; PURPOSE:
;       Plot an arrow head on a map.
; CATEGORY:
; CALLING SEQUENCE:
;       map_arrhd, lng, lat
; INPUTS:
;       lng, lat = Longitude and Latitude of arrow head.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         HEADING=hd  Azimuth arrow head points (def=0).
;         LENGTH=len  Length of arrow head (def=20).
;         UNITS=unt Units of length.
;           'kms'     Kilometers (Default).
;           'miles'   Statute miles.
;           'nmiles'  Nautical miles.
;           'feet'    Feet.
;           'yards'   Yards.
;           'degrees' Degrees (great circle).
;           'radians' Radians (great circle).
;           'pixels'  Device coordinates.
;         COLOR=clr  outline color (def=!p.color).
;         THICKNESS=thk outline thickness (def=!p.thick).
;         FILL=fclr  fill color (def=none).
;         SHAPE=shp  Arrow head shape (1=fat, 0=thin, def=0.5).
;         /BASE means plot arrow head base only.
;         LABEL=lbl Optional label (def=none).
;         LCOLOR=lclr Label color (def=color).
;         LTHICK=lthk Label thick (def=thk).
;         LSIZE=lsz Label size (def=1.0).
;         LORIENT=lori  Label angle, relative to track.
;         LOFFSET=loff  Label offset from track. + on 3:00 side of
;           track (right side), - on 9:00 side (left side).
;           Values like 1.5, or 2, or -2.
;         LALIGN=lagn   Label alignment from offset pt.
;           Works like xyouts align keyword.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Jun 30
;       R. Sterner, 2001 Aug 16 --- Added Pixels.
;       R. Sterner, 2004 Apr 01 --- Pixels broke.  Fixed.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_arrhd, lng, lat, length=len, heading=head, $
	  units=units, shape=shape, color=clr, thickness=thk, base=base, $
	  fill=fill, label=lbl, lcolor=lclr, lsize=lsize, lthick=lthk, $
	  lorient=lorient, lalign=lalign, loffset=loffset, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot an arrow head on a map.'
	  print,' map_arrhd, lng, lat'
	  print,'   lng, lat = Longitude and Latitude of arrow head.   in'
	  print,' Keywords:'
	  print,'   HEADING=hd  Azimuth arrow head points (def=0).'
	  print,'   LENGTH=len  Length of arrow head (def=20).'
	  print,'   UNITS=unt Units of length.'
	  print,"     'kms'     Kilometers (Default)."
	  print,"     'miles'   Statute miles."
	  print,"     'nmiles'  Nautical miles."
	  print,"     'feet'    Feet."
	  print,"     'yards'   Yards."
	  print,"     'degrees' Degrees (great circle)."
	  print,"     'radians' Radians (great circle)."
	  print,"     'pixels'  Device coordinates."
	  print,'   COLOR=clr  outline color (def=!p.color).'
	  print,'   THICKNESS=thk outline thickness (def=!p.thick).'
	  print,'   FILL=fclr  fill color (def=none).'
	  print,'   SHAPE=shp  Arrow head shape (1=fat, 0=thin, def=0.5).'
	  print,'   /BASE means plot arrow head base only.'
	  print,'   LABEL=lbl Optional label (def=none).'
	  print,'   LCOLOR=lclr Label color (def=color).'
	  print,'   LTHICK=lthk Label thick (def=thk).'
	  print,'   LSIZE=lsz Label size (def=1.0).'
	  print,'   LORIENT=lori  Label angle, relative to track.'
	  print,'   LOFFSET=loff  Label offset from track. + on 3:00 side of'
	  print,'     track (right side), - on 9:00 side (left side).'
	  print,'     Values like 1.5, or 2, or -2.'
	  print,'   LALIGN=lagn   Label alignment from offset pt.'
	  print,'     Works like xyouts align keyword.'
	  return
	endif
 
	;---------  Defaults  ----------------------
	if n_elements(units) eq 0 then units='kms'
	if n_elements(len) eq 0 then len=20.
	if n_elements(head) eq 0 then head=0.
	if n_elements(shape) eq 0 then shape=0.5
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(thk) eq 0 then thk=!p.thick
 
	;---------  Deal with units  ---------------
	un = strlowcase(strmid(units,0,2))
	case un of        ; Convert distance on earth's surface to radians.
	    'km': begin
	        cf = 1.56956e-04  ; Km/radian.                 
	        utxt = 'kms'                                   
	        end                                            
	    'mi': begin                                        
	        cf = 2.52595e-04  ; Miles/radian.              
	        utxt = 'miles'                                 
	        end                                            
	    'nm': begin                                        
	        cf = 2.90682e-04  ; Nautical mile/radian.      
	        utxt = 'nautical miles'                        
	        end                                            
	    'fe': begin                                        
	        cf = 4.78401e-08  ; Feet/radian.               
	        utxt = 'feet'                                  
	        end                                            
	    'ya': begin                                        
	        cf = 1.43520e-07  ; Yards/radian.              
	        utxt = 'yards'                                 
	        end                                            
	    'de': begin                                        
	        cf = 0.0174532925 ; Degrees/radian.            
	        utxt = 'degrees'                               
	        end                                            
	    'ra': begin                                        
	        cf = 1.0          ; Radians/radian.            
	        utxt = 'radians'                               
	        end                                            
	    'pi': begin
		tmpy = !y.window*!d.y_size	; Window y pixels.
		ny = tmpy(1)-tmpy(0)		; Window y size in pixels.
		tmpx =midv(!x.window*!d.x_size)	; Window x mid pixels.
		t = convert_coord([tmpx,tmpx],tmpy,/dev,/to_data)
	        dy = (t(1,1)-t(1,0))/!radeg	; Win y size in radians.
	        cf = dy/ny	; Radians/pixel.
		utxt = 'pixels'
	        end
	    else: begin                                        
	        print,' Error in map_arrhd: Unknown units: '+units
	        print,'   Aborting.'                           
	        return                                         
	        end                                            
	endcase
 
	;-------  Find arrow head points  -----------
	rng = len*cf				; Range in radians.
	rb2ll,lng,lat,rng,head,lng2,lat2	; Find point at tip.
	if lng2 gt 180 then lng2=lng2-360.	; Correct longitude.
	tmp = convert_coord([lng,lng2],[lat,lat2],/data,/to_dev)
	x0=tmp(0,0) & y0=tmp(1,0)		; Base.
	x2=tmp(0,1) & y2=tmp(1,1)		; Tip.
	dx=shape*(x2-x0) & dy=shape*(y2-y0)
	x1=x0+dy & y1=y0-dx			; Side 1.
	x3=x0-dy & y3=y0+dx			; Side 2.
	x = round([x1,x2,x3,x1])		; Outline.
	y = round([y1,y2,y3,y1])
	if keyword_set(base) then begin		; Do only base.
	  x = round([x1,x3])
	  y = round([y1,y3])
	endif
 
 
 
	;-------  Fill  -----------
	if n_elements(fill) ne 0 then polyfill,/dev,x,y,col=fill,noclip=0
 
	;--------  Outline  --------
	plots,/dev,x,y,col=clr(0),thick=thk,noclip=0
 
	;--------  Label  ---------------
	if n_elements(lbl) eq 0 then return
	if n_elements(lclr) eq 0 then lclr=clr
	if n_elements(lthk) eq 0 then lthk=thk
	if n_elements(lsize) eq 0 then lsize=1.
	if n_elements(lorient) eq 0 then lorient=0.
	if n_elements(lalign) eq 0 then lalign=0.
	if n_elements(loffset) eq 0 then loffset=2.
	rx = x0+dy*loffset & ry=y0-dx*loffset
	ang = atan(dy,dx)*!radeg-90.
	xyoutb,/dev,rx,ry,lbl,charsize=lsize,color=lclr,orient=ang+lorient, $
	  align=lalign, bold=lthk
 
	end
