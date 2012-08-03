;-------------------------------------------------------------
;+
; NAME:
;       SPH_DEMO
; PURPOSE:
;       Demonstrate some of the spherical plot (sph*) routines.
; CATEGORY:
; CALLING SEQUENCE:
;       sph_demo
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /HARD means use colors appropriate to hardcopy.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro sph_demo, hard=hard, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Demonstrate some of the spherical plot (sph*) routines.'
	  print,' sph_demo
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   /HARD means use colors appropriate to hardcopy.'
	  return
	endif
 
	c1 = 60
	c2 = 255
	c3 = 140
 
	if keyword_set(hard) then begin
	  c1 = 0
	  c2 = 0
	  c3 = 0
	endif
 
	set_isoxy, -5, 5, -5, 5
	erase
	sphinit, lat=40, long=40, pa=30
	loadct, 4
 
	for l = 0, 90, 10 do sphrad,0,l,1,3, color=c1
	for l = 0, 90, 10 do sphrad,l,0,1,3, color=c1
	for l = 0, 90, 10 do sphrad,90,l,1,3, color=c1
 
	sphlng,0,3,0,90, color=c1
	sphlng,0,3,0,90, color=c1
	sphlng,90,3,0,90, color=c1
	sphlat,0,3,0,90, color=c1
 
	sphlng,90,1,0,90, color=c2
	sphlat,0,1,0,90, color=c2
	sphlng,0,1,0,90, color=c2
 
	for l=0, 90,10 do sphlat,l,3,90,360, color=c1
	for l=0, -90,-10 do sphlat,l,3, color=c1
	for l=90,360,10 do sphlng,l,3, color=c1
	for l=0,90,10 do sphlng,l,3,-90,0, color=c1
 
	for l=0,90,10 do sphlng,l,1,0,90, color=c2
	for l=0, 90,10 do sphlat,l,1,0,90, color=c2
 
	rr = makex(3., 1., -.2)
	n = n_elements(rr)
	cc = maken(c1,c2,n)
 
	for i=0, n-1 do sphlat,0,rr(i),0,90, color=cc(i)
	for i=0,n-1 do sphlat,0,rr(i),0,90, color=cc(i)
	for i=0,n-1 do sphlng,0,rr(i),0,90, color=cc(i)
	for i=0,n-1 do sphlng,90,rr(i),0,90, color=cc(i)
	sphinit, rad=3, color=c1
 
	for r = 3.5, 4.5, .2 do begin
	  sphlat, 0, r, maxrad=3, color=c3
	  if r lt 4.3 then begin
	    for l=0, 360, 10 do sphrad, l+r*25.,0,r,r+.2,maxrad=3,color=c3
	  endif
	endfor
 
	return
	end
