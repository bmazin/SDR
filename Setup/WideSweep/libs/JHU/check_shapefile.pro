;-------------------------------------------------------------
;+
; NAME:
;       CHECK_SHAPEFILE
; PURPOSE:
;       Look at details of a shapefile. Show some access commands.
; CATEGORY:
; CALLING SEQUENCE:
;       check_shapefile, file
; INPUTS:
;       file = name of shapefile.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: How to deal with attributes of an entity
;         Each entity in the shape file has a number of
;         attributes.  Those attributes have values.
;         This routine will find the possible values of a selected
;         attribute.
;         To access a shape file:
;           s = obj_new('IDLffShape',file)
;         The number of entities in the file is found by:
;           s->IDLffShape::GetProperty, n_entities=num
;         The names of the attributes are found by:
;           s->IDLffShape::GetProperty,attribute_names=attnames
;         To get the i'th (i<num) entity in structure t:
;           t = s->IDLffShape::GetEntity(i,/attributes)
;         The attribute structure is then
;           att = *t.attributes
;         The value of the j'th attribute is
;           val = att.(j)
;           To apply this must known j and the target value.
;         Must free all pointers in the entity structure:
;           ptr_free,t.VERTICES,t.MEASURE,t.PARTS,t.PART_TYPES,t.ATTRIBUTES
;         Also destory the object when done:
;           obj_destroy, s
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Apr 05
;       R. Sterner, 2004 Jul 15 --- Listed Number of entities, type.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro check_shapefile, file, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Look at details of a shapefile. Show some access commands.'
	  print,' check_shapefile, file'
	  print,'   file = name of shapefile.   in'
	  print,' Notes: How to deal with attributes of an entity'
	  print,'   Each entity in the shape file has a number of'
	  print,'   attributes.  Those attributes have values.'
	  print,'   This routine will find the possible values of a selected'
	  print,'   attribute.'
	  print,'   To access a shape file:'
	  print,"     s = obj_new('IDLffShape',file)"
	  print,'   The number of entities in the file is found by:'
	  print,'     s->IDLffShape::GetProperty, n_entities=num'
	  print,'   The names of the attributes are found by:'
	  print,'     s->IDLffShape::GetProperty,attribute_names=attnames'
	  print,"   To get the i'th (i<num) entity in structure t:"
	  print,'     t = s->IDLffShape::GetEntity(i,/attributes)'
	  print,'   The attribute structure is then'
	  print,'     att = *t.attributes'
	  print,"   The value of the j'th attribute is"
	  print,'     val = att.(j)'
	  print,'     To apply this must known j and the target value.'
	  print,'   Must free all pointers in the entity structure:'
	  print,'     ptr_free,t.VERTICES,t.MEASURE,t.PARTS,t.PART_TYPES,t.ATTRIBUTES'
	  print,'   Also destory the object when done:'
	  print,'     obj_destroy, s'
	  return
	endif
 
	;-------  Set up  --------------------
	s = obj_new('IDLffShape',file)			; Open shape file.
 
	s->IDLffShape::GetProperty, n_entities=num	; # items in file.
	s->IDLffShape::GetProperty, n_attributes=numa	; # attributes in file.
	s->IDLffShape::GetProperty, n_records=numr	; # attributes in file.
print,' # entities = ',num
print,' # attributes = ',numa
print,' # records = ',numr
help,num,numa,numr
	s->IDLffShape::GetProperty,attribute_names=attnames ; Attribute names.
	s->idlffshape::getproperty, entity_type=typ
	typtxt = 'Type unknown'
	if typ eq 1 then typtxt='Point'
	if typ eq 3 then typtxt='Polyline'
	if typ eq 5 then typtxt='Polygon'
 
	;-------  Get first entity  ---------
	t = s->IDLffShape::GetEntity(0,/attributes)
	att = *t.attributes
	ptr_free,t.VERTICES,t.MEASURE,t.PARTS,t.PART_TYPES,t.ATTRIBUTES
	tags = tag_names(att)				; Get attribute tags.
	vals = strarr(n_tags(att))			; Space for attr values.
	for i=0,n_tags(att)-1 do vals(i)=string(att.(i)) ; Extract values.
	print,' '
	print,' Number of entities in file: '+strtrim(num,2)
	print,' Entity type: '+strtrim(typ,2)+' = '+typtxt
	print,' '
	more,/n,tags+'  '+attnames+' =  '+vals
	print,' '
 
	;-------  Get attribute to map out  -------
	txt = ''
	read,' Enter attribute # to index on: ',txt
	if txt eq '' then return
	in = txt+0
 
	;-------  Get loop end  -----------------
	print,' '
	print,' There are '+strtrim(num,2)+' entities in the file'
	read,' Enter last entity to index (def=last): ',txt
	if txt eq '' then last=num-1 else last=txt+0L
 
	;-------  Set up a hash table to find all values of key  ----
	hash_init, key=att.(in), val=1L, n_main=6000, n_over=100, hash=h
 
	;-------  Loop through entities  --------
	for i=0L,last do begin
	  if (i mod 1000) eq 0 then print,i
	  t = s->IDLffShape::GetEntity(i,/attributes)
	  att = *t.attributes
	  ptr_free,t.VERTICES,t.MEASURE,t.PARTS,t.PART_TYPES,t.ATTRIBUTES
	  key = att.(in)
	  val = hash_get(key, hash=h,err=err,/quiet)
	  if err eq 0 then val=val+1 else val=1
	  hash_put,hash=h, key,val, new=new
	  if new then print,' ',key
	endfor
 
	hash_list, h, outkeys=keys, outvals=vals, /quiet
	tot = long(total(vals))
	vals = strtrim(vals,2)
 
	print,' '
	print,' Values (and counts) found for '+tags(in)+ $
	  ' (= '+attnames(in)+'):'
	more,/num,keys+' = '+vals,lines=50
	print,' Total count: ',tot
 
	;------  Cleanup  ---------
	obj_destroy, s
 
	end
 
