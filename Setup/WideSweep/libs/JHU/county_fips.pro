;-------------------------------------------------------------
;+
; NAME:
;       COUNTY_FIPS
; PURPOSE:
;       Return list of county FIPS codes given state.
; CATEGORY:
; CALLING SEQUENCE:
;       cfips = county_fips(st)
; INPUTS:
;       st = state 2 letter abbreviation or 2 digit FIPS code.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         NAME=nam Returned array of county names.
;         /LIST list counties and their FIPS codes for a state.
; OUTPUTS:
;       cfips = Returned list of county FIPS codes.             out
; COMMON BLOCKS:
;       county_fips_com
; NOTES:
;       Notes: For county names with FIPS by state see
;         http://www.itl.nist.gov/fipspubs/co-codes/states.htm
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jul 12
;       R. Sterner, 2004 Jul 16 --- Added /LIST.
;       R. Sterner, 2004 Jul 21 --- Added state name and state FIPS to /list.
;       R. Sterner, 2005 Jan 28 --- Listed web site reference.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function county_fips, st0, name=nam, list=list, help=hlp
 
	common county_fips_com, s
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return list of county FIPS codes given state.'
	  print,' cfips = county_fips(st)'
	  print,'   st = state 2 letter abbreviation or 2 digit FIPS code.  in'
	  print,'   cfips = Returned list of county FIPS codes.             out'
	  print,' Keywords:'
	  print,'   NAME=nam Returned array of county names.'
	  print,'   /LIST list counties and their FIPS codes for a state.'
	  print,' Notes: For county names with FIPS by state see'
	  print,'   http://www.itl.nist.gov/fipspubs/co-codes/states.htm'
	  return,''
	endif
 
	if n_elements(s) eq 0 then begin
	  whoami, dir
	  file = filename(dir,'County_FIPS_codes.sav',/nosym)
	  restore_named, file, s
	endif
 
	st = st0
	if isnumber(st) then st=fips2st(st)	; Want 2 letter code.
 
	t = tag_value(s,st+'_0')
	nam = t.name
	fips = t.fips
 
	if keyword_set(list) then begin
	  st_fips = st2fips(st,name=st_name)
	  print,' '
	  print,' '+st_name+'  '+st+' '+st_fips
	  more,' '+fips+' '+nam
	endif
 
	return, fips
 
	end
