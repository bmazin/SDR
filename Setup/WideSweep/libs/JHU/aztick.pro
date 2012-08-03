;-------------------------------------------------------------
;+
; NAME:
;       AZTICK
; PURPOSE:
;       Tick mark formatting function for azimuth.
; CATEGORY:
; CALLING SEQUENCE:
;       s = aztick(ax, ind, val)
; INPUTS:
;       ax = axis number.                      in
;       ind = index of tick mark, 0 is first.  in
;       val = Tick value.                      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = Returned label string.             out
; COMMON BLOCKS:
; NOTES:
;       Note: for use in plot statements, not intended to be
;         called directly.  Example use:
;           plots,x,y,...,xtickform='aztick',...
;         Should work for any axis.  Can turn the formatting off
;         by substituting a null string for the function name.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Mar 07
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function aztick, ax, ind, val, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Tick mark formatting function for azimuth.'
	  print,' s = aztick(ax, ind, val)'
	  print,'   ax = axis number.                      in'
	  print,'   ind = index of tick mark, 0 is first.  in'
	  print,'   val = Tick value.                      in'
	  print,'   s = Returned label string.             out'
	  print,' Note: for use in plot statements, not intended to be'
	  print,'   called directly.  Example use:'
	  print,"     plots,x,y,...,xtickform='aztick',..."
	  print,'   Should work for any axis.  Can turn the formatting off'
	  print,'   by substituting a null string for the function name.'
	  return, ''
	endif
 
	v = val				; Copy to allow modification.
	if v eq fix(v) then v=fix(v)	; Make integer if ok.
	return, strtrim(pmod(v,360),2)	; Modified value.
 
	end
