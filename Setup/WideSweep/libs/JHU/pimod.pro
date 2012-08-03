;-------------------------------------------------------------
;+
; NAME:
;       PIMOD
; PURPOSE:
;       Force angles in radians to the range -Pi to +Pi.
; CATEGORY:
; CALLING SEQUENCE:
;       out = pimod(in)
; INPUTS:
;       in = Input value or array of angles.         in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES input angles are in degrees.  Output range
;            will then be -180 to +180.  Else input assumed to
;            be Radians and output range is -Pi to +Pi.
;         /DOUBLE use double precision, else single float.
; OUTPUTS:
;       out = returned angle(s) corrected to range.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Feb 26
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function pimod, in, degrees=deg, double=dbl, help=hlp
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Force angles in radians to the range -Pi to +Pi.'
	  print,' out = pimod(in)'
	  print,'   in = Input value or array of angles.         in'
	  print,'   out = returned angle(s) corrected to range.  out'
	  print,' Keywords:'
	  print,'   /DEGREES input angles are in degrees.  Output range'
	  print,'      will then be -180 to +180.  Else input assumed to'
	  print,'      be Radians and output range is -Pi to +Pi.'
	  print,'   /DOUBLE use double precision, else single float.'
	  return,''
	endif
 
	if keyword_set(dbl) then begin
	  if keyword_set(deg) then begin
	    a = 180D0
	    b = 360D0
	  endif else begin
	    a = !pi
	    b = 2*!pi
	  endelse
	endif else begin
	  if keyword_set(deg) then begin
	    a = 180.
	    b = 360.
	  endif else begin
	    a = !dpi
	    b = 2*!dpi
	  endelse
	endelse
 
	return, pmod((in + a),b) - a
 
	end
