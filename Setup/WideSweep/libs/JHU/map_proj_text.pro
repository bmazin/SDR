;-------------------------------------------------------------
;+
; NAME:
;       MAP_PROJ_TEXT
; PURPOSE:
;       Return map projection descriptive text
; CATEGORY:
; CALLING SEQUENCE:
;       map_proj_text, txt
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       txt = returned text array.   out
; COMMON BLOCKS:
; NOTES:
;       Note: txt contains projection name,
;         central lat,long,rotation angle,
;         and latitudes of any standard parallels.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jan 14
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_proj_text, txt, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return map projection descriptive text'
	  print,' map_proj_text, txt'
	  print,'   txt = returned text array.   out'
	  print,' Note: txt contains projection name,'
	  print,'   central lat,long,rotation angle,'
	  print,'   and latitudes of any standard parallels.'
	  return
	endif
 
	;------  Make sure the last plot was a map command   -----
	if !x.type ne 3 then begin
	  print,' Error in map_proj_text: No map projection'
	  print,'   info available.  Check if map_set has been done.'
	  return
	endif
 
	;-------  Set up projection name table  ---------------
	names = ['', $
		'Stereographic', $
		'Orthographic', $
		'Lambert Conformal Conic', $
		'Lambert Azimuthal Equal Area', $
		'Gnomic', $
		'Azimuthal Equidistant', $
		'Satellite', $
		'Cylindrical', $
		'Mercator', $
		'Mollweide', $
		'Sinusoidal', $
		'Aitoff', $
		'Hammer-Aitoff', $
		'Albers Equal Area Conic', $
		'Transverse Mercator', $
		'Miller Cylindrical', $
		'Robinson Pseudo-Cylindrical', $
		'Lambert Conic Ellipsoid', $
		'Goodes Homolosine', $
		'']
 
	;-----  Get basic map parameters  ------------
	out = str_cliptrail0([!map.p0lat,!map.p0lon,!map.rotation])
	lat0 = out(0)
	lng0 = out(1)
	ang = out(2)
 
	code = !map.projection
	proj = names(code)
 
	;-----  Satellite projection  ----------
	if code eq 7 then begin
	  h = !map.p(0) - 1.
	  a_miles = strtrim(string(h*earthrad('miles'),form='(F20.1)'),2)
	  a_km = strtrim(string(h*earthrad('km'),form='(F20.1)'),2)
	  atxt = ', Altitude: '+a_miles+' miles = '+a_km+' km'
	endif else atxt=''
 
	std_p = str_cliptrail0(!map.p[[3,4]]/!dtor)
	if std_p(0) eq std_p(1) then std_p = std_p(0)	; Keep just 1.
 
	;-----  Pack up output  -----------------
	txt = [proj+atxt,'Central lat, lon, ang: '+lat0+', '+lng0+', '+ang]
 
	;---  Special cases: Conic, Albers  ------------------
	if (code eq 3) or (code eq 14) then begin
	  np = n_elements(std_p)
	  ptxt = 'Standard Parallel'+plural(np)+': '+commalist(std_p)
	  txt = [txt,ptxt]
	endif
 
	end
