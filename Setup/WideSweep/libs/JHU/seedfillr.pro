;-------------------------------------------------------------
;+
; NAME:
;       SEEDFILLR
; PURPOSE:
;       For an array fill a connected region of constant pixel value.
; CATEGORY:
; CALLING SEQUENCE:
;       seedfillr, img
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         SEED=s  Seed point as a 2 element array [ix,iy].
;         FILL=f  Fill pixel value.
; OUTPUTS:
;       img = Image to process.    in, out
; COMMON BLOCKS:
; NOTES:
;       Notes: Fill connected region having pixel values equal
;         to original seed pixel value.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 May 23 from seedfill.
;       R. Sterner, R. Sterner, 1995 Oct 18 --- Completely rewritten
;       using label_region.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;--------  seedfillr.pro = Scan line region seed fill routine  ---------
 
	pro seedfillr, pix, seed=seed,fill=fill,help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' For an array fill a connected region of constant pixel value.'
	  print,' seedfillr, img'
	  print,'   img = Image to process.    in, out'
	  print,' Keywords:'
	  print,'   SEED=s  Seed point as a 2 element array [ix,iy].'
	  print,'   FILL=f  Fill pixel value.'
	  print,' Notes: Fill connected region having pixel values equal'
	  print,'   to original seed pixel value.'
	  return
	endif
 
	v = pix(seed(0),seed(1))		; Desired value to modify.
	m = pix eq v				; Isolate regions with value v.
	b = label_region(m)			; Give each region a unique #.
	v = b(seed(0),seed(1))			; Find selected region #.
	w = where(b eq v)			; Find all pts of selected reg.
	pix(w) = fill				; Replace value.
 
	return
	end
