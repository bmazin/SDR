;-------------------------------------------------------------
;+
; NAME:
;       IMGPOLREC
; PURPOSE:
;       Map an angle/radius image to an X/Y image.
; CATEGORY:
; CALLING SEQUENCE:
;       xy = imgpolrec(ar, a1, a2, r1, r2, x1, x2, dx, y1, y2, dy)
; INPUTS:
;       ar = angle/radius image.                            in
;          Angle is in x direction, and radius is in y direction
;       a1, a2 = start and end angles in ar (degrees)       in
;       r1, r2 = start and end radius in ar.                in
;       x1, x2, dx = desired start x, end x, x step.        in
;       y1, y2, dy = desired start y, end y, y step.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         /LAST use last computed indices and mask.
;         /BILINEAR does bilinear interpolation,
;           else nearest neighbor is used.
;         /MASK masks values outside image to 0.
;         VAL_MASK=val mask value if not 0.
;         /MIN  Use data min for mask value.
;         /MAX  Use data max for mask value.
;         /A_EDGE means a1, a2 apply to pixel edges, not center.
;         /R_EDGE means r1, r2 apply to pixel edges, not center.
; OUTPUTS:
;       xy = returned X/Y image.                            out
; COMMON BLOCKS:
;       imgpolrec_com
; NOTES:
;       Notes: Angle is 0 along + X axis and increases CCW.
; MODIFICATION HISTORY:
;       R. Sterner.  12 May, 1986.
;       R. Sterner, 3 Sep, 1991 --- converted to IDL vers 2.
;       R. Sterner, 5 Sep, 1991 --- simplified and added bilinear interp.
;       R. Sterner, 1998 Apr 7 --- Added non-centered pixel keywords.
;       R. Sterner, 2005 Aug 16 --- Save last indices and mask.
;       R. Sterner, 2006 May 11 --- Added custom mask values.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function imgpolrec, ar, a1, a2, r1, r2, x1, x2, dx, y1, y2, dy, $
	  mask=mask, help=hlp, bilinear=bilin, $
	  a_edge=aedge, r_edge=redge, last=last, $
	  val_mask=mval, min=mmin, max=mmax
 
	common imgpolrec_com, ia0,ia1, ir0, ir1, cnt_msk, w_msk, $
	  int_typ, msk_flag, na0, nr0, msk_val, msk_typ
	;-------------------------------------------------------
	;  Common with last indices and mask.
	;  ia0 = NN angle index or first BILIN angle index.
	;  ia1 = Second BILIN index.
	;  ir0 = NN radial index or first BILIN radial index.
	;  ir1 = Second BILIN index.
	;  cnt_msk = # points to mask.
	;  w_msk = Indices of masked points.
	;  int_typ = Interpolation type: 0=NN, 1=BILIN.
	;  msk_flag = Mask? 0=no, 1=yes.
	;  na0, nr0 = Dimensions of last image.
	;  msk_val = Mask value.
	;  msk_typ = Mask type (0, msk_val, min, or max).
	;-------------------------------------------------------
 
	if ((not keyword_set(last)) and (n_params(0) lt 11)) or $
	    keyword_set(hlp) then begin
	  print,' Map an angle/radius image to an X/Y image.'
	  print,' xy = imgpolrec(ar, a1, a2, r1, r2, x1, x2, dx, y1, y2, dy)'
	  print,'   ar = angle/radius image.                            in'
	  print,'      Angle is in x direction, and radius is in y direction'
	  print,'   a1, a2 = start and end angles in ar (degrees)       in'
	  print,'   r1, r2 = start and end radius in ar.                in'
	  print,'   x1, x2, dx = desired start x, end x, x step.        in'
	  print,'   y1, y2, dy = desired start y, end y, y step.        in'
	  print,'   xy = returned X/Y image.                            out'
	  print,' Keywords:'
	  print,'   /LAST use last computed indices and mask.'
          print,'   /BILINEAR does bilinear interpolation,'
          print,'     else nearest neighbor is used.'
	  print,'   /MASK masks values outside image to 0.'
	  print,'   VAL_MASK=val mask value if not 0.'
	  print,'   /MIN  Use data min for mask value.'
	  print,'   /MAX  Use data max for mask value.'
	  print,'   /A_EDGE means a1, a2 apply to pixel edges, not center.'
	  print,'   /R_EDGE means r1, r2 apply to pixel edges, not center.'
          print,' Notes: Angle is 0 along + X axis and increases CCW.'
	  return, 0
	endif
 
	;--------  Get input image size and make sure its an image  ------
	s = size(ar)				; Error check.
	if s(0) ne 2 then begin
	  print,' Error in imgrecpol: First arg must be a 2-d array.'
	  return, -1
	endif
	na = s(1)				; Size of AR in a.
	nr = s(2)				; Size of AR in r.
 
	if not keyword_set(last) then begin
	  ;--------  Save image dimensions  ---------
	  na0 = na  & nr0 = nr
 
	  ;--------  Set up X and Y arrays  ---------
	  x = makex(x1, x2, dx)			; Generate X array.
	  nx = n_elements(x)
	  y = transpose(makex(y1, y2, dy))	; Generate Y array.
	  ny = n_elements(y)
	  x = rebin(x,nx,ny)			; Make both 2-d.
	  y = rebin(y,nx,ny)
 
	  ;-------  Compute angle and radius from X and Y  ------ 
	  r = sqrt(x^2 + y^2)			; From XY coordinates find R.
	  w = where(r eq 0., count)		; ATAN(0,0) won't work. Fix.
	  if count gt 0 then begin
	    x(w) = 1.0e-25
	    y(w) = 1.0e-25
	  endif
	  ;--- Longest step  -------
	  a = !radeg*atan(y, x)			; From XY coordinates find A.
	  if a1 GE 0 then begin
	    w=where(a lt 0.,count)		; Principal value 0 to 360
	    if count gt 0 then A(W)=A(W)+360.
	  endif
 
	  ;--------  Convert angle and radius to indices  --------
	  ;-----  Indices in Angle dimension  ---------
	  if keyword_set(aedge) then begin
	    ia = (a-a1)*na/(a2-a1)	; Non-centered pixels.
	    aoff = 0.0
	  endif else begin
	    ia = (a-a1)*(na-1)/(a2-a1)  	; Centered pixels.
	    aoff = 0.5
	  endelse
	  ;-----  Indices in Radius dimension  ---------
	  if keyword_set(redge) then begin
            ir = (r-r1)*nr/(r2-r1)	; Non-centered pixels.
	    roff = 0.0
          endif else begin
            ir = (r-r1)*(nr-1)/(r2-r1)	; Centered pixels.
	    roff = 0.5
	  endelse
 
	  ;---------  Interpolation indices  ------------
	  if not keyword_set(bilin) then begin
	    ;--------  Nearest Neighbor interpolation  ----------
	    int_typ = 0
	    ia0 = fix(ia+aoff)<(na-1)
	    ir0 = fix(ir+roff)<(nr-1)
	  endif else begin
	    ;--------  Bilinear interpolation  ------
	    int_typ = 1
	    ia0 = floor(ia)	; Indices of the 4 surrounding points.
	    ia1 = (ia0+1)<(na-1)
	    ir0 = floor(ir)
	    ir1 = (ir0+1)<(nr-1)
	  endelse
 
	  ;------ Indices to mask points outside input image to 0  ------
	  if keyword_set(mask) then begin
	    msk_flag = 1
	    w_msk = where((ir lt 0) or (ir ge (nr-2*roff)) or $
	            (ia lt 0) or (ia ge (na-2*aoff)), cnt_msk)
	    msk_val = 0				; Default mask value.
	    if n_elements(mval) ne 0 then msk_val=mval  ; Given mask value.
	    msk_typ = 0				; Use msk_val as mask value.
	    if keyword_set(mmin) then msk_typ=1	; Use data min as mask value.
	    if keyword_set(mmax) then msk_typ=2	; Use data max as mask value.
	  endif else msk_flag=0
 
	endif	; not last.
 
	;------------------------------------------------------
	;  Do interpolation
	;------------------------------------------------------
	;---------  Interpolate  ------------
	if int_typ eq 0 then begin
	  ;--------  Nearest Neighbor interpolation  ----------
	  xy = ar(ia0, ir0)  ; Pick off values.
	endif else begin
	  ;--------  Bilinear interpolation  ------
	  v00 = ar(ia0,ir0)	; Values of the 4 surrounding points.
	  v01 = ar(ia0,ir1)
	  v10 = ar(ia1,ir0)
	  v11 = ar(ia1,ir1)
	  fa = ia - ia0		; Fractional angle between points.
	  v0 = v00 + (v10-v00)*fa	; A interp at r0.
	  v1 = v01 + (v11-v01)*fa	; A interp at r1.
	  xy = v0+(v1-v0)*(ir-ir0)	; R interp at a.
	endelse
 
	;------------------------------------------------------
	;  Do masking
	;------------------------------------------------------
	if msk_flag then begin
	  if msk_typ eq 0 then val=msk_val
	  if msk_typ eq 1 then val=min(ar)
	  if msk_typ eq 2 then val=max(ar)
	  if cnt_msk gt 0 then xy(w_msk)=val
	endif
 
	;------  Return result  --------- 
	return, xy
 
	end
