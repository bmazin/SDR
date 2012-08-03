;-------------------------------------------------------------
;+
; NAME:
;       IMG_ADD
; PURPOSE:
;       Add two 24-bit color images together.
; CATEGORY:
; CALLING SEQUENCE:
;       img3 = img_add(img1,img2)
; INPUTS:
;       img1 = First input image.   in
;       img2 = Second input image.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         WT1=wt1  Image 1 weighting (def=1).
;         WT2=wt2  Image 2 weighting (def=1).
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
;       img3 = Output image.        out
;         Same pixel interleave as img1.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Nov 12
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_add, img1, img2, wt1=wt1, wt2=wt2, error=err,help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Add two 24-bit color images together.'
	  print,' img3 = img_add(img1,img2)'
	  print,'   img1 = First input image.   in'
	  print,'   img2 = Second input image.  in'
	  print,'   img3 = Output image.        out'
	  print,'     Same pixel interleave as img1.'
	  print,' Keywords:'
	  print,'   WT1=wt1  Image 1 weighting (def=1).'
	  print,'   WT2=wt2  Image 2 weighting (def=1).'
	  print,'   ERROR=err Error flag: 0=ok.'
	  return,''
	endif
 
	;-------  Defaults  ---------------
	if n_elements(wt1) eq 0 then wt1=1.
	if n_elements(wt2) eq 0 then wt2=1.
 
	;------  Split input images  ---------------
	img_split, img1, r1, g1, b1, tr=tr1
	img_split, img2, r2, g2, b2, tr=tr2
 
	;-------  Added weighted components  -------
	r = (r1*wt1 + r2*wt2)>0<255
	g = (g1*wt1 + g2*wt2)>0<255
	b = (b1*wt1 + b2*wt2)>0<255
 
	;-------  Merge color channels back into a 24-bit image  -------
	return, img_merge(r,g,b,true=tr1)
 
	end
