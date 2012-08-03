;-------------------------------------------------------------
;+
; NAME:
;       INBOX
; PURPOSE:
;       Test if given point inside given box.
; CATEGORY:
; CALLING SEQUENCE:
;       flag = inbox( x, y, x1, x2, y1, y2)
; INPUTS:
;       x, y = x and y of point to test.         in
;       x1, x2 = min and max x of test box.      in
;       y1, y2 = min and max y of test box.      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       flag = result: 0=not inside, 1= inside.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: x and y may be a scalar or array.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Nov 10
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function inbox, x, y, x1, x2, y1, y2, help=hlp
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' Test if given point inside given box.'
	  print,' flag = inbox( x, y, x1, x2, y1, y2)'
	  print,'   x, y = x and y of point to test.         in'
	  print,'   x1, x2 = min and max x of test box.      in'
	  print,'   y1, y2 = min and max y of test box.      in'
	  print,'   flag = result: 0=not inside, 1= inside.  out'
	  print,' Notes: x and y may be a scalar or array.'
	  return,''
	endif
 
	return, (x ge x1) and (x le x2) and (y ge y1) and (y le y2)
 
	end
