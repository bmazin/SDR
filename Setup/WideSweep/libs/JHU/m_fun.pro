;-------------------------------------------------------------
;+
; NAME:
;       M_FUN
; PURPOSE:
;       Function to get a value by tag name from a global area.
; CATEGORY:
; CALLING SEQUENCE:
;       val = m_fun(tag)
; INPUTS:
;       tag = Tag name for value.   in
;         (spaces converted to _)
; KEYWORD PARAMETERS:
;       Keywords:
;         AREA=aname Name of area to use (def="DEFAULT").
;           (spaces converted to _)
;         DEFAULT=area Name of area to default to instead
;           of "DEFAULT".  Later calls to m_put, m_list, or
;           m_fun will use this default area instead of "DEFAULT".
;           To clear back to the normal default, call with
;           DEFAULT="DEFAULT".  The default keyword will work on
;           any of the m_* routines.
;         ERROR=err Error flag: 0=ok.
;         /QUIET inhibit error messages.
; OUTPUTS:
;       val = Returned value.       out
; COMMON BLOCKS:
;       m_put_common
; NOTES:
;       Notes: Use m_put to add items to the global area,
;         m_list to list items in the global areas.
;         m_get is a procedure version of m_fun.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 10
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function m_fun, tag0, val, area=aname0, error=m_err, $
	  default=adef0, quiet=quiet, help=hlp
 
	common m_put_common, s0,s1,s2,s3,s4,s5,s6,s7,s8,s9, area, free, adef
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Function to get a value by tag name from a global area.'
	  print,' val = m_fun(tag)'
	  print,'   tag = Tag name for value.   in'
	  print,'     (spaces converted to _)'
	  print,'   val = Returned value.       out'
	  print,' Keywords:'
	  print,'   AREA=aname Name of area to use (def="DEFAULT").'
	  print,'     (spaces converted to _)'
	  print,'   DEFAULT=area Name of area to default to instead'
	  print,'     of "DEFAULT".  Later calls to m_put, m_list, or'
	  print,'     m_fun will use this default area instead of "DEFAULT".'
	  print,'     To clear back to the normal default, call with'
	  print,'     DEFAULT="DEFAULT".  The default keyword will work on'
	  print,'     any of the m_* routines.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,'   /QUIET inhibit error messages.'
	  print,' Notes: Use m_put to add items to the global area,'
	  print,'   m_list to list items in the global areas.'
	  print,'   m_get is a procedure version of m_fun.'
	  return,''
	endif
 
	m_err = 0			; Error flag: none yet.
 
	if n_elements(tag0) eq 0 then begin
	  if not keyword_set(quiet) then $
	    print,' Error in m_fun: Tag is undefined.'
	  m_err = 1
	  return,''
	endif
 
	if n_elements(area) eq 0 then begin
	  if not keyword_set(quiet) then $
	    print,' Error in m_fun: There are no items saved'+$
	      ' in the global areas.'
	  m_err = 1
	  return,''
	endif
 
	;---------------------------------------------------------------
	; Determine Area
	;
	; Area names are converted to lower case so case is ignored.
	; If no area name is given "DEFAULT" is used.
	;---------------------------------------------------------------
	if n_elements(adef0) gt 0 then begin		; A default area given.
	  if tag_test(area,adef0) eq 1 then begin	; Area exists.
	    adef = adef0				; Set new default area.
	  endif else begin				; No such area.
	    if not keyword_set(quiet) then $
	      print,' Error in m_fun: Given default area does not exist: '+$
	        strupcase(adef0)
	    m_err = 1
	    return,''
	  endelse
	endif
	if n_elements(aname0) eq 0 then aname0=adef	; Use default area.
	aname = repchr(aname0,' ','_')			; Fix spaces.
	in = tag_value(area,aname,err=a_err)		; Get area index.
 
	;---------------------------------------------------------------
	;  Retrieve requested item.
	;---------------------------------------------------------------
	tag = repchr(tag0,' ','_')	; Spaces convert to _.
	case in of				; Clear specified area.
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
	if datatype(s) eq 'STR' then begin
	  if not keyword_set(quiet) then $
	    print,' Error in m_fun: Specified area ('+aname+') not in use.'
	  m_err = 1
	  return,''
	endif
	val = tag_value(s, tag, err=m_err)
	if m_err ne 0 then $
	  if not keyword_set(quiet) then $
	    print,' Error in m_fun: Specified tag ('+tag+') undefined '+ $
	      'for area = '+aname+'.'
 
	return, val
 
	end
