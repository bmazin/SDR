;-------------------------------------------------------------
;+
; NAME:
;       CONCOORD
; PURPOSE:
;       Convert between two linear coordinate systems.
; CATEGORY:
; CALLING SEQUENCE:
;       concoord, x1, y1, x2, y2
; INPUTS:
;       x1,y1 = input coordinates.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         /ROUND means round output to nearest integers.
;           Intended for pixel coordinates.
;         /TO_1  the input point(s), x1,y1, are in system 2 and are
;           to be converted to system 1.  /TO_1 is the default.
;         /TO_2  the input point(s), x1,y1, are in system 1 and are
;           to be converted to system 2.
;         /INIT  means initialize coordinate transformations.
;           In this case x1,y1 are the known reference point
;           coordinates in system 1, and x2,y2 are the known
;           reference point coordinates in system 2.
;           At least 3 non-colinear reference points are needed
;           to define the coordinate transformations, more are
;           ok.  So for /INIT all 4 parameters are inputs and
;           arrays of at least 3 elements.
;         NAME1=nm1, NAME2=nm2  Optional coordinate system names,
;           def=system 1 and system 2.  Only on /INIT.
;           Use /SYSTEMS to display system names at a later time.
;           Very useful to make the correct calls clear.
; OUTPUTS:
;       x2,y2 = output coordinates.         out
; COMMON BLOCKS:
;       concoord_com
; NOTES:
;       Notes: Example for pixel coordinates and lat/long:
;         concoord,ix,iy,lng,lat,/init,name1='Pixels',name2='Long/lat'
;           ix,iy are arrays of ref pt pixel coord, lng,lat are
;           arrays of ref pt long, lat.
;         concoord,lng,lat,ix,iy,/to_1,/round
;           From long,lat find pixel coordinates.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Oct 2
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro concoord, x1, y1, x2, y2, initialize=init, $
	  to_1=to_1, to_2=to_2, round=round, $
	  name1=nam1, name2=nam2, systems=sys, help=hlp
 
	common concoord_com, xform_x1, xform_y1, xform_x2, xform_y2, $
	  name1, name2
 
	if keyword_set(hlp) then begin
help:	  print,' Convert between two linear coordinate systems.'
	  print,' concoord, x1, y1, x2, y2'
	  print,'   x1,y1 = input coordinates.          in'
	  print,'   x2,y2 = output coordinates.         out'
	  print,' Keywords:'
	  print,'   /ROUND means round output to nearest integers.'
	  print,'     Intended for pixel coordinates.'
	  print,'   /TO_1  the input point(s), x1,y1, are in system 2 and are'
	  print,'     to be converted to system 1.  /TO_1 is the default.'
	  print,'   /TO_2  the input point(s), x1,y1, are in system 1 and are'
          print,'     to be converted to system 2.'
	  print,'   /INIT  means initialize coordinate transformations.'
	  print,'     In this case x1,y1 are the known reference point'
	  print,'     coordinates in system 1, and x2,y2 are the known'
	  print,'     reference point coordinates in system 2.'
	  print,'     At least 3 non-colinear reference points are needed'
	  print,'     to define the coordinate transformations, more are'
	  print,'     ok.  So for /INIT all 4 parameters are inputs and'
	  print,'     arrays of at least 3 elements.'
	  print,'   NAME1=nm1, NAME2=nm2  Optional coordinate system names,'
	  print,'     def=system 1 and system 2.  Only on /INIT.'
	  print,'     Use /SYSTEMS to display system names at a later time.'
	  print,'     Very useful to make the correct calls clear.'
	  print,' Notes: Example for pixel coordinates and lat/long:'
	  print,"   concoord,ix,iy,lng,lat,/init,name1='Pixels',name2='Long/lat'"
	  print,'     ix,iy are arrays of ref pt pixel coord, lng,lat are'
	  print,'     arrays of ref pt long, lat.'
	  print,'   concoord,lng,lat,ix,iy,/to_1,/round'
	  print,'     From long,lat find pixel coordinates.'
	  return
	endif
 
	;--------------  Initialize  ---------------------
	if keyword_set(init) then begin
	  ;--------  Find transformations from samp,line to long,lat  --------
	  ;--------  Find transformations from x1,y1 to x2,y2  --------
	  ones = fltarr(n_elements(x1))+1.
;	  a = [transpose(x1),transpose(y1),transpose([1,1,1,1])]
	  a = [transpose(x1),transpose(y1),transpose(ones)]
	  svdc,a,w,u,v,/double
	  xform_x2 = transpose(svsol(u,w,v,x2,/double))
	  xform_y2 = transpose(svsol(u,w,v,y2,/double))
 
	  ;--------  Find transformations from long,lat to samp,line  --------
	  ;--------  Find transformations from x2,y2 to x1,y1   --------
	  ones = fltarr(n_elements(x2))+1.
;	  a = [transpose(x2),transpose(y2),transpose([1,1,1,1])]
	  a = [transpose(x2),transpose(y2),transpose(ones)]
	  svdc,a,w,u,v,/double
	  xform_x1 = transpose(svsol(u,w,v,x1,/double))
	  xform_y1 = transpose(svsol(u,w,v,y1,/double))
 
	  if n_elements(nam1) eq 0 then nam1='System 1'
	  if n_elements(nam2) eq 0 then nam2='System 2'
	  name1=nam1  &  name2=nam2
	  return
	endif
 
	;---------  Display coordinate system names  -------------
	if keyword_set(sys) then begin
	  print,'  Call to concoord (after initializing):'
	  print,'  concoord, x1, y1, x2, y2'
	  print,'  Use /TO_1 to convert from '+name2+' to '+name1+' (default)'
	  print,'     x1, y1 are inputs and are '+name2
	  print,'     x2, y2 are outputs and are '+name1
	  print,'  Use /TO_2 to convert from '+name1+' to '+name2
	  print,'     x1, y1 are inputs and are '+name1
	  print,'     x2, y2 are outputs and are '+name2
	  return
	endif
 
	;-----------  Convert from one system to the other  -----------
	if n_params(0) lt 4 then goto, help
	n = n_elements(x1)
	sz = size(x1)					; Reshape info.
	if sz(0) gt 0 then d=sz(1:sz(0)) else d=1
	a = [transpose(x1(0:*)),transpose(y1(0:*)),transpose(fltarr(n)+1.)]
 
	;----  Samp, Line to Long, Lat  -----
	;----  x1,y1 to x2,y2  -----
	if keyword_set(to_2) then begin
	  x2 = xform_x2#a
	  y2 = xform_y2#a
	  if keyword_set(round) then begin
	    x2 = round(x2)
	    y2 = round(y2)
	  endif
	  x2=reform(x2,d) & y2=reform(y2,d)
	  return
        endif
 
	;----  x2,y2 to x1,y1  (default)  -----
        x2 = xform_x1#a
        y2 = xform_y1#a
	if keyword_set(round) then begin
	  x2 = round(x2)
	  y2 = round(y2)
	endif
	x2=reform(x2,d) & y2=reform(y2,d)
 
	return
	end
