;-------------------------------------------------------------
;+
; NAME:
;       DATA_SEGMOD
; PURPOSE:
;       Segment data that has values modulo a constant (like angles).
; CATEGORY:
; CALLING SEQUENCE:
;       data_segmod, x, lo, hi
; INPUTS:
;       x = data to segment based on breakpoints.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         MAX=mx  Modulo constant (def=360).
;         COUNT=c Returned number of segments between breakpoints.
; OUTPUTS:
;       lo = array of segment start indices.       out
;       hi = array of segment end indices.         out
; COMMON BLOCKS:
; NOTES:
;       Note: data with values that wrap, like angles, can be
;       segmented into subsections having no breaks.  A break
;       a step between sample values that is more than 1/2 the
;       modulo constant.  The i'th segment would be:
;         xi = x(lo(i):hi(i)) (for i=0,c-1).
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Sep 05
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro data_segmod, x, lo, hi, max=mx, count=c, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Segment data that has values modulo a constant (like angles).'
	  print,' data_segmod, x, lo, hi'
	  print,'   x = data to segment based on breakpoints.  in'
	  print,'   lo = array of segment start indices.       out'
	  print,'   hi = array of segment end indices.         out'
	  print,' Keywords:'
	  print,'   MAX=mx  Modulo constant (def=360).'
	  print,'   COUNT=c Returned number of segments between breakpoints.'
	  print,' Note: data with values that wrap, like angles, can be'
	  print,' segmented into subsections having no breaks.  A break'
	  print,' a step between sample values that is more than 1/2 the'
	  print," modulo constant.  The i'th segment would be:"
	  print,'   xi = x(lo(i):hi(i)) (for i=0,c-1).'
	  return
	endif
 
	if n_elements(mx) eq 0 then mx=360.
	bmx = mx/2.
 
	n = n_elements(x)
 
	w = where((shift(x,1)-x) gt bmx, cnt)
 
	;-----  No breaks found: 1 segment  -------
	if cnt eq 0 then begin
	  lo = 0			; Segment start index.
	  hi = n-1			; Segment end index.
	  c = 1				; Number of segments.
	  return
	endif
 
	;-----  Found a break (or breaks)  -----------
	if w(0) ne 0 then w = [0,w]	; Make sure 0 is included.
	lo = w				; Segment start indices.
	w = ([w,n])(1:*)		; Add total length to end, drop 0.
	hi = w-1			; Segment end indices.
	c = n_elements(lo)		; Number of segments.
 
	end
