;-------------------------------------------------------------
;+
; NAME:
;       SPHGC
; PURPOSE:
;       Find intersections of two great circles on sphere.
; CATEGORY:
; CALLING SEQUENCE:
;       sphgc, an1,at1,an2,at2,bn1,bt1,bn2,bt2,pn1,pt1,pn2,pt2
; INPUTS:
;       an1, at1 = Longitude and Latitude of point A1 on GC A.  in
;       an2, at2 = Longitude and Latitude of point A2 on GC A.  in
;       bn1, bt1 = Longitude and Latitude of point B1 on GC B.  in
;       bn2, bt2 = Longitude and Latitude of point B2 on GC B.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         flag=f  Flag: 0=no poles found, 1=OK.
; OUTPUTS:
;       pn1, pt1 = Longitude and Latitude of pole 1.            out
;       pn2, pt2 = Longitude and Latitude of pole 2.            out
; COMMON BLOCKS:
; NOTES:
;       Notes: all coordinates in degrees.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Sep 20
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro sphgc, alng1,alat1,alng2,alat2,blng1,blat1,blng2,blat2,$
	  plng1,plat1,plng2,plat2,flag=flag,help=hlp
 
	if (n_params(0) lt 10) or keyword_set(hlp) then begin
	  print,' Find intersections of two great circles on sphere.'
	  print,' sphgc, an1,at1,an2,at2,bn1,bt1,bn2,bt2,pn1,pt1,pn2,pt2'
	  print,'   an1, at1 = Longitude and Latitude of point A1 on GC A.  in'
	  print,'   an2, at2 = Longitude and Latitude of point A2 on GC A.  in'
	  print,'   bn1, bt1 = Longitude and Latitude of point B1 on GC B.  in'
	  print,'   bn2, bt2 = Longitude and Latitude of point B2 on GC B.  in'
	  print,'   pn1, pt1 = Longitude and Latitude of pole 1.            out'
	  print,'   pn2, pt2 = Longitude and Latitude of pole 2.            out'
	  print,' Keywords:'
	  print,'   flag=f  Flag: 0=no poles found, 1=OK.'
	  print,' Notes: all coordinates in degrees.'
	  return
	endif
 
	;------  Constants  --------
	radeg = 180/!dpi		; Double radians to degrees.
	ninety = 90/radeg		; 90 degrees in radians.
 
	;------  Find a point 90 degrees from great circle A  -----------
	ll2rb, alng1,alat1,alng2,alat2,ra,ba		; Bearing of A2 from A1.
	rb2ll, alng1,alat1,ninety,(ba-90.),clnga,clata	; Pt 90 deg away.
 
	;------  Find a point 90 degrees from great circle B  -----------
	ll2rb, blng1,blat1,blng2,blat2,rb,bb		; Bearing of A2 from A1.
	rb2ll, blng1,blat1,ninety,(bb-90.),clngb,clatb	; Pt 90 deg away.
 
	;------  Find poles  ---------------
	sphic, /degrees,clnga,clata,90d0,clngb,clatb,90d0,$
	  plng1,plat1,plng2,plat2,f
	flag = f gt 0
 
	return
	end
