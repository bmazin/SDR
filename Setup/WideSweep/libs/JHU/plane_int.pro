;-------------------------------------------------------------
;+
; NAME:
;       PLANE_INT
; PURPOSE:
;       Compute the intersection line of two planes.
; CATEGORY:
; CALLING SEQUENCE:
;       plane_int, a1, a2, a3, b1, b2, b3, p, u, flag
; INPUTS:
;       a1, a2, a3 = 3 pts in plane A (a1=(xa,ya,za),...).  in.
;       b1, b2, b3 = 3 pts in plane B (b1=(xb,yb,zb),...).  in.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       p = a point on intersection line (Px,Py,Pz).        out.
;       u = Unit vector along intersection line (Ux,Uy,Uz). out.
;       flag = intersect flag.  0: none, 1: intersection.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 25 Oct, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       R. Sterner, 1996 Dec 10 --- Fixed a mistake found by
;       David S. Foster, UCSD.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro plane_int, a1, a2, a3, b1, b2, b3, p, u, flag, help=hlp
 
	if (n_params(0) lt 8) or keyword_set(hlp) then begin
	  print,' Compute the intersection line of two planes.'
	  print,' plane_int, a1, a2, a3, b1, b2, b3, p, u, flag'
	  print,'   a1, a2, a3 = 3 pts in plane A (a1=(xa,ya,za),...).  in.'
	  print,'   b1, b2, b3 = 3 pts in plane B (b1=(xb,yb,zb),...).  in.'
	  print,'   p = a point on intersection line (Px,Py,Pz).        out.'
	  print,'   u = Unit vector along intersection line (Ux,Uy,Uz). out.'
	  print,'   flag = intersect flag.  0: none, 1: intersection.'
	  return
	endif
 
	;-------  Get equations of the two planes  ---------
	na = crossp((a2-a1), (a3-a1))	; Normal to plane A.
	na = unit(na)			; Work with unit normal.
	da = total(na*a1)		; Plane eq: X dot NA = DA
	nb = crossp((b2-b1), (b3-b1))	; Normal to plane B.
	nb = unit(nb)			; Work with unit normal.
	db = total(nb*b1)		; Plane eq: X dot NB = DB
 
	;-------  Test for parallel planes  ----------------
	crss = crossp(na,nb)		; NA cross NB = 0 if parallel.
;	det = abs(total(crss))		; Wrong.  Fixed below.
	if abs(total(crss)) lt 1e-5 then begin
;	  print,'Error: Planes are parallel or very close.'
;	  print,'No intersection found.'
	  flag = 0
	  return
	endif
 
	;--- For non-parallel planes NA and NB are non-parallel and
	;--- with NA X NB form a basis set for R3, so any X in R3
	;--- may be written as X = a*NA + b*NB + t*(NA X NB)
	;--- Substituting into the plane equations gives:
	;--- a*abs(NA)^2 + b*(NA dot NB) = DA
	;--- a*(NA dot NB) + b*abs(NB)^2 = DB
	;--- Since NA and NB are unit vectors NA dot NA =1 = NB dot NB so
	;--- a + b*(NA dot NB) = DA
        ;--- a*(NA dot NB) + b = DB
	;--- Solve for a and B below.
 
	dot = total(na*nb)
	det = 1-dot^2
 
	a = (da - db*dot)/det
	b = (db - da*dot)/det
 
	p = a*na + b*nb		; A point common to both planes.
	u = unit(crss)		; Unit vector along line.		
 
	flag = 1
 
	return
	end
