;-------------------------------------------------------------
;+
; NAME:
;       POLYSTAT
; PURPOSE:
;       Compute polygon statistics (# vertices, area, perimeter).
; CATEGORY:
; CALLING SEQUENCE:
;       polystat, x, y, s
; INPUTS:
;       x,y = polygon vertices.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /CURVE means x,y are a curve, return
;           arc_length instead of perimeter (area=0).
;         /SIGNED returned signed area (no abs(a)).
; OUTPUTS:
;       s = statistics.           out
;         s = [n_vertices, area, perimeter].
; COMMON BLOCKS:
; NOTES:
;       Notes: See also drawpoly.
; MODIFICATION HISTORY:
;       R. Sterner, 30 Oct, 1990
;       R. Sterner, 2006 Mar 15 --- Added /SIGNED.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro polystat, x, y, stats, curve=curve, signed=signed, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Compute polygon statistics (# vertices, area, perimeter).'
	  print,' polystat, x, y, s'
	  print,'   x,y = polygon vertices.   in'
	  print,'   s = statistics.           out'
	  print,'     s = [n_vertices, area, perimeter].'
	  print,' Keywords:'
	  print,'   /CURVE means x,y are a curve, return'
	  print,'     arc_length instead of perimeter (area=0).'
	  print,'   /SIGNED returned signed area (no abs(a)).'
	  print,' Notes: See also drawpoly.'
	  return
	endif
 
	n = n_elements(x)
	if n ne n_elements(y) then begin
	  print,' Error in polystat: vertex arrays must have same size.'
	  return
	endif
	if n lt 2 then begin
	  print,' Error in polystat: polygon has only 1 point.'
	  return
	endif
 
	a = 0.
	p = 0.
 
	if keyword_set(curve) then begin
	  for i1 = 0L, n-2 do begin
	    i2 = i1 + 1
	    p = p + sqrt((x(i2)-x(i1))^2 + (y(i2)-y(i1))^2)
	  endfor
	  stats = [n,a,p]
	  return
	endif
 
	for i1 = 0L, n-1 do begin
	  i2 = (i1 + 1) mod n
	  a = a + (x(i2) - x(i1))*(y(i2) + y(i1))/2.
	  p = p + sqrt((x(i2)-x(i1))^2 + (y(i2)-y(i1))^2)
	endfor
 
	if not keyword_set(signed) then a=abs(a)
 
	stats = [n,a,p]
	return
 
	end
