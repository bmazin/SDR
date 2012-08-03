;-------------------------------------------------------------
;+
; NAME:
;       M_PUT
; PURPOSE:
;       Save a value by a tag name in a global area.
; CATEGORY:
; CALLING SEQUENCE:
;       m_put, tag, val
; INPUTS:
;       tag = Tag name for value.   in
;         (spaces converted to _)
;       val = Value to save.        in
;         Any IDL data item, scalars, arrays, structures,
;         even objects.
; KEYWORD PARAMETERS:
;       Keywords:
;         AREA=aname Name of area to use (def="DEFAULT").
;           Limit of 9 named areas (plus default area).
;           (spaces converted to _)
;         DEFAULT=area Name of area to default to instead
;           of "DEFAULT".  Later calls to m_put, m_list, or
;           m_get will use this default area instead of "DEFAULT".
;           To clear back to the normal default, call with
;           DEFAULT="DEFAULT".  The default keyword will work on
;           any of the m_* routines.
;         /CLEAR clear an area or a tag.
;           If a tag name is given that tag wil be cleared in
;           the default or specified area.  If tag name is not
;           given then the specified area will be cleared.
;         ERROR=err Error flag: 0=ok.
;         /QUIET inhibit error messages.
; OUTPUTS:
; COMMON BLOCKS:
;       m_put_common
; NOTES:
;       Notes: This routine is used to save values under given
;       names to be retrieved later using m_get.  m_get may be
;       used in another routine, no values need be passed to it.
;       Values are saved in areas, there are 10 such areas, one
;       default area and 9 which are specified by an area name.
;       If an area name is not given the default area is used.
;       The name "default" (case ignored) will use the default area.
;       
;       Use m_get or m_fun to retrieve items from a global area,
;         m_list to list items in the global areas.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 05
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro m_put, tag0, val, area=aname0, clear=clear, error=m_err, $
	  default=adef0, quiet=quiet, help=hlp
 
	common m_put_common, s0,s1,s2,s3,s4,s5,s6,s7,s8,s9, area, free, adef
 
	if keyword_set(hlp) then begin
help:	  print,' Save a value by a tag name in a global area.'
	  print,' m_put, tag, val'
	  print,'   tag = Tag name for value.   in'
	  print,'     (spaces converted to _)'
	  print,'   val = Value to save.        in'
	  print,'     Any IDL data item, scalars, arrays, structures,'
	  print,'     even objects.'
	  print,' Keywords:'
	  print,'   AREA=aname Name of area to use (def="DEFAULT").'
	  print,'     Limit of 9 named areas (plus default area).'
	  print,'     (spaces converted to _)'
	  print,'   DEFAULT=area Name of area to default to instead'
	  print,'     of "DEFAULT".  Later calls to m_put, m_list, or'
	  print,'     m_get will use this default area instead of "DEFAULT".'
	  print,'     To clear back to the normal default, call with'
	  print,'     DEFAULT="DEFAULT".  The default keyword will work on'
	  print,'     any of the m_* routines.'
	  print,'   /CLEAR clear an area or a tag.'  
	  print,'     If a tag name is given that tag wil be cleared in'
	  print,'     the default or specified area.  If tag name is not'
	  print,'     given then the specified area will be cleared.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,'   /QUIET inhibit error messages.'
	  print,' Notes: This routine is used to save values under given'
	  print,' names to be retrieved later using m_get.  m_get may be'
	  print,' used in another routine, no values need be passed to it.'
	  print,' Values are saved in areas, there are 10 such areas, one'
	  print,' default area and 9 which are specified by an area name.'
	  print,' If an area name is not given the default area is used.'
	  print,' The name "default" (case ignored) will use the default area.'
	  print,' '
	  print,' Use m_get or m_fun to retrieve items from a global area,'
	  print,'   m_list to list items in the global areas.'
	  return
	endif
 
	m_err = 0			; Error flag: none yet.
 
	;---------------------------------------------------------------
	; Initialize
	; 
	; The structure AREA contains area names as tags.  The
	;   value of each tag is the area index: 0 means s0 is the area,
	;   1 means s1 is the area, ...
	; The actual areas are the structures s0, s1, ..., s9.
	;   When not in use these are null strings.
	; The array FREE contains flags for each possible area, 10
	;   in all.  The flags are 1 if the area is free, else 0.
	; The default area is s0 and named "DEFAULT".  Its free flag is 0.
	;---------------------------------------------------------------
	if n_elements(area) eq 0 then begin
	  area = {DEFAULT:0}
	  adef = 'DEFAULT'
	  free = [0,1,1,1,1,1,1,1,1,1]
	  s0='' & s1='' & s2='' & s3='' & s4=''
	  s5='' & s6='' & s7='' & s8='' & s9=''
	endif
 
	;---------------------------------------------------------------
	; Determine Area
	;
	; Area names are converted to lower case so case is ignored.
	; If no area name is given "DEFAULT" is used.
	;---------------------------------------------------------------
	if n_elements(adef0) gt 0 then adef=adef0	; Set new default area.
	adef = strupcase(adef)				; Uppercase default.
	if n_elements(aname0) eq 0 then aname0=adef	; Use default area.
	aname = repchr(aname0,' ','_')			; Fix spaces.
	aname = strupcase(aname)			; Uppercase aname.
	in = tag_value(area,aname,err=a_err)		; Get area index.
 
	;---------------------------------------------------------------
	; /CLEAR: Clear an area or tag.
	;---------------------------------------------------------------
	if keyword_set(clear) then begin
	  if a_err ne 0 then begin
	    if not keyword_set(quiet) then $
	      print,' Error in m_put: trying to clear a non-existant area.'
	    m_err = 1
	    return
	  endif
	  ;-----------------------------------
	  ; Clear an area
	  ;
	  ; Also drop area name and
	  ; flag as free.
	  ;-----------------------------------
	  if n_elements(tag0) eq 0 then begin
	    if in gt 0 then begin		; If not DEFAULT area ...
	      area = tag_drop(area,aname)	; Drop area name.
	      free(in) = 1			; Flag specified area as free.
	      if aname eq adef then adef='DEFAULT'  ; Fix default area.
	    endif
	    case in of				; Clear specified area.
	  0: s0=''
	  1: s1=''
	  2: s2=''
	  3: s3=''
	  4: s4=''
	  5: s5=''
	  6: s6=''
	  7: s7=''
	  8: s8=''
	  9: s9=''
	    endcase
	  ;-----------------------------------
	  ; Clear a tag
	  ;
	  ; If last tag cleared then drop
	  ; area and flag as free.
	  ;-----------------------------------
	  endif else begin
	    tag = repchr(tag0,' ','_')	; Spaces convert to _.
	    case in of	; Clear tag in specified area.
	  0: begin
	       s0=tag_drop(s0,tag)
	     end
	  1: begin
	       s1=tag_drop(s1,tag)
	       if datatype(s1) eq 'STR' then begin
		 free(1) = 1				; Flag area as free.
	         area = tag_drop(area,aname)		; Drop area name.
	         if aname eq adef then adef='DEFAULT'	; Fix default area.
	       endif
	     end
	  2: begin
	       s2=tag_drop(s2,tag)
	       if datatype(s2) eq 'STR' then begin
		 free(2) = 1
	         area = tag_drop(area,aname)
	         if aname eq adef then adef='DEFAULT'
	       endif
	     end
	  3: begin
	       s3=tag_drop(s3,tag)
	       if datatype(s3) eq 'STR' then begin
		 free(3) = 1
	         area = tag_drop(area,aname)
	         if aname eq adef then adef='DEFAULT'
	       endif
	     end
	  4: begin
	       s4=tag_drop(s4,tag)
	       if datatype(s4) eq 'STR' then begin
		 free(4) = 1
	         area = tag_drop(area,aname)
	         if aname eq adef then adef='DEFAULT'
	       endif
	     end
	  5: begin
	       s5=tag_drop(s5,tag)
	       if datatype(s5) eq 'STR' then begin
		 free(5) = 1
	         area = tag_drop(area,aname)
	         if aname eq adef then adef='DEFAULT'
	       endif
	     end
	  6: begin
	       s6=tag_drop(s6,tag)
	       if datatype(s6) eq 'STR' then begin
		 free(6) = 1
	         area = tag_drop(area,aname)
	         if aname eq adef then adef='DEFAULT'
	       endif
	     end
	  7: begin
	       s7=tag_drop(s7,tag)
	       if datatype(s7) eq 'STR' then begin
		 free(7) = 1
	         area = tag_drop(area,aname)
	         if aname eq adef then adef='DEFAULT'
	       endif
	     end
	  8: begin
	       s8=tag_drop(s8,tag)
	       if datatype(s8) eq 'STR' then begin
		 free(8) = 1
	         area = tag_drop(area,aname)
	         if aname eq adef then adef='DEFAULT'
	       endif
	     end
	  9: begin
	       s9=tag_drop(s9,tag)
	       if datatype(s9) eq 'STR' then begin
		 free(9) = 1
	         area = tag_drop(area,aname)
	         if aname eq adef then adef='DEFAULT'
	       endif
	     end
	    endcase
	  endelse
	  return
	endif  ; /CLEAR.
 
	;---------------------------------------------------------------
	;  Save given item.
	;---------------------------------------------------------------
	if n_elements(tag0) eq 0 then goto, help
	tag = repchr(tag0,' ','_')	; Spaces convert to _.
	if n_elements(val) eq 0 then begin
	  if not keyword_set(quiet) then $
	    print,' Error in m_put: Must give a value.'
	  m_err = 1
	  return
	endif
	;-----------------------------------
	; New area
	;
	; Check if any new areas are
	; available.  If so then create
	; new structure in that area.
	;-----------------------------------
	if a_err ne 0 then begin
	  w = where(free eq 1,cnt)	; Look for a free area.
	  if cnt eq 0 then begin
	    if not keyword_set(quiet) then $
	      print,' Error in m_put: Cannot create new area, all in use.'
	    m_err = 1
	    return
	  endif
	  in = w(0)				; Next free area.
	  free(in) = 0				; Flag as used.
	  area = create_struct(area,aname,in)	; Add new area name.
	  case in of			; Create a structure in specified area.
;	0: s0=create_struct(tag,val)	; Default always exists.
	1: s1=create_struct(tag,val)
	2: s2=create_struct(tag,val)
	3: s3=create_struct(tag,val)
	4: s4=create_struct(tag,val)
	5: s5=create_struct(tag,val)
	6: s6=create_struct(tag,val)
	7: s7=create_struct(tag,val)
	8: s8=create_struct(tag,val)
	9: s9=create_struct(tag,val)
	  endcase
	;-----------------------------------
	; Existing area
	;-----------------------------------
	endif else begin
	  case in of			; Add tag and val in specified area.
	0: begin  ; DEFAULT area (always in name list even if cleared).
	    if datatype(s0) eq 'STR' then begin	; Still cleared.
	      s0 = create_struct(tag,val)
	    endif else begin					; In used.
	      if tag_test(s0,tag) then s0=tag_drop(s0,tag)	; Tag in use, drop first.
	      if datatype(s0) eq 'STR' then begin		; Was all dropped, no tags.
	       s0=create_struct(tag,val)			;   Recreate s0 with new.
	      endif else begin
	       s0 = create_struct(s0,tag,val)			; Else add tag.
	      endelse
	    endelse
	   end
	1: begin
	     if tag_test(s1,tag) then s1=tag_drop(s1,tag)
	     if datatype(s1) eq 'STR' then begin
	       s1=create_struct(tag,val)
	     endif else begin
	       s1=create_struct(s1,tag,val)
	     endelse
	   end
	2: begin
	     if tag_test(s2,tag) then s2=tag_drop(s2,tag)
	     if datatype(s2) eq 'STR' then begin
	       s2=create_struct(tag,val)
	     endif else begin
	       s2=create_struct(s2,tag,val)
	     endelse
	   end
	3: begin
	     if tag_test(s3,tag) then s3=tag_drop(s3,tag)
	     if datatype(s3) eq 'STR' then begin
	       s3=create_struct(tag,val)
	     endif else begin
	       s3=create_struct(s3,tag,val)
	     endelse
	   end
	4: begin
	     if tag_test(s4,tag) then s4=tag_drop(s4,tag)
	     if datatype(s4) eq 'STR' then begin
	       s4=create_struct(tag,val)
	     endif else begin
	       s4=create_struct(s4,tag,val)
	     endelse
	   end
	5: begin
	     if tag_test(s5,tag) then s5=tag_drop(s5,tag)
	     if datatype(s5) eq 'STR' then begin
	       s5=create_struct(tag,val)
	     endif else begin
	       s5=create_struct(s5,tag,val)
	     endelse
	   end
	6: begin
	     if tag_test(s6,tag) then s6=tag_drop(s6,tag)
	     if datatype(s6) eq 'STR' then begin
	       s6=create_struct(tag,val)
	     endif else begin
	       s6=create_struct(s6,tag,val)
	     endelse
	   end
	7: begin
	     if tag_test(s7,tag) then s7=tag_drop(s7,tag)
	     if datatype(s7) eq 'STR' then begin
	       s7=create_struct(tag,val)
	     endif else begin
	       s7=create_struct(s7,tag,val)
	     endelse
	   end
	8: begin
	     if tag_test(s8,tag) then s8=tag_drop(s8,tag)
	     if datatype(s8) eq 'STR' then begin
	       s8=create_struct(tag,val)
	     endif else begin
	       s8=create_struct(s8,tag,val)
	     endelse
	   end
	9: begin
	     if tag_test(s9,tag) then s9=tag_drop(s9,tag)
	     if datatype(s9) eq 'STR' then begin
	       s9=create_struct(tag,val)
	     endif else begin
	       s9=create_struct(s9,tag,val)
	     endelse
	   end
	  endcase
	endelse
 
 
	end
