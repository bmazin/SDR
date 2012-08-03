;-------------------------------------------------------------
;+
; NAME:
;       CTINT
; PURPOSE:
;       Interpolate between two color table entries.
; CATEGORY:
; CALLING SEQUENCE:
;       ctint, r, g, b, i1, i2, [mode]
; INPUTS:
;       i1, i2 = start and end index for interpolation.  in
;       mode = interpolation mode (def=1).               in
;         Color interpolation mode
;       0 = Copy.  Copy color i1 to i1:i2 range.
;       1 = R,G,B.  Interp each color independently.
;       2 = H,S,V straight.  Through less sat. hues (grays).
;       3 = H,S,V curved. Through sat. in-between hues.
;       4 = Reverse.  Reverse colors in i1:i2 range.
;       5 = Ramp value from i1 down to 0 at i2.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       r,g,b = color table, red, green, blue.           in out
; COMMON BLOCKS:
; NOTES:
;       Note: Modifies the color table.
; MODIFICATION HISTORY:
;       R. Sterner, 6 Sep, 1990
;       R. Sterner, 18 Oct, 1993 --- Added Copy and Reverse.
;       R. Sterner, 21 Oct, 1993 --- Added Ramp mode.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro ctint, r, g, b, i1, i2, mode, help=hlp
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' Interpolate between two color table entries.'
	  print,' ctint, r, g, b, i1, i2, [mode]'
	  print,'   r,g,b = color table, red, green, blue.           in out'
	  print,'   i1, i2 = start and end index for interpolation.  in'
	  print,'   mode = interpolation mode (def=1).               in'
	  print,'     Color interpolation mode'
	  print,'	0 = Copy.  Copy color i1 to i1:i2 range.'
	  print,'	1 = R,G,B.  Interp each color independently.'
	  print,'	2 = H,S,V straight.  Through less sat. hues (grays).'
	  print,'	3 = H,S,V curved. Through sat. in-between hues.'
	  print,'	4 = Reverse.  Reverse colors in i1:i2 range.'
	  print,'	5 = Ramp value from i1 down to 0 at i2.'
	  print,' Note: Modifies the color table.'
	  return
	endif
 
	if n_params(0) lt 6 then mode = 1
 
	;-----------  Interpolate  --------------
	lo = i1<i2
	hi = i1>i2
	n = hi - lo + 1
 
	;-------  Ramp mode  ------------
	if mode eq 5 then begin
	  rgb_to_hsv, r, g, b, hh, ss, vv
	  wt = maken(0., 1., n)
	  if i2 gt i1 then wt = reverse(wt)
	  vv(lo) = vv(lo:hi)*wt
	  hsv_to_rgb,hh,ss,vv,r,g,b
	endif
	;-------  Reverse  --------------------
	if mode eq 4 then begin
	  r(lo) = reverse(r(lo:hi))
	  g(lo) = reverse(g(lo:hi))
	  b(lo) = reverse(b(lo:hi))
	endif
	;-------  H,S,V curved mode  ----------
	if mode eq 3 then begin	
	  rgb_to_hsv, r, g, b, hh, ss, vv
	  t1 = maken(hh(lo),hh(hi),n)  & hh(lo) = t1
	  t2 = maken(ss(lo),ss(hi),n)  & ss(lo) = t2<1.
	  t3 = maken(vv(lo),vv(hi),n)  & vv(lo) = t3<1.
	  hsv_to_rgb,hh,ss,vv,r,g,b
	endif
	;-------  H,S,V straight  --------
	if mode eq 2 then begin
	  rgb_to_hsv, r, g, b, hh, ss, vv
	  polrec, ss(lo), hh(lo)/!radeg, xxlo, yylo
	  polrec, ss(hi), hh(hi)/!radeg, xxhi, yyhi
	  xx = maken(xxlo, xxhi, n)  & yy = maken(yylo, yyhi, n)
	  recpol, xx, yy, ssi, hhi  & hhi = hhi*!radeg
	  vvi = maken(vv(lo), vv(hi), n)
 	  ss(lo) = ssi<1.  & hh(lo) = hhi  & vv(lo) = vvi<1.
	  hsv_to_rgb,hh,ss,vv,r,g,b
	endif
	;-------  R,G,B mode  -----------
	if mode eq 1 then begin
	  t1 = maken(fix(r(lo)),fix(r(hi)),n)  & r(lo) = t1
	  t2 = maken(fix(g(lo)),fix(g(hi)),n)  & g(lo) = t2
	  t3 = maken(fix(b(lo)),fix(b(hi)),n)  & b(lo) = t3
	endif
	;-------  Copy  ------------------
	if mode eq 0 then begin
	  r(lo:hi) = r(i1)
	  g(lo:hi) = g(i1)
	  b(lo:hi) = b(i1)
	endif
 
	tvlct, r, g, b				; Load new color table.
 
	return
 
	end
