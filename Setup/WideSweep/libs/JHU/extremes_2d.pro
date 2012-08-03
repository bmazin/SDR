;-------------------------------------------------------------
;+
; NAME:
;       EXTREMES_2D
; PURPOSE:
;       Find local extremes in a 2-d array.
; CATEGORY:
; CALLING SEQUENCE:
;       ind = extremes_2d(z, flag)
; INPUTS:
;       z = 2-d array to search.                          in
;       flag = min/max flag: -1 for min, 1 for max.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         /EDGES   Means examine image edges (default ignores edges).
;         VALUE=v  Returned values at each extreme.
; OUTPUTS:
;       ind = 1-d indices of local extremes (-1 if none). out
; COMMON BLOCKS:
; NOTES:
;       Notes: Mimima are sorted in ascending order of value.
;              Maxima are sorted in descending order of value.
;         2-d indices may be found from: one2two,ind,z,ix,iy.
;         Noisy images should be smoothed first.
; MODIFICATION HISTORY:
;       R. Sterner, 23 Dec, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function extremes_2d, z, flag, value=v, edges=edges, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find local extremes in a 2-d array.'
	  print,' ind = extremes_2d(z, flag)'
	  print,'   z = 2-d array to search.                          in'
	  print,'   flag = min/max flag: -1 for min, 1 for max.       in'
	  print,'   ind = 1-d indices of local extremes (-1 if none). out'
	  print,' Keywords:'
	  print,'   /EDGES   Means examine image edges (default ignores edges).'
	  print,'   VALUE=v  Returned values at each extreme.'
	  print,' Notes: Mimima are sorted in ascending order of value.'
	  print,'        Maxima are sorted in descending order of value.'
	  print,'   2-d indices may be found from: one2two,ind,z,ix,iy.'
	  print,'   Noisy images should be smoothed first.'
	  return,''
	endif
 
	sz = size(z)			; Image size.
	nx = sz(1)
	ny = sz(2)
	c = bytarr(nx,ny)		; Accumulator. 
	dx = [1,1,0,-1,-1,-1,0,1]	; Shift tables.
	dy = [0,1,1,1,0,-1,-1,-1]
 
	for i = 0, 7 do begin		; Compare neighboring pixels.
	  s = shift(z,dx(i),dy(i))
	  if flag gt 0 then begin	; Max.
	    c = c + (z gt s)
	  endif else begin		; Min.
	    c = c + (z lt s)
	  endelse
	endfor
 
	if not keyword_set(edges) then imgfrm, c, 0	; Drop edges (invalid).
 
	w = where(c eq 8,cnt)		; Extremes.
	if cnt le 0 then return,-1
 
	v = z(w)			; Find values at extremes.
 
	s = sort(v)			; Find sort order.
	if flag gt 0 then s = reverse(s)
 
	v = v(s)			; Sort
	w = w(s)
 
	return, w
 
	end
