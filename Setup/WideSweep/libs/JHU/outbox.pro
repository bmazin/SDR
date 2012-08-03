;-------------------------------------------------------------
;+
; NAME:
;       OUTBOX
; PURPOSE:
;       Test if given point outside given box.
; CATEGORY:
; CALLING SEQUENCE:
;       flag = outbox( x, y, x1, x2, y1, y2)
; INPUTS:
;       x, y = x and y of point to test.           in
;       x1, x2 = min and max x of test box.        in
;       y1, y2 = min and max y of test box.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         EXPAND=ex Pixels to expand box by before checking if
;           outside.  Makes easier to grab.  Could also give ex<0
;           to shrink box.
; OUTPUTS:
;       flag = result: 0=not outside, 1= outside.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: x and y may be a scalar or array.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Nov 10
;       R. Sterner, 2004 Mar 23 --- Added EXPAND=ex
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function outbox, x, y, x1, x2, y1, y2, expand=ex, help=hlp
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' Test if given point outside given box.'
	  print,' flag = outbox( x, y, x1, x2, y1, y2)'
	  print,'   x, y = x and y of point to test.           in'
	  print,'   x1, x2 = min and max x of test box.        in'
	  print,'   y1, y2 = min and max y of test box.        in'
	  print,'   flag = result: 0=not outside, 1= outside.  out'
	  print,' Keywords:'
	  print,'   EXPAND=ex Pixels to expand box by before checking if'
	  print,'     outside.  Makes easier to grab.  Could also give ex<0'
	  print,'     to shrink box.'
	  print,' Notes: x and y may be a scalar or array.'
	  return,''
	endif
 
	if n_elements(ex) eq 0 then ex=0
 
	return, (x lt (x1-ex)) or (x gt (x2+ex)) or  $
		(y lt (y1-ex)) or (y gt (y2+ex))
 
	end
