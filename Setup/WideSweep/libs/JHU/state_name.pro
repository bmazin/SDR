;-------------------------------------------------------------
;+
; NAME:
;       STATE_NAME
; PURPOSE:
;       Return name of state given 2 letter abbreviation.
; CATEGORY:
; CALLING SEQUENCE:
;       name = state_name(ss)
; INPUTS:
;       ss = 2 letter abbreviation of state.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /UNDER  means replace spaces in name with underscore (_).
;         /DASH   means replace spaces in name with dash (-).
;         /LOWER  means all lower case.
;         /UPPER  means all upper case.
;         /SQUEEZE  means squeeze out all spaces.
; OUTPUTS:
;       name = full name of state.            out
;         If called with no arguments all 2 letter abbreviations
;         are returned.
; COMMON BLOCKS:
;       state_name_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Jan 27
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function state_name, state, under=und, lower=low, upper=up, $
	  squeeze=sq, dash=dsh, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return name of state given 2 letter abbreviation.'
	  print,' name = state_name(ss)'
	  print,'   ss = 2 letter abbreviation of state.  in'
	  print,'   name = full name of state.            out'
	  print,'     If called with no arguments all 2 letter abbreviations'
	  print,'     are returned.'
	  print,' Keywords:'
	  print,'   /UNDER  means replace spaces in name with underscore (_).'
	  print,'   /DASH   means replace spaces in name with dash (-).'
	  print,'   /LOWER  means all lower case.'
	  print,'   /UPPER  means all upper case.'
	  print,'   /SQUEEZE  means squeeze out all spaces.'
	  return,''
	endif
 
	common state_name_com, s, n
 
	if n_elements(s) eq 0 then begin
	  whoami, dir
	  f = filename(dir,'state_names.txt',/nosym)
	  a = getfile(f)
	  s = strlowcase(strmid(a,0,2))
	  n = strmid(a,3,99)
	endif
 
	if n_params(0) lt 1 then return, s	; Return 2 letter abbrev.
 
	w = (where(strlowcase(state) eq s, cnt))(0)
	if cnt lt 1 then return, ''
	t = n(w)
 
	if keyword_set(und) then t=repchr(t,' ','_')
	if keyword_set(dsh) then t=repchr(t,' ','-')
	if keyword_set(low) then t=strlowcase(t)
	if keyword_set(up) then t=strupcase(t)
	if keyword_set(sq) then t=strcompress(t,/remove)
 
	return,t
	
	end
