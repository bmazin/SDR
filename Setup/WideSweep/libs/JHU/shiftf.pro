;-------------------------------------------------------------
;+
; NAME:
;       SHIFTF
; PURPOSE:
;       Shift an array by a fractional number of indices.
; CATEGORY:
; CALLING SEQUENCE:
;       b = shiftf(a,dx,dy)
; INPUTS:
;       a = input array (1-d or 2-d).    in
;       dx = shift data in X.            in
;       dy = shift data in Y.            in
;         dy only needed for 2-d data.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes:  A positive shift shifts data in + direction.
;         Like shift except generalized.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Jul 2
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function shiftf, a, dx, dy, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Shift an array by a fractional number of indices.'
	  print,' b = shiftf(a,dx,dy)'
	  print,'   a = input array (1-d or 2-d).    in'
	  print,'   dx = shift data in X.            in'
	  print,'   dy = shift data in Y.            in'
	  print,'     dy only needed for 2-d data.'
	  print,' Notes:  A positive shift shifts data in + direction.'
	  print,'   Like shift except generalized.'
	  return,''
	endif
 
	sz = size(a)
	n = sz(0)				; Number of dimensions.
	nx = sz(1)				; x dimension.
	ny = sz(2)				; y dimension.
	if n_elements(dx) eq 0 then dx=0	; Default x shift.
	if n_elements(dy) eq 0 then dy=0	; Default y shift.
 
	if n eq 1 then begin
	  if dx eq 0 then return, a			; No shift.
	  if dx eq long(dx) then return, shift(a,dx)	; Int shift.
	  xx = makex(0,nx-1,1)				; Original indices.
	  xx = xx - dx					; Shifted indices.
	  w = where(xx lt 0, c)				; Underflow.
	  if c gt 0 then xx(w) = xx(w) + nx		; Correct any.
	  w = where(xx gt nx, c)			; Overflow.
	  if c gt 0 then xx(w) = xx(w) - nx		; Correct any.
	  return, interpolate([a,a(0)],xx)		; Add a(0) to end.
	endif
 
	if n eq 2 then begin
	  if (dx eq 0) and (dy eq 0) then return, a	; No shift.
	  if ((dx eq long(dx)) and (dx eq long(dy))) then $
	    return, shift(a,dx,dy)			; Int shift.
	  makexy,0,nx-1,1,0,ny-1,1,xx,yy		; Original indices.
	  xx = xx - dx					; Shifted indices.
	  yy = yy - dy
	  w = where(xx lt 0, c)                         ; X Underflow.
          if c gt 0 then xx(w) = xx(w) + nx             ; Correct any.
          w = where(xx gt nx, c)                        ; X Overflow.
          if c gt 0 then xx(w) = xx(w) - nx             ; Correct any.
	  w = where(yy lt 0, c)                         ; Y Underflow.
          if c gt 0 then yy(w) = yy(w) + ny             ; Correct any.
          w = where(yy gt ny, c)                        ; Y Overflow.
          if c gt 0 then yy(w) = yy(w) - ny             ; Correct any.
	  return, interpolate([[a,a(0,*)],[a(*,0),a(0,0)]],xx,yy)
	endif
 
	end
