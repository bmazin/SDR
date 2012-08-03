;-------------------------------------------------------------
;+
; NAME:
;       PIXSPLIT
; PURPOSE:
;       Bilinearly split given pixels between surrounding pixels.
; CATEGORY:
; CALLING SEQUENCE:
;       pixsplit, img, ix, iy, val
; INPUTS:
;       ix,iy = x and y indices of new pixels.  in
;          Will be fractional in general.
;       val = Values of new pixels.             in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NN means use nearest neighbor method instead.
;           NN=0  Bilinear pixel split.
;           NN=1  Nearest neighbor (loses energy).
;           NN=2  Nearest neighbor summed over values.
;           NN=3  Nearest neighbor histogram method.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: ix,iy,val may all be arrays. Must be same length.
;         Useful for adding a curve to an array.  Curve
;         coordinates may be fractional.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jun 16
;       R. Sterner, 2004 Jun 29 --- Fixed loop limit.
;       R. Sterner, 2004 Jul 22 --- Added NN=2 option.
;       R. Sterner, 2004 Jul 23 --- Added NN=3 option.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro pixsplit, img, ix, iy, val, nn=nn, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Bilinearly split given pixels between surrounding pixels.'
	  print,' pixsplit, img, ix, iy, val'
	  print,'   img = Image array to add pixels to.     in/out'
	  print,'   ix,iy = x and y indices of new pixels.  in'
	  print,'      Will be fractional in general.'
	  print,'   val = Values of new pixels.             in'
	  print,' Keywords:'
	  print,'   /NN means use nearest neighbor method instead.'
	  print,'     NN=0  Bilinear pixel split.'
	  print,'     NN=1  Nearest neighbor (loses energy).'
	  print,'     NN=2  Nearest neighbor summed over values.'
	  print,'     NN=3  Nearest neighbor histogram method.'
	  print,' Note: ix,iy,val may all be arrays. Must be same length.'
	  print,'   Useful for adding a curve to an array.  Curve'
	  print,'   coordinates may be fractional.'
	  return
	endif
 
	if n_elements(nn) eq 0 then nn=0
 
	;--------------------------------------------------------
	;  NN=3: Histogram nearest neighbor sum.
	;--------------------------------------------------------
	if nn eq 3 then begin
	  x = round(ix)
	  y = round(iy)
	  img = tbin2d(img, x, y, val)
	  return
	endif
 
	;--------------------------------------------------------
	;  NN=2: Deal with summed nearest neighbor method
	;  Slower than NN option but does not lose energy.
	;--------------------------------------------------------
	if nn eq 2 then begin
	  z = img*0		; Need a blank copy of image array.
	  x = round(ix)
	  y = round(iy)
	  for i=0,n_elements(val)-1 do z(ix(i),iy(i))=z(ix(i),iy(i))+val(i)
	  img = img + z
	  return
	endif
 
	;--------------------------------------------------------
	;  NN=1: Deal with nearest neighbor method
	;  Fastest but loses energy.
	;--------------------------------------------------------
	if keyword_set(nn) then begin
	  z = img*0		; Need a blank copy of image array.
	  x = round(ix)
	  y = round(iy)
	  z(ix,iy) = val
	  img = img + z
	  return
	endif
 
	;--------------------------------------------------------
	;  NN=0: Find surrounding pixel coordinates
	;--------------------------------------------------------
	sz=size(img) & nx=sz(1) & ny=sz(2)
	x1 = floor(ix)<(nx-1)
	x2 = (x1 + 1)<(nx-1)
	y1 = floor(iy)<(ny-1)
	y2 = (y1 + 1)<(ny-1)
 
	;--------------------------------------------------------
	;  Weighting factors in x and y
	;--------------------------------------------------------
	wx1 = x2 - ix
	wx2 = 1 - wx1
	wy1 = y2 - iy
	wy2 = 1 - wy1
 
	;--------------------------------------------------------
	;  Loop over new values
	;--------------------------------------------------------
	for i=0L, n_elements(val)-1 do begin
	  x1i = x1(i)	; Grab i'th value of each item.
	  x2i = x2(i)
	  y1i = y1(i)
	  y2i = y2(i)
	  vi  = val(i)
	  wx1i = wx1(i)
	  wx2i = wx2(i)
	  wy1i = wy1(i)
	  wy2i = wy2(i)
	  img(x1i,y1i) = img(x1i,y1i) + vi*wx1i*wy1i  ; Add into 4 pixels.
	  img(x2i,y1i) = img(x2i,y1i) + vi*wx2i*wy1i
	  img(x1i,y2i) = img(x1i,y2i) + vi*wx1i*wy2i
	  img(x2i,y2i) = img(x2i,y2i) + vi*wx2i*wy2i
	endfor
 
	end
