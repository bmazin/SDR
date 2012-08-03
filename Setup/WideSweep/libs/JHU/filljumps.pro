;-------------------------------------------------------------
;+
; NAME:
;       FILLJUMPS
; PURPOSE:
;       Find indices needed to fill in value jumps in an array.
; CATEGORY:
; CALLING SEQUENCE:
;       filljumps, v, t, in
; INPUTS:
;       v = array to examine.                       in
;       t = max allowed value jump.                 in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       in = indices needed to keep max jumps < t.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: Use the IDL interpolate function to create
;         the new array or arrays needed.  For example:
;         filljump, y, t, in       ; Avoid large jumps in y.
;         y2 = interpolate(y,in)   ; New y array.
;         x2 = interpolate(x,in)   ; Corresponding x array.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Jul 18
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro filljumps, v, t, in, help=hhlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Find indices needed to fill in value jumps in an array.'
	  print,' filljumps, v, t, in'
	  print,'   v = array to examine.                       in'
	  print,'   t = max allowed value jump.                 in'
	  print,'   in = indices needed to keep max jumps < t.  out'
	  print,' Notes: Use the IDL interpolate function to create'
	  print,'   the new array or arrays needed.  For example:'
	  print,'   filljump, y, t, in       ; Avoid large jumps in y.'
	  print,'   y2 = interpolate(y,in)   ; New y array.'
	  print,'   x2 = interpolate(x,in)   ; Corresponding x array.'
	  return
	endif
 
	in = [0]			; Seed array.
 
	np = n_elements(v)		; Number of array values.
 
	for i=0L, np-2 do begin		; Loop through array.
	  a = v(i)			; Pull out two values.
	  b = v(i+1)
	  d = abs(b-a)			; Find difference.
	  if d lt t then begin		; Difference ok.
	    in = [in,i]			; Add index.
	  endif else begin
	    ni = 1+ceil(d/t)
	    fill = maken(i,i+1,ni)	; Needed in-between indices.
	    in = [in,fill(0:ni-2)]	; Clip off index of pt b.
	  endelse
	endfor
 
	in = [in,np-1]			; Include last point.
	in = in(1:*)			; Drop seed value.
 
	return
	end
