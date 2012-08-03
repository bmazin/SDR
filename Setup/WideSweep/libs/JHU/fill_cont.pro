;-------------------------------------------------------------
;+
; NAME:
;       FILL_CONT
; PURPOSE:
;       Returns a byte array with filled contours.
; CATEGORY:
; CALLING SEQUENCE:
;       img = fill_cont(z)
; INPUTS:
;       z = 2-d array to contour.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         LEVELS=lv  Array of contour levels.  Default
;           is 8 contours from array min to max.  First value
;           in LEVELS should be the minimum of the first contour
;           range, and the last should be the maximum of the
;           last contour range.  For example, for 3 contour
;           ranges from 23 to 130 LEVEL should be:
;           23.0000      58.6667      94.3333      130.00
;         N_LEVELS=n Number of evenly spaced levels to contour
;           from array min to max.  Only if LEVELS not given.
;         COLORS=clr Array of contour colors.  Default
;           is enough colors to handle LEVELS
;           spaced from 0 to !d.table_size-1.  Number of colors
;           is 1 less than the number in LEVELS.
; OUTPUTS:
;       img = output image.          out
;         Same size as input array.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 22 Jan, 1993
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function fill_cont, z, levels=lv, colors=clr, n_levels=n_lv, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Returns a byte array with filled contours.'
	  print,' img = fill_cont(z)'
	  print,'   z = 2-d array to contour.    in'
	  print,'   img = output image.          out'
	  print,'     Same size as input array.'
	  print,' Keywords:'
	  print,'   LEVELS=lv  Array of contour levels.  Default'
	  print,'     is 8 contours from array min to max.  First value'
	  print,'     in LEVELS should be the minimum of the first contour'
	  print,'     range, and the last should be the maximum of the'
	  print,'     last contour range.  For example, for 3 contour'
	  print,'     ranges from 23 to 130 LEVEL should be:'
	  print,'     23.0000      58.6667      94.3333      130.00'
	  print,'   N_LEVELS=n Number of evenly spaced levels to contour'
	  print,'     from array min to max.  Only if LEVELS not given.' 
	  print,'   COLORS=clr Array of contour colors.  Default'
	  print,'     is enough colors to handle LEVELS'
	  print,'     spaced from 0 to !d.ncolors-1.  Number of colors'
	  print,'     is 1 less than the number in LEVELS.'
	  return, -1
	endif
 
	;--------  Set defaults  ---------
	mn = min(z,max=mx)			; Find data min and max.
	d = mx-mn				; Data range.
	if n_elements(n_lv) eq 0 then n_lv=8	; Default number of levels.
	n_lv = n_lv>1				; Must be at least 1.
	;---  If LEVELS array not given make it.  -----
	if n_elements(lv) eq 0 then lv = findgen(n_lv+1)*d/n_lv+mn
	nlv = n_elements(lv)			; How many levels?
	;---  If COLORS array not given make it.  -----
	if n_elements(clr) eq 0 then $
	  clr = (findgen(nlv)*(!d.table_size-1)/(nlv-1))(1:*)
	lstc = n_elements(clr)-1		; Last color index.
 
	;-------  Set up output array  ----------
	out = byte(z*0)
 
	;---  Loop through levels filling contours.  -------
	for i = 0, nlv-2 do begin
	  w = where((z ge lv(i)) and (z le lv(i+1)), cnt)
	  if cnt gt 0 then out(w) = clr(i<lstc)
	endfor
 
	return, out
	end
