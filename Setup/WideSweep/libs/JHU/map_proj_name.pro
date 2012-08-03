;-------------------------------------------------------------
;+
; NAME:
;       MAP_PROJ_NAME
; PURPOSE:
;       Convert map_set projection number to projection name.
; CATEGORY:
; CALLING SEQUENCE:
;       name = map_proj_name( proj)
; INPUTS:
;       proj = projection number.  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       name = projection name.    out
; COMMON BLOCKS:
; NOTES:
;       Note: projection number is the number set by the
;       map_set command and may be found in !map.projection
;       after map_set is executed.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 27 (split off from map_set_scale).
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function map_proj_name, proj, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert map_set projection number to projection name.'
	  print,' name = map_proj_name( proj)'
	  print,'   proj = projection number.  in'
	  print,'   name = projection name.    out'
	  print,' Note: projection number is the number set by the'
	  print,' map_set command and may be found in !map.projection'
	  print,' after map_set is executed.'
	  return,''
	endif
 
	names = ['', $
		'Stereographic', $
		'Orthographic', $
		'Lambert Conic', $
		'Lambert Azimuthal', $
		'Gnomic', $
		'Azimuthal Equidistant', $
		'Satellite', $
		'Cylindrical', $
		'Mercator', $
		'Mollweide', $
		'Sinusoidal', $
		'Aitoff', $
		'Hammer Aitoff', $
		'Albers Equal Area Conic', $
		'Transverse Mercator', $
		'Miller Cylindrical', $
		'Robinson', $
		'Lambert Conic Ellipsoid', $
		'Goodes Homolosine', $
		'']
 
	return, (names([proj]))(0)
 
	end
