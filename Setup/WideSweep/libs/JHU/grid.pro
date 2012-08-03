;-------------------------------------------------------------
;+
; NAME:
;       GRID
; PURPOSE:
;       Draw x/y grid in plot window.
; CATEGORY:
; CALLING SEQUENCE:
;       grid, dx, dy
; INPUTS:
;       dx, dy = optional x and y grid step sizes.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr  grid color (def=!p.color).
;         NUMBER=n  Approximate number of grid lines (def=6).
; OUTPUTS:
; COMMON BLOCKS:
;       grid_com
; NOTES:
;       Note: defaults to last grid if called with no args.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 19
;       R. Sterner, 2005 Nov 04 --- Added THICK=thk. Checked for data coords.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro grid, dx0, dy0, color=clr0, number=n0, thick=thk0, help=hlp
 
	common grid_com, clr, n, dx, dy, thk
 
	if keyword_set(hlp) then begin
	  print,' Draw x/y grid in plot window.'
	  print,' grid, dx, dy'
	  print,'   dx, dy = optional x and y grid step sizes.  in'
	  print,' Keywords:'
	  print,'   COLOR=clr  grid color (def=!p.color).'
	  print,'   NUMBER=n  Approximate number of grid lines (def=6).'
	  print,' Note: defaults to last grid if called with no args.'
	  return
	endif
 
	;--------  Defaults  -------------------
	if n_elements(clr0) ne 0 then clr=clr0
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(thk0) ne 0 then thk=thk0
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(n0) ne 0 then n=n0
	if n_elements(n) eq 0 then n=6
 
	;--------  Check if data coordinates defined  -----
	if (!x.crange(0) eq 0) and (!x.crange(1) eq 0) then begin
	  print,' Error in grid: No data coordinates defined.'
	  return
	endif
 
	;--------  Steps  ----------------------
	;------  Force common to be defined  ----------
	if n_elements(dx) eq 0 then begin
	  naxes,!x.crange(0),!x.crange(1),n,tx1,tx2,ntx,dx,ndec,/no25
	endif
	if n_elements(dy) eq 0 then begin
	  naxes,!y.crange(0),!y.crange(1),n,ty1,ty2,nty,dy,ndec,/no25
	endif
	;------  New number given  ---------------------
	if n_elements(n0) ne 0 then begin
	  naxes,!x.crange(0),!x.crange(1),n,tx1,tx2,ntx,dx,ndec,/no25
	  naxes,!y.crange(0),!y.crange(1),n,ty1,ty2,nty,dy,ndec,/no25
	endif
 
	if n_elements(dx0) eq 0 then dx0=dx
	t = nearest(dx0,!x.crange(0),tmp,tx1)
	t = nearest(dx0,!x.crange(1),tx2,tmp)
	dx = dx0					; Remember given dx.
	if n_elements(dy0) eq 0 then dy0=dy
	t = nearest(dy0,!y.crange(0),tmp,ty1)
	t = nearest(dy0,!y.crange(1),ty2,tmp)
	dy = dy0
 
	;--------  Find values  -----------------
	if !x.crange(0) eq tx1 then tx1=tx1+dx
	if !x.crange(1) eq tx2 then tx2=tx2-dx
	if !y.crange(0) eq ty1 then ty1=ty1+dy
	if !y.crange(1) eq ty2 then ty2=ty2-dy
 
	;---------  Plot  ------------------------
	ver, makex(tx1,tx2,dx), col=clr, thick=thk, shrink=0.02
	hor, makex(ty1,ty2,dy), col=clr, thick=thk, shrink=0.02
 
	end
