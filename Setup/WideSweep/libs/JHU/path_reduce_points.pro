;-------------------------------------------------------------
;+
; NAME:
;       PATH_REDUCE_POINTS
; PURPOSE:
;       Reduce number of points in a path.
; CATEGORY:
; CALLING SEQUENCE:
;       path_reduce_points, x1,y1, x2, y2
; INPUTS:
;       x1,y1 = X and Y coordinate arrays of     in
;               points along path.
; KEYWORD PARAMETERS:
;       Keywords:
;         DIST=dmx Max allowed distance off original path.
;           Def=1.
;         INDEX=ind Return index array of input points used
;           in output array.
; OUTPUTS:
;       x2,y2 = X and Y coordinate arrays of     out
;               points along reduced path.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Aug 20
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro path_reduce_points, x1,y1, x2, y2, dist=dmx, index=in2, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Reduce number of points in a path.'
	  print,' path_reduce_points, x1,y1, x2, y2'
	  print,'   x1,y1 = X and Y coordinate arrays of     in'
	  print,'           points along path.'
	  print,'   x2,y2 = X and Y coordinate arrays of     out'
	  print,'           points along reduced path.'
	  print,' Keywords:'
	  print,'   DIST=dmx Max allowed distance off original path.'
	  print,'     Def=1.'
	  print,'   INDEX=ind Return index array of input points used'
	  print,'     in output array.'
	  return
	endif
 
	;-----------------------------------------------------------------
	;  Method
	;
	;  Start with first point, connect to points farther along
	;  path until an in-between point is off the segment more than
	;  a specified distance.  When that happens add previous
	;  segment endpoint to output list and repeat using it as new
	;  segment starting point.  Points that are kept are anchor points.
	;
	;-----------------------------------------------------------------
 
	if n_elements(dmx) eq 0 then dmx=1.
	dmx2 = dmx*dmx				; (Max_dist)^2.
	n = n_elements(x1)
	in1 = lindgen(n)			; Input points indices.
	if n lt 3 then begin			; Only 2 pts, return both.
	  x2 = x1
	  y2 = y1
	  return
	endif
 
	;--- Start output  ---
	x2 = x1[[0]]				; Keep first point = 1st anchor.
	y2 = y1[[0]]
	i0 = 0					; Index of last output point.
	in2 = [in1[i0]]				; Output indices.
 
	;---  Loop over input points  ---
	for i=2, n-1 do begin			; Current test point = i.
	  u = unit([x1[i]-x1[i0],y1[i]-y1[i0]])	; Unit vector from last anchor.
	  ;---  Check distances  ---
	  for j=i0+1, i-1 do begin		; Check pts from anchor to curr.
	    v = [x1[j]-x1[i0],y1[j]-y1[i0]]	; Vector from anchor to test pt.
	    v_par = total(v*u)*u		; Comp of V parallel to U. 
	    v_perp = v - v_par			; Comp of V perp to U.
	    vlen2 = total(v_perp*v_perp)	; Length of perp comp.
	    if vlen2 gt dmx2 then begin		; i is 1 too big.
	      i0 = i-1				; Next anchor point.
	      x2 = [x2,x1[i0]]			; Add to output array.
	      y2 = [y2,y1[i0]]
	      in2 = [in2,in1[i0]]		; Add to output indices.
	      break				; Exit dist check loop.
	    endif ; vlen
	  endfor ; j
	endfor ; i
 
	x2 = [x2,x1[n-1]]			; Keep last point.
	y2 = [y2,y1[n-1]]
	in2 = [in2,in1[n-1]]
 
	end
