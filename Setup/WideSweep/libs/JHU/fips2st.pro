;-------------------------------------------------------------
;+
; NAME:
;       FIPS2ST
; PURPOSE:
;       From 2 digit FIPS code return 2 letter state abbreviation.
; CATEGORY:
; CALLING SEQUENCE:
;       st = fips2st(fips)
; INPUTS:
;       fips = 2 digit state FIPS code string. in
; KEYWORD PARAMETERS:
;       Keywords:
;         NAME=nam  Returned full name.
;         /LIST list all states and their FIPS codes.
; OUTPUTS:
;       st = 2 letter state abbreviation.      out
;         Null string means error.
; COMMON BLOCKS:
;       st2fips_com
; NOTES:
;       Notes: Example: fips2st(42) returns 'PA'.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jul 08
;       R. Sterner, 2004 Jul 16 --- Added /LIST.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function fips2st, fips, name=nam, list=list, help=hlp
 
	common st2fips_com, st2, fips2, name
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' From 2 digit FIPS code return 2 letter state abbreviation.'
	  print,' st = fips2st(fips)'
	  print,'   fips = 2 digit state FIPS code string. in'
	  print,'   st = 2 letter state abbreviation.      out'
	  print,'     Null string means error.'
	  print,' Keywords:'
	  print,'   NAME=nam  Returned full name.'
	  print,'   /LIST list all states and their FIPS codes.'
	  print," Notes: Example: fips2st(42) returns 'PA'."
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
	fipstxt = string(fips,form='(I2.2)')
	w = where(fipstxt eq fips2, cnt)
	if cnt eq 0 then return,''
	nam = name(w(0))
 
	if keyword_set(list) then begin
	  more,' '+fips2+'  '+st2+'  '+name
	endif
 
	return, st2(w(0))
 
	end
