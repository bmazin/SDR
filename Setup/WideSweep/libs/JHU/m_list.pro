;-------------------------------------------------------------
;+
; NAME:
;       M_LIST
; PURPOSE:
;       List values in global areas saved by m_put.
; CATEGORY:
; CALLING SEQUENCE:
;       m_list
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         AREA=aname Name of area to list (def="DEFAULT").
;           (spaces converted to _)
;         DEFAULT=area Name of area to default to instead
;           of "DEFAULT".  Later calls to m_put, m_list, or
;           m_get will use this default area instead of "DEFAULT".
;           To clear back to the normal default, call with
;           DEFAULT="DEFAULT".  The default keyword will work on
;           any of the m_* routines.
;         /ALL list all areas.
;         OUT=txt Return listed text.
;         /QUIET Do not list on screen.
; OUTPUTS:
; COMMON BLOCKS:
;       m_put_common
; NOTES:
;       Notes: Use m_put to add items to the global area,
;         m_get or m_fun to retrieve them.
;         Tags in each area are listed in the order last added
;         or updated last.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 may 05
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro m_list, area=aname0, all=all, out=txt, quiet=quiet, $
	  default=adef0, help=hlp
 
	common m_put_common, s0,s1,s2,s3,s4,s5,s6,s7,s8,s9, area, free, adef
 
	if keyword_set(hlp) then begin
	  print,' List values in global areas saved by m_put.'
	  print,' m_list'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   AREA=aname Name of area to list (def="DEFAULT").'
	  print,'     (spaces converted to _)'
	  print,'   DEFAULT=area Name of area to default to instead'
	  print,'     of "DEFAULT".  Later calls to m_put, m_list, or'
	  print,'     m_get will use this default area instead of "DEFAULT".'
	  print,'     To clear back to the normal default, call with'
	  print,'     DEFAULT="DEFAULT".  The default keyword will work on'
	  print,'     any of the m_* routines.'
	  print,'   /ALL list all areas.'
	  print,'   OUT=txt Return listed text.'
	  print,'   /QUIET Do not list on screen.'
	  print,' Notes: Use m_put to add items to the global area,'
	  print,'   m_get or m_fun to retrieve them.'
	  print,'   Tags in each area are listed in the order last added'
	  print,'   or updated last.'
	  return
	endif
 
	tprint,/init
	tprint,' '
	tprint,' Global memory contents'
	if keyword_set(quiet) then pr=0 else pr=1
 
	if n_elements(area) eq 0 then begin
	  tprint,' There are no items saved in the global areas.'
	  tprint,print=pr,out=txt
	  return
	endif
 
	;---------------------------------------------------------------
	; Determine Area
	;
	; Area names are converted to lower case so case is ignored.
	; If no area name is given the default area is used.
	; The default area is named "DEFAULT" unless redefined.
	;---------------------------------------------------------------
	if n_elements(adef0) gt 0 then begin		; A default area given.
	  if tag_test(area,adef0) eq 1 then begin	; Area exists.
	    adef = strupcase(adef0)			; Set new default area.
	  endif else begin				; No such area.
	    print,' Error in m_list: Given default area does not exist: '+$
	      strupcase(adef0)
	    print,'   Default ignored.'
	  endelse
	endif
	if n_elements(aname0) eq 0 then aname0=adef	; Use default area.
	aname = repchr(aname0,' ','_')			; Fix spaces.
	in = tag_value(area,aname,err=a_err)		; Get area index.
	if keyword_set(all) then in=where(free eq 0)	; Get all indices.
	anams0 = tag_names(area)	; All area names.
	anams = strarr(10)		; Possible indices (0 to 9).
	for i=0,n_tags(area)-1 do begin ; Save area name under area index.
	  t = anams0(i)			; Next area tag name.
	  anams(tag_value(area,t)) = t	; Index into anams is tag value.
	endfor
 
	;---------------------------------------------------------------
	; Loop through all specified areas and list.
	;---------------------------------------------------------------
	for i=0, n_elements(in)-1 do begin
	  case in(i) of				; Clear specified area.
	0: s = s0
	1: s = s1
	2: s = s2
	3: s = s3
	4: s = s4
	5: s = s5
	6: s = s6
	7: s = s7
	8: s = s8
	9: s = s9
	  endcase
	  if datatype(s) eq 'STR' then continue	; Skip if DEFAULT cleared.
	  n = n_tags(s)
	  tags = tag_names(s)
	  txt = ''
	  if anams(in(i)) eq adef then txt='  <---<<< Default area'
	  tprint,' '
	  tprint,' Area name: '+anams(in(i))+' has '+ $
	    strtrim(n,2)+' item'+plural(n)+txt
	  for j=0,n-1 do begin
	    tprint,'  '+tags(j)+': '+datatype(s.(j),/desc)
	  endfor
	endfor
 
	n_free = fix(total(free))
	if datatype(s0) eq 'STR' then n_free = n_free + 1
	n_used = 10 - n_free
 
	tprint,' '
	tprint,' '+strtrim(n_used,1)+' area'+plural(n_used)+' used, '+$
	  strtrim(n_free,1)+' area'+plural(n_free)+' free.'
	tprint,' '
 
	tprint,print=pr, out=txt
 
	end
