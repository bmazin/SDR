;-------------------------------------------------------------
;+
; NAME:
;       SPL_ANGINT
; PURPOSE:
;       Spline angular interpolation of a periodic function.
; CATEGORY:
; CALLING SEQUENCE:
;       r2 = spl_angint(r, a, a2)
; INPUTS:
;       r = Radii of spline anchor points.           in
;       a = Angles of spline anchor points.          in
;       a2 = Angles of desired interpolated points.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means angles are in degrees, else radians.
;         /CLOSED  means last point has already been repeated,
;           else repeat it here before interpolating.
; OUTPUTS:
;       r2 = Radii of desired interpolated points.   out
;         Make sure a2 is in a range appropriate to a.
; COMMON BLOCKS:
; NOTES:
;       Notes: If given curve has the first point repeated as
;       the last it is closed.  This routine must be told if the
;       curve is closed.  The given points are assumed to be not
;       too non-uniform along the curve.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 May 14
;       R. Sterner, 1998 May 18 --- Fixed angles.
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function spl_angint, r, a0, a2, degrees=deg, closed=closed, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Spline angular interpolation of a periodic function.'
	  print,' r2 = spl_angint(r, a, a2)'
	  print,'   r = Radii of spline anchor points.           in'
	  print,'   a = Angles of spline anchor points.          in'
	  print,'   a2 = Angles of desired interpolated points.  in'
	  print,'   r2 = Radii of desired interpolated points.   out'
	  print,'     Make sure a2 is in a range appropriate to a.'
	  print,' Keywords:'
	  print,'   /DEGREES means angles are in degrees, else radians.'
	  print,'   /CLOSED  means last point has already been repeated,'
	  print,'     else repeat it here before interpolating.'
	  print,' Notes: If given curve has the first point repeated as'
	  print,' the last it is closed.  This routine must be told if the'
	  print,' curve is closed.  The given points are assumed to be not'
	  print,' too non-uniform along the curve.'
	  return, ''
	endif
 
	;----------------------------------------------------
	;	Deg or Rad?
	;----------------------------------------------------
	if keyword_set(deg) then begin
	  crc = 360.
	  rad = 0
	endif else begin
	  crc = !pi*2
	  rad = 1
	endelse
 
	;----------------------------------------------------
        ;	Make sure angles are increasing.  Have to
        ;	allow for 0/2Pi (0/360) discontinuety
	;----------------------------------------------------
        a = a0
        if min(a(1:*)-a) lt 0 then a=fixang(a,rad=rad)
 
	;----------------------------------------------------
	;	Close curve if not and match slopes at first
	;	and last points.  Assumes points are
	;	not too unevenly space around curve.
	;----------------------------------------------------
	if not keyword_set(closed) then begin
          aa = [a,a(0)+crc]		; Close curve.
          rr = [r,r(0)]
	endif else begin
	  aa = a			; Was closed.  Just rename.
	  rr = r
	endelse
        last = n_elements(aa)-1		; Index of last point.
 
        s1 = (rr(1)-rr(0))/(aa(1)-aa(0))		  ; Slope at 1st pt.
        s9 = (rr(last)-rr(last-1))/(aa(last)-aa(last-1))  ; Slope at last pt.
        slope = .5*(s1+s9)		; Set slopes to mean.
 
	;----------------------------------------------------
	;	Make sure desired angles are in the same
	;	range as function angles.
	;----------------------------------------------------
	a3 = a2			; Working copy.
	w = where(a3 lt min(aa),c)
	if c gt 0 then a3(w)=a3(w)+crc
	w = where(a3 gt max(aa),c)
	if c gt 0 then a3(w)=a3(w)-crc	; a3 is now in valid range.
 
	;----------------------------------------------------
	;	Do spline interpolation
	;----------------------------------------------------
        s = spl_init(aa,rr,yp0=slope,ypn_1=slope)
        r2 = spl_interp(aa,rr,s,a3)
 
	return, r2
 
	end
