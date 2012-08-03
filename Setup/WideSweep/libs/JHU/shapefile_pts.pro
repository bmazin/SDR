;-------------------------------------------------------------
;+
; NAME:
;       SHAPEFILE_PTS
; PURPOSE:
;       Return data points from a shape file.
; CATEGORY:
; CALLING SEQUENCE:
;       shapefile_pts, file, lng, lat, pen
; INPUTS:
;       file = Name of shape file.                   in
; KEYWORD PARAMETERS:
;       Keywords:
;         TYPE=typ  Shape file type: 3=Polyline, 5=Polygon.
;         BBOX=bbox returned bounding box of data.
;           bbox=[min_lng, max_lng, min_lat, max_lat]
;         CFCC=cfcc Returned Census Feature Class Code.
;         PREFIX=prefix CFCC prefix stripped from CFCC.
;           Like A for roads, H for hydro ...
;         ERROR=err Error flag.  0=ok.
; OUTPUTS:
;       lng, lat = Returned arrays of long and lat.  out
;       pen = Returned pen code when needed.         out
;         0=pen up, 1=pen down.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Aug 02
;       R. Sterner, 2004 Oct 26 --- Added cfcc.  Also DestroyEntity.
;       R. Sterner, 2004 Oct 27 --- Returned error flag.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro shapefile_pts, file, lng, lat, pen, bbox=bbox, type=typ, $
	  cfcc=cfcc, prefix=prefix, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return data points from a shape file.'
	  print,' shapefile_pts, file, lng, lat, pen'
	  print,'   file = Name of shape file.                   in'
	  print,'   lng, lat = Returned arrays of long and lat.  out'
	  print,'   pen = Returned pen code when needed.         out'
	  print,'     0=pen up, 1=pen down.'
	  print,' Keywords:'
	  print,'   TYPE=typ  Shape file type: 3=Polyline, 5=Polygon.'
	  print,'   BBOX=bbox returned bounding box of data.'
	  print,'     bbox=[min_lng, max_lng, min_lat, max_lat]'
	  print,'   CFCC=cfcc Returned Census Feature Class Code.'
	  print,'   PREFIX=prefix CFCC prefix stripped from CFCC.'
	  print,'     Like A for roads, H for hydro ...'
	  print,'   ERROR=err Error flag.  0=ok.'
	  return
	endif
 
	;-----  Open shape file and get properties  --------
	shape = obj_new('idlffshape',file)
 
	err = 1 - obj_valid(shape)
	if err ne 0 then return
 
	;-------  Grab some values from the shape file  ------
	shape->idlffshape::getproperty, n_entities=num, entity_type=typ, $
	  attribute_names=a_names
 
	;-------  Deal with CFCC  ---------
	w = where(a_names eq 'CFCC',cnt)
	cfcc_flag = 0
	if arg_present(cfcc) then cfcc_flag=1
	if cnt eq 0 then cfcc_flag=0
	if cfcc_flag eq 1 then tag = 'ATTRIBUTE_'+strtrim(w(0),2)
 
	if keyword_set(noplot) then begin
	  obj_destroy, shape
	  return
	endif
 
	;-------  Storage  -----------
	lng = [0.]	; Longitudes.
	lat = [0.]	; Latitudes.
	pen = [0]	; Pen codes.
	cfcc = [0]	; Census Feature Class Codes.
 
	;-----  Loop through entities and plot  ------------
	case typ of
 
3:	begin
;	  print,' Polyline.'
	  for i=0L,num-1 do begin		; Loop through ent.
	    if cfcc_flag eq 1 then begin	; Deal with cfcc.
	      att = shape->idlffshape::getattributes(i)	; Grab attribuites.
	      attval = tag_value(att,tag)		; Grab cfcc value.
	      val = strmid(attval,1,99)+0		; Numeric.
	      if i eq 0 then prefix=strmid(attval,0,1)	; Prefix.
	    endif
	    ent = shape->idlffshape::getentity(i) ; Grab i'th.
	    xy = *ent.vertices			; Get vertices.
	    dim = size(xy,/dim)			; Dimensions.
	    lst = dim(1)			; Last index.
	    np = ent.n_parts			; # parts.
	    parts = [*ent.parts,lst]		; Get index table.
	    for j=0L,np-1 do begin		; Loop through parts.
	      lo = parts(j)			; Start index.
	      hi = parts(j+1)-1			; End index.
	      lng = [lng, reform(xy(0,lo:hi))]	; Add values to arrays.
	      lat = [lat, reform(xy(1,lo:hi))]
	      pen = [pen, 0, intarr(hi-lo)+1]
	      if cfcc_flag eq 1 then begin	; Deal with cfcc.
		cfcc = [cfcc,intarr(hi-lo+1)+val]
	      endif
	    endfor  ; j
	    shape->idlffshape::DestroyEntity, ent  ; Clean up pointers.
	  endfor  ; i
	end
 
5:	begin
;	  print,' Polygon'
	  ;-----  Fill polygons  -----------
	  for i=0L,num-1 do begin		; Loop through ent.
	    if cfcc_flag eq 1 then begin	; Deal with cfcc.
	      att = shape->idlffshape::getattributes(i)	; Grab attribuites.
	      attval = tag_value(att,tag)		; Grab cfcc value.
	      val = strmid(attval,1,99)+0		; Numeric.
	      if i eq 0 then prefix=strmid(attval,0,1)	; Prefix.
	    endif
	    ent = shape->idlffshape::getentity(i) ; Grab i'th.
	    xy = *ent.vertices			; Get vertices.
	    dim = size(xy,/dim)			; Dimensions.
	    lst = dim(1)			; Last index.
	    np = ent.n_parts			; # parts.
	    parts = [*ent.parts,lst]		; Get index table.
	    for j=0L,np-1 do begin		; Loop through parts.
	      lo = parts(j)			; Start index.
	      hi = parts(j+1)-1			; End index.
	      lng = [lng, reform(xy(0,lo:hi))]		; Add values to arrays.
	      lat = [lat, reform(xy(1,lo:hi))]
	      pen = [pen, 0, intarr(hi-lo)+1]
	      if cfcc_flag eq 1 then begin	; Deal with cfcc.
		cfcc = [cfcc,intarr(hi-lo+1)+val]
	      endif
	    endfor  ; j
	    shape->idlffshape::DestroyEntity, ent  ; Clean up pointers.
	  endfor
 
	end
else:	begin
	  print,' Entities of type '+strtrim(typ,2)+' not yet handled.'
	  err = 2
	end
	endcase
 
	obj_destroy, shape
 
	;------- Clean up -----------
	lng = lng(1:*)
	lat = lat(1:*)
	pen = pen(1:*)
	if cfcc_flag eq 1 then cfcc = cfcc(1:*)
 
	;--------  Bounding box  ------------
	x1 = min(lng,max=x2)
	y1 = min(lat,max=y2)
	bbox = [x1,x2,y1,y2]
 
	end
