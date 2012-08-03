;-------------------------------------------------------------
;+
; NAME:
;       ST2FIPS
; PURPOSE:
;       From 2 letter state abbreviation return 2 digit FIPS code.
; CATEGORY:
; CALLING SEQUENCE:
;       fips = st2fips(st)
; INPUTS:
;       st = 2 letter state abbreviation.      in
;         NULL strings returns list of all
;         FIPS codes in fips, all state names
;         through the NAME keyword, and all
;         2 letter state abbreviation through
;         the STATE keyword.
; KEYWORD PARAMETERS:
;       Keywords:
;         NAME=nam  Returned full name.
;         STATE=state  Returned 2 letter state abbreviation2
;           when called with a null string.
;         /LIST list all states and their FIPS codes.
; OUTPUTS:
;       fips = 2 digit state FIPS code string. out
;         Null string means error.
; COMMON BLOCKS:
;       st2fips_com
; NOTES:
;       Notes: Example: st2fips('pa') returns '42'.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jul 07
;       R. Sterner, 2004 Jul 12 --- Return all FIPS option.
;       R. Sterner, 2004 Jul 16 --- Added /LIST.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function st2fips, st, name=nam, state=state, list=list, help=hlp
 
	common st2fips_com, st2, fips2, name
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' From 2 letter state abbreviation return 2 digit FIPS code.'
	  print,' fips = st2fips(st)'
	  print,'   st = 2 letter state abbreviation.      in'
	  print,'     NULL strings returns list of all'
	  print,'     FIPS codes in fips, all state names'
	  print,'     through the NAME keyword, and all'
	  print,'     2 letter state abbreviation through'
	  print,'     the STATE keyword.'
	  print,'   fips = 2 digit state FIPS code string. out'
	  print,'     Null string means error.'
	  print,' Keywords:'
	  print,'   NAME=nam  Returned full name.'
	  print,'   STATE=state  Returned 2 letter state abbreviation2'
	  print,'     when called with a null string.'
	  print,'   /LIST list all states and their FIPS codes.'
	  print," Notes: Example: st2fips('pa') returns '42'."
	  return,''
	endif
 
	;------  Initialize  -------------
	if n_elements(st2) eq 0 then begin
	  whoami, dir
	  file = filename(dir,'st_fips.txt',/nosym)
	  s = txtdb_rd(file)
	  st2 = s.st
	  fips2 = string(s.fips,form='(I2.2)')
	  name = s.name
	endif
 
	;-----  Process request  ---------
	nam = ''
	if st eq '' then begin
	  nam = name
	  state = st2
	  return, fips2
	endif
	w = where(strupcase(st) eq st2, cnt)
	if cnt eq 0 then return,''
	nam = name(w(0))
 
	if keyword_set(list) then begin
	  more,' '+fips2+'  '+st2+'  '+name
	endif
 
	return, fips2(w(0))
 
	end
