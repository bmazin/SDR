;-------------------------------------------------------------
;+
; NAME:
;       EARTHRAD
; PURPOSE:
;       Return earth radius in specified units.
; CATEGORY:
; CALLING SEQUENCE:
;       r = earthrad(units)
; INPUTS:
;       units = Units for earth radius (def='radians').   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       r = returned earth radius in requested units.     out
; COMMON BLOCKS:
; NOTES:
;       Notes: Available units (use 2 letters min):
;         'radians' Radians (default).
;         'degrees' Degrees.
;         'nmiles'  Nautical miles.
;         'miles'   Statute miles.
;         'kms'     Kilometers.
;         'meters'  Meters.
;         'yards'   Yards.
;         'feet'    Feet.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Sep 03
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function earthrad, units, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return earth radius in specified units.'
	  print,' r = earthrad(units)'
	  print,"   units = Units for earth radius (def='radians').   in"
	  print,'   r = returned earth radius in requested units.     out'
          print,' Notes: Available units (use 2 letters min):'
          print,"   'radians' Radians (default)."
          print,"   'degrees' Degrees."
          print,"   'nmiles'  Nautical miles."
          print,"   'miles'   Statute miles."
	  print,"   'kms'     Kilometers."
	  print,"   'meters'  Meters."
          print,"   'yards'   Yards."
          print,"   'feet'    Feet."
	  return,''
	endif
 
        ;---------  Deal with units  ---------------
        if n_elements(units) eq 0 then units='rad'
        un = strlowcase(strmid(units,0,2))
        case un of      ; Earth's radius in requested units.
'ra':   cf = 1.0              ; Radians/radian.
'de':   cf = 0.0174532925     ; Degrees/radian.
'nm':   cf = 2.90682e-04      ; Nautical mile/radian.
'mi':   cf = 2.52595e-04      ; Miles/radian.
'km':   cf = 1.56956e-04      ; Km/radian.
'me':   cf = 1.56956e-07      ; m/radian.
'fe':   cf = 4.78401e-08      ; Feet/radian.
'ya':   cf = 1.43520e-07      ; Yards/radian.
else:   begin
          print,' Error in earthrad: Unknown units: '+units
          print,'   Defaulting to radians.'
          cf = 1.0              ; Radians/radian.
        end
        endcase
 
	return, 1/cf
	end
