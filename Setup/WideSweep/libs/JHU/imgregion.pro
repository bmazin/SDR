;-------------------------------------------------------------
;+
; NAME:
;       IMGREGION
; PURPOSE:
;       Interactively extract a selected image region.
; CATEGORY:
; CALLING SEQUENCE:
;       out = imgregion(img)
; INPUTS:
;       img = input image to operate on.                   in
;         This image should be byte
;         scaled, ready for display.
; KEYWORD PARAMETERS:
;       Keywords:
;         MISSING=val  Value for points outside region (def=0).
;         WINDOW=win   Window number for image display (def=0).
;         /STATS  means display statistics for selected region.
;         X=x  Returned region polygon x indices.
;         Y=y  Returned region polygon y indices.
; OUTPUTS:
;       out = output image containing extracted region.    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1993 Jan 3.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function imgregion, in, window=win, missing=miss, stats=stats, $
	  x=x, y=y, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Interactively extract a selected image region.'
	  print,' out = imgregion(img)'
	  print,'   img = input image to operate on.                   in'
	  print,'     This image should be byte
	  print,'     scaled, ready for display.'
	  print,'   out = output image containing extracted region.    out'
	  print,' Keywords:'
	  print,'   MISSING=val  Value for points outside region (def=0).'
	  print,'   WINDOW=win   Window number for image display (def=0).'
	  print,'   /STATS  means display statistics for selected region.'
	  print,'   X=x  Returned region polygon x indices.'
	  print,'   Y=y  Returned region polygon y indices.'
	  return, -1
	endif
 
	;--------  Set defaults  ---------
	if n_elements(win) eq 0 then win = 0
	if n_elements(miss) eq 0 then miss = 0
 
	;-------  Display image  -------
	if n_elements(in) eq 0 then begin
	  print,' Error in imgregion: undefined image.'
 	  return, -1
	endif
	sz = size(in)
	nx = sz(1)
	ny = sz(2)
	window, win, xs=nx, ys=ny
	tv, in
 
	;------  Draw polygon  ---------
	drawpoly, x, y
	if n_elements(x) lt 3 then return, -1
 
	;-------  Extract region  ---------
	v = polyfillv(x, y, nx, ny)	; 1-d indices of region points.
	one2two, v, [nx,ny], ix, iy	; Convert to 2-d indices.
	ix1 = min(ix, max=ix2)		; Bounding box.
	iy1 = min(iy, max=iy2)
	dx = ix2 - ix1 + 1		; Bounding box size.
	dy = iy2 - iy1 + 1
	sz(1) = dx			; Modify size array.
	sz(2) = dy
	out = make_array(size=sz, value=miss)
	out(ix-ix1,iy-iy1) = in(ix,iy)
 
	if not keyword_set(stats) then return, out
 
	print,' '
	print,' Statistics for selected region'
	print,' '
	print,' Number of pixels = '+strtrim(n_elements(v),2)
	print,' Mean value = '+strtrim(mean(in(ix,iy)),2)
	print,' Standard Deviation = '+strtrim(sdev(in(ix,iy)),2)
	print,' '
	
	return, out
 
	end
