;-------------------------------------------------------------
;+
; NAME:
;       SCALE_DB
; PURPOSE:
;       Scale given data to db (meant for images).
; CATEGORY:
; CALLING SEQUENCE:
;       d = scale_db(p, db, pmax, minout, maxout)
; INPUTS:
;       p = original data.                      in
;       db = Decibel range to cover.            in
;       pmax = reference value to map to 0 db.  in
;       minout = value to map -DB db to.        in
;       maxout = value to map 0 db to.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NOCLIP means do not clip values to stay in
;           range -db to 0.  This allows saturation for
;           pmax < max(p).
;         MAXDB=mxdb  Returned max db.  Useful with /NOCLIP.
; OUTPUTS:
;       d = scaled values.                      out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  3 Apr, 1987.
;       R. Sterner, 15 Jul, 1991 --- updated to IDL V2.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function scale_db, p, db, pmax, minout, maxout, $
	  noclip=noclip, maxdb=maxdb, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Scale given data to db (meant for images).'
	  print,' d = scale_db(p, db, pmax, minout, maxout)'
	  print,'   p = original data.                      in'
	  print,'   db = Decibel range to cover.            in'
	  print,'   pmax = reference value to map to 0 db.  in'
	  print,'   minout = value to map -DB db to.        in'
	  print,'   maxout = value to map 0 db to.          in'
	  print,'   d = scaled values.                      out'
	  print,' Keywords:'
	  print,'   /NOCLIP means do not clip values to stay in'
	  print,'     range -db to 0.  This allows saturation for'
	  print,'     pmax < max(p).'
	  print,'   MAXDB=mxdb  Returned max db.  Useful with /NOCLIP.'
	  return, -1
	endif
 
	w = where(p lt 0., count)
	if count gt 0 then begin
	  print,' Error in scale_db: negative values not allowed.'
	  return, -1
	Endif
	np = n_params(0)
	if np lt 2 then begin
	  db = 60
	  print,' scale_db routine using default of 60 db.'
	endif
	if np lt 3 then begin
	  pmax = max(p)
	endif
	if np lt 4 then minout = 0.
	if np lt 5 then maxout = 255.
 
	p2 = p/pmax
	w = where(p2 le 0., count)
	if count gt 0 then p2(w) = 1.e-30
	t = 10.*alog10(p2)
	if not keyword_set(noclip) then t=t >(-db)<0
	maxdb = max(t)
	d = scalearray(t, (-db), 0, minout, maxout)
 
	return, d
	end
