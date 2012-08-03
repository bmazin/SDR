;-------------------------------------------------------------
;+
; NAME:
;       AXVAL
; PURPOSE:
;       Find nice axis values.
; CATEGORY:
; CALLING SEQUENCE:
;       v = axval(x1,x2,n)
; INPUTS:
;       x1 = Range minimum.                           in
;       x2 = Range maximum.                           in
;       n = Suggested number of divisions (def=5).    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       v = array of labeled tick positions.          out
; COMMON BLOCKS:
; NOTES:
;       Notes: Useful when exact axis and number of ticks
;         are both specified.  For this case IDL forces
;         labeled ticks to start and end at the axis ends,
;         which in general gives poor tick spacing.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Feb 8
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function axval, x1, x2, n, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find nice axis values.'
	  print,' v = axval(x1,x2,n)'
	  print,'   x1 = Range minimum.                           in'
	  print,'   x2 = Range maximum.                           in'
	  print,'   n = Suggested number of divisions (def=5).    in'
	  print,'   v = array of labeled tick positions.          out'
	  print,' Notes: Useful when exact axis and number of ticks'
	  print,'   are both specified.  For this case IDL forces'
	  print,'   labeled ticks to start and end at the axis ends,'
	  print,'   which in general gives poor tick spacing.'
	  return,''
	endif
 
	if n_elements(n) eq 0 then n = 5
	dx = nicenumber((double(x2)-double(x1))/double(n))
	v = nearest(dx,double(x1),t,xlo)
	v = nearest(dx,double(x2),xhi,t)
 
	return, makex(xlo,xhi,dx)
	end
