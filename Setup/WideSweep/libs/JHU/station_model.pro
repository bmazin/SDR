;-------------------------------------------------------------
;+
; NAME:
;       STATION_MODEL
; PURPOSE:
;       Meteorology station plot (wind barbs, ...).
; CATEGORY:
; CALLING SEQUENCE:
;       station_model, x, y, knots, dir
; INPUTS:
;       x = Longitude array.                   in
;       y = Latitude array.                    in
;       knots = Array of wind speeds in knots. in
;       azi = Array of wind directions from.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr symbol color (def = !p.color).
;         SIZE=sz symbol size factor (def=1).
;         THICKNESS=thk symbol thickness (def=1).
;         CLOUDCOVER=cloud: 0=clear, 1=scattered, 2=broken,
;           3=overcast, 4=obscured, 5=missing.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Dec 17
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro station_model, x, y, knots, dir, size=sz, _extra=extra, $
	  cloudcover=cloud, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Meteorology station plot (wind barbs, ...).'
	  print,' station_model, x, y, knots, dir'
	  print,'   x = Longitude array.                   in'
	  print,'   y = Latitude array.                    in'
	  print,'   knots = Array of wind speeds in knots. in'
	  print,'   azi = Array of wind directions from.   in'
	  print,' Keywords:'
	  print,'   COLOR=clr symbol color (def = !p.color).'
	  print,'   SIZE=sz symbol size factor (def=1).'
	  print,'   THICKNESS=thk symbol thickness (def=1).'
	  print,'   CLOUDCOVER=cloud: 0=clear, 1=scattered, 2=broken,'
	  print,'     3=overcast, 4=obscured, 5=missing.'
	  return
	endif
 
	if n_elements(sz) eq 0 then sz=1.
 
	;------------------------------------------
	;  Turtle object
	;------------------------------------------
	t = obj_new('rturtle', scale=sz*5., _extra=extra)
 
	;------------------------------------------
	;  Loop through arrays
	;------------------------------------------
	n = n_elements(x)
	for i=0, n-1 do begin
 
	  ;----  Set symbol center and orientation by wind direction  -----
	  t->set, ref=[x(i),y(i)],/data, orient=-dir(i)
 
	  ;----  Station circle -------
	  t->circle, 1
 
	  ;-----  Cloud Cover  -----------
	  if n_elements(cloud) gt 0 then begin
	    case cloud(i) of
0:	    begin
	    end
1:	    begin
	      t->chord, 0, ang=0, /abs, radius=1
	    end
2:	    begin
	      t->chord, [-.3,.3], ang=0, /abs, radius=1
	    end
3:	    begin
	      t->circle, 1, /fill
	    end
4:	    begin
	      t->chord, 0, ang=40, /abs, radius=1
	      t->chord, 0, ang=-40, /abs, radius=1
	    end
5:	    begin
	      t->movetoxy, -.4,-.4,/abs
	      t->drawtoxy,-.4,.4,/abs
	      t->drawtoxy, 0,0,/abs
	      t->drawtoxy,.4,.4,/abs
	      t->drawtoxy,.4,-.4,/abs
	    end
else:
	    endcase
	  endif
 
	  ;-----  Start wind barb  -------
	  k = knots(i)			; Wind speed.
	  if k lt 1. then begin		; Calm.
	    t->circle, .5		; Inner circle.
	    continue
	  endif else begin		; Not calm.
	    t->movetoxy, 0, 1		; Staff.
	    t->draw, 6, 0		; Positioned at end of staff.
	  endelse
	  k = k+2.5			; Center wind ranges.
 
	  dy = 0.8			; Step in y between barbs.
	  bang = 120.			; Barb angle.
 
	  ;------  Pennants  ------------
	  np = fix(k/50.)		; # pennants.
	  k = k - 50.*np		; Remainder.
	  for j=1,np do begin		; Plot pennants.
	    t->movexy,2,0,/start	; Start pennant polygon.
	    t->draw,3,bang-270.,tox=0,/close,/fill	; Complete pennant.
	  endfor
	  if np gt 0 then t->movexy,0,-dy	; Next barb start.
	  t->set, ang=90		; Point toward local y.
 
	  ;------  Full barbs  --------
	  nb = fix(k/10.)		; # full barbs.
	  k = k - 10.*nb		; Remainder.
	  for j=1,nb do begin		; Plot full barbs.
	    t->save			; Save current poistion.
	    t->draw,3,bang-180.,tox=2	; Plot barb.
	    t->restore			; Back to saved position.
	    t->movexy,0,-dy		; Next barb start.
	    t->set, ang=90		; Point toward local y.
	  endfor
 
	  ;------  Half barbs  --------
	  nb2 = fix(k/5.)		; # full barbs.
	  k = k - 5.*nb2		; Remainder.
	  if nb2 gt 1 then begin
	    print,' Error in wind bards.'
	    break
	  endif
	  if nb2 eq 1 then t->draw,3,bang-180.,tox=1	; Plot half barb.
 
	endfor
 
	;------------------------------------------
	;  Clean up
	;------------------------------------------
	obj_destroy, t
 
	end
