;-------------------------------------------------------------
;+
; NAME:
;       SEEDFILL
; PURPOSE:
;       For an array fill a connected region bounded by given values.
; CATEGORY:
; CALLING SEQUENCE:
;       seedfill, img
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         SEED=s  Seed point as a 2 element array [ix,iy].
;         FILL=f  Fill pixel value.
;         BOUND=b Region boundary pixel value.
;           May be an array of allowed boundary values.
;         ERROR=err Error flag.  0=ok, else error.
; OUTPUTS:
;       img = Image to process.    in, out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Mar 16
;       R. Sterner, 1994 May 23 --- Converted to multiple boundary values.
;       R. Sterner, 1995 May 17 --- Added keyboard abort.
;       R. Sterner, 1995 Oct 18 --- Completely rewrote to vastly simplify
;       and speed up.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;--------  seedfill.pro = Scan line seed fill routine  ---------
 
	pro seedfill, pix, seed=seed,fill=fill,bound=b0,$
	  error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' For an array fill a connected region bounded by given values.'
	  print,' seedfill, img'
	  print,'   img = Image to process.    in, out'
	  print,' Keywords:'
	  print,'   SEED=s  Seed point as a 2 element array [ix,iy].'
	  print,'   FILL=f  Fill pixel value.'
	  print,'   BOUND=b Region boundary pixel value.'
	  print,'     May be an array of allowed boundary values.'
	  print,'   ERROR=err Error flag.  0=ok, else error.'
	  return
	endif
 
	sz = size(pix)				; Input image size.
	m = bytarr(sz(1),sz(2))+1B		; Initial mask array.
	n = n_elements(b0)			; # boundary values.
	for i=0,n-1 do m=m and (pix ne b0(i))	; Isolate regions.
	b = label_region(m)			; Give each region a unique #.
	v = b(seed(0),seed(1))			; Find selected region #.
	w = where(b eq v)			; Find all pts of selected reg.
	pix(w) = fill				; Replace value.
	err = 0
 
	return
	end
