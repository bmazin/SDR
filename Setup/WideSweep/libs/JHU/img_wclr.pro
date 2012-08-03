;-------------------------------------------------------------
;+
; NAME:
;       IMG_WCLR
; PURPOSE:
;       Find where a color is in a 24-bit image.
; CATEGORY:
; CALLING SEQUENCE:
;       w = img_wclr(img)
; INPUTS:
;       img = 24-bit image.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr Target color. 24-bit color value or
;           may also be a 3 element array: [R,G,B].
;         TOL=tol Tolerance, Euclidian distance in RGB space. Def=0.
;         COUNT=c Number of pixels found.
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 26
;       R. Sterner, 2004 May 16 --- Fixed to work for 24-color target color.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_wclr, img, color=clr0, tol=tol, $
 	   count=c, error=err,help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Find where a color is in a 24-bit image.'
	  print,' w = img_wclr(img)'
	  print,'   img = 24-bit image.  in'
	  print,' Keywords:'
	  print,'   COLOR=clr Target color. 24-bit color value or'
	  print,'     may also be a 3 element array: [R,G,B].'
	  print,'   TOL=tol Tolerance, Euclidian distance in RGB space. Def=0.'
	  print,'   COUNT=c Number of pixels found.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  return,''
	endif
 
	;-------  Check for valid input values  --------------
	c = 0
	if n_elements(tol) eq 0 then tol=0
 
	if n_elements(clr0) eq 0 then begin
	  print,' Error in img_wclr: Must give a target color:'
	  print,'   24-bit color value or a 3 element array: [r,g,b].'
	  err = 1
	  return,''
	endif
 
	if n_elements(clr0) eq 3 then begin
	  clr = clr0
	endif else begin
	  c2rgb, clr0, r, g, b
	  clr = [r,g,b]
	endelse
 
	mn = min(clr,max=mx)
	if (mn lt 0) or (mx gt 255) then begin
	  print,' Error in img_wclr: Target color value out of range (0-255).'
	  err = 1
	  return,''
	endif
 
	;------  Split input image  ---------------
	img_split, img, r, g, b, tr=tr
	r1=clr(0)+0. & g1=clr(1)+0. & b1=clr(2)+0.
 
	;----------------------------------------------------------
	;  Notes on an upgrade.
	;  Allow two modes: /HSV, else RGB mode.
	;  If RGB and TOL=scalar then use Euclidian distance as now.
	;    If TOL=[rtol,gtol,btol] then handle tolerances for
	;  each color: w=where((d2r le rtol^2) and (d2g le gtol^2) ...)
	;  If /HSV then must use TOL=[htol,stol,vtol], handle for
	;  each component like above.
	;----------------------------------------------------------
 
	;------  Compute squared distance from target color  ------
	d2 = (r-r1)^2 + (g-g1)^2 + (b-b1)^2
 
	;------  Find and replace pixles close to target color -----------
	w = where(d2 le float(tol)^2, c)
 
	;-------  Merge color channels back into a 24-bit image  -------
	return, w
 
	end
