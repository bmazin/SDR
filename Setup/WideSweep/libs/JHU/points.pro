;-------------------------------------------------------------
;+
; NAME:
;       POINTS
; PURPOSE:
;       Convert from size in points to IDL charsize or pixels.
; CATEGORY:
; CALLING SEQUENCE:
;       sz = points(n)
; INPUTS:
;       n = Size in points (1/72 inch).            in
; KEYWORD PARAMETERS:
;       Keywords:
;         /PIXELS means convert from size in points to size
;           in pixels.  Returned value sz is then a 2 element
;           array: [nxpix, nypix].
;         /NORMALIZED means convert from size in points to size
;           in normalized coord.  Returned value sz is then a
;           2 element array: [dx, dy].
; OUTPUTS:
;       sz = Value for IDL charsize.               out
; COMMON BLOCKS:
; NOTES:
;       Notes: Should be very close for PS Helvetica.
;         Not well tested with other fonts.  Assumes
;         character font size is the distance in points
;         from the bottom of the descenders to the top
;         of capital letters in units of 1/72 ".
; MODIFICATION HISTORY:
;       R. Sterner, 27 Jul, 1993
;       R. Sterner, 1998 Feb 5 --- Added /NORMALIZED keyword.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function points, x, pixels=pixels, normalized=norm, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Convert from size in points to IDL charsize or pixels.'
	  print,' sz = points(n)'
	  print,'   n = Size in points (1/72 inch).            in'
	  print,'   sz = Value for IDL charsize.               out'
	  print,' Keywords:'
	  print,'   /PIXELS means convert from size in points to size'
	  print,'     in pixels.  Returned value sz is then a 2 element'
	  print,'     array: [nxpix, nypix].'
	  print,'   /NORMALIZED means convert from size in points to size'
	  print,'     in normalized coord.  Returned value sz is then a'
	  print,'     2 element array: [dx, dy].'
	  print,' Notes: Should be very close for PS Helvetica.'
	  print,'   Not well tested with other fonts.  Assumes'
	  print,'   character font size is the distance in points'
	  print,'   from the bottom of the descenders to the top'
	  print,'   of capital letters in units of 1/72 ".'
	  return,-1
	endif
 
	if keyword_set(pixels) then begin
	  return, round(x/72.*2.54*[!d.x_px_cm,!d.y_px_cm])
	endif
 
	if keyword_set(norm) then begin
          return, x/72.*2.54*[!d.x_px_cm,!d.y_px_cm]/[!d.x_size,!d.y_size]
	endif
 
	fx = 0.906*x - 0.59		; Fudged x.
	return, fx/(!d.y_ch_size/!d.y_px_cm*72./2.54)
 
	end
