;-------------------------------------------------------------
;+
; NAME:
;       LONLAT2SHAPE
; PURPOSE:
;       Save lon, lat arrays in a shape file.
; CATEGORY:
; CALLING SEQUENCE:
;       lonlat2shape, lon, lat, filename
; INPUTS:
;       lon = Array of longitudes.        in
;       lat = Array of latitudes.         in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       filename = Name of new shapefile. out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Sep 18
;       R. Sterner, 2006 Sep 19 --- Added N_PARTS=0L.
;       R. Sterner, 2006 Sep 28 --- Added some attributes.
;       R. Sterner, 2006 Sep 28 --- Added attributes=att keyword.
;       R. Sterner, 2006 Oct 04 --- Fixed # points listed.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro lonlat2shape, lon, lat, filename, attributes=att, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Save lon, lat arrays in a shape file.'
	  print,' lonlat2shape, lon, lat, filename'
	  print,'   lon = Array of longitudes.        in'
	  print,'   lat = Array of latitudes.         in'
	  print,'   filename = Name of new shapefile. out'
	  return
	endif
 
	;---------------------------------
	;  Prepare data
	;---------------------------------
	x = transpose(lon(0:*))		; Force to be a column vector.
	y = transpose(lat(0:*))
	xy = [x,y]			; Two column array.
	n = n_elements(x)		; Number of vertices in curve.
 
	;---------------------------------
	;  Open shape file
	;---------------------------------
	shp = obj_new('IDLffShape',filename,/update,ENTITY_TYPE=3)
 
	;---------------------------------
	;  Add data
	;---------------------------------
	entNew = {IDL_SHAPE_ENTITY}	; Get an entity structure to fill.
	entNew.SHAPE_TYPE = 3		; Insert shape type (3=polyline).
	b = dblarr(8)			; Set up bounds.
	b[0] = min(x)			; Add values to bounding box.
	b[1] = min(y)
	b[4] = max(x)
	b[5] = max(y)
	entNew.BOUNDS = b		; Add bounds to structure.
	entNew.N_VERTICES = n		; # vertices.
	entNew.VERTICES = ptr_new(xy)	; Add vertices array.
	entNew.N_PARTS = 1L		; 1 part.
	entNew.PARTS = ptr_new([0L])	; 0 works.
	shp->IDLffShape::PutEntity, entNew	; Add entity to shape file.
 
	;---------------------------------
	;  Set up some attributes.
	;  Seems that some attributes
	;  are needed in the file.
	;  Add at least 1, creation date.
	;  Must set up attributes needed
	;  then get attribute structure
	;  and fill it.  Then save it.
	;---------------------------------
	shp->idlffshape::addattribute, 'Shapefile',7,25
	if n_elements(att) ne 0 then begin
	  tags = tag_names(att)
	  nt = n_elements(tags)
	  for i=0,nt-1 do begin
	    shp->idlffshape::addattribute, tags(i),7,25
	  endfor
	endif
	attrNew = shp->IDLffShape::GetAttributes(/attribute_structure)
	attrNew.Attribute_0 = systime()
	if n_elements(att) ne 0 then begin
	  for i=0,nt-1 do begin
	    attrNew.(i+1) = att.(i)
	  endfor
	endif
	shp->IDLffShape::SetAttributes, 0, attrNew
 
	;---------------------------------
	;  Close the shape file
	;---------------------------------
	obj_destroy, shp		; This closes the file.
	print,' Shape file complete: '+filename
	print,' Has '+strtrim(n,2)+' points.'
 
	end
