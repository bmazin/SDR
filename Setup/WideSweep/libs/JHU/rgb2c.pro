;-------------------------------------------------------------
;+
; NAME:
;       RGB2C
; PURPOSE:
;       Convert R,G,B (or H,S,V) values to 24-bit color.
; CATEGORY:
; CALLING SEQUENCE:
;       c = rgb2c(r,g,b)
; INPUTS:
;       r,g,b = Red, Green, Blue color components.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /HSV  Input h,s,v instead of r,g,b.
; OUTPUTS:
;       c = Returned 24-bit color value(s).         out
; COMMON BLOCKS:
; NOTES:
;       Note: r,g,b values are from 0 to 255.
;             h,s,v values are: h=0 to 360, s=0 to 1, v=0 to 1.
;       Inputs may be arrays.  If arrays are given then the
;       number of elements must match.  If arrays and scalars
;       are mixed then scalars will be converted to arrays with
;       the correct number of elements.
;       
;       Inverse of c2rgb and c2hsv.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Oct 05
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function rgb2c, a10, a20, a30, hsv=hsv, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Convert R,G,B (or H,S,V) values to 24-bit color.'
	  print,' c = rgb2c(r,g,b)'
	  print,'   r,g,b = Red, Green, Blue color components.  in'
	  print,'   c = Returned 24-bit color value(s).         out'
	  print,' Keywords:'
	  print,'   /HSV  Input h,s,v instead of r,g,b.'
	  print,' Note: r,g,b values are from 0 to 255.'
	  print,'       h,s,v values are: h=0 to 360, s=0 to 1, v=0 to 1.'
	  print,' Inputs may be arrays.  If arrays are given then the'
	  print,' number of elements must match.  If arrays and scalars'
	  print,' are mixed then scalars will be converted to arrays with'
	  print,' the correct number of elements.'
	  print,' '
	  print,' Inverse of c2rgb and c2hsv.'
	  return,''
	endif
 
	;------------------------------------------------------
	;  Preprocess to equalize number of elements
	;
	;  Must compare each pair.
	;  When converting scalar treat as a 1 element array
	;  and use element 0.  This makes it work also when the
	;  scalar is a 12 element array (else when adding two
	;  arrays will use smallest number of elements).
	;------------------------------------------------------
	a1 = a10			; Make copies.
	a2 = a20
	a3 = a30
	n1 = n_elements(a1)		; Number of elements of each.
	n2 = n_elements(a2)
	n3 = n_elements(a3)
 
	if n1 ne n2 then begin		; First two differ.
	  flag = 0			; Change flag.
	  if n1 eq 1 then begin		; First is a scalar.
	    a1 = a2*0 + a1[0]		; Convert scalar to array.
	    flag = 1			; Set change flag.
	  endif
	  if n2 eq 1 then begin		; Second is a scalar.
	    a2 = a1*0 + a2[0]		; Convert scalar to array.
	    flag = 1			; Set change flag.
	  endif
	  if flag eq 0 then begin
	    print,' Error in rgb2c: Arrays must be the same size.'
	    return, -1
	  endif
	endif
 
	if n2 ne n3 then begin		; Last two differ.
	  flag = 0			; Change flag.
	  if n2 eq 1 then begin		; Second is a scalar.
	    a2 = a3*0 + a2[0]		; Convert scalar to array.
	    flag = 1			; Set change flag.
	  endif
	  if n3 eq 1 then begin		; Third is a scalar.
	    a3 = a2*0 + a3[0]		; Convert scalar to array.
	    flag = 1			; Set change flag.
	  endif
	  if flag eq 0 then begin
	    print,' Error in rgb2c: Arrays must be the same size.'
	    return, -1
	  endif
	endif
 
	if n1 ne n3 then begin		; First and last differ.
	  flag = 0			; Change flag.
	  if n1 eq 1 then begin		; Second is a scalar.
	    a1 = a3*0 + a1[0]		; Convert scalar to array.
	    flag = 1			; Set change flag.
	  endif
	  if n3 eq 1 then begin		; Third is a scalar.
	    a3 = a1*0 + a3[0]		; Convert scalar to array.
	    flag = 1			; Set change flag.
	  endif
	  if flag eq 0 then begin
	    print,' Error in rgb2c: Arrays must be the same size.'
	    return, -1
	  endif
	endif
 
	;------------------------------------------------------
	;  Convert to 24-bit color
	;------------------------------------------------------
	if keyword_set(hsv) then begin
	  color_convert,a1,a2,a3,/hsv_rgb,r,g,b	; Convert HSV to RGB.
	endif else begin
	  r = a1				; Values are RGB.
	  g = a2
	  b = a3
	endelse
 
	return, r + 256L*(g + 256L*b)		; RGB to 24-bit color.
 
	end
