;-------------------------------------------------------------
;+
; NAME:
;       MAKEVLT
; PURPOSE:
;       Generate and load a random color table (CT).
; CATEGORY:
; CALLING SEQUENCE:
;       makevlt
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         RED=r     Returned red array.                  out
;         GREEN=g   Returned green array.                out
;         BLUE=b    Returned blue array.                 out
;         SMOOTH=w  smoothing window width (def = 31).   in
;         SDEV=s    standard deviation (def = 64).       in
;         /WHITE forces top color to be white.
;         WHITE=N forces color N to be white.
;         /RAMP make a table that goes from dark to light.
;         /SAWTOOTH make a CT where colors ramp from dark to light. 8 teeth.
;         SAWTOOTH=N  A sawtooth CT with each tooth being N values long.
;         /NOLOAD inhibits CT load.
;         /GETSEED returns the random number seed use to make
;            the last CT.  The call is: makevlt, seed, /GETSEED
;         SEED=value sets the color table seed (can use to remake a CT).
;         /RANDOM  A completely random CT but with 0=black, 255=white.
;         BRIGHT=nb  Bright line table: all black but nb (def=20) bright lines
; OUTPUTS:
; COMMON BLOCKS:
;       makevlt_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  20 May, 1986.
;       R. Sterner, 12 Feb, 1993 --- Added /BRIGHT
;       R. Sterner, 1994 Feb 22 --- Modified to match new makey.
;       R. Sterner, 1994 Sep 27 --- Fixed color clipping problem.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro makevlt, red=r, green=g, blue=b, smooth=w, sdev=s, help=hlp,$
	   white=wh, ramp=rmp, noload=nl,$
	  getseed=gs, seed=sd, random=rndm, sawtooth=saw, bright=nbr
 
	common makevlt_com, ctseed, lstseed
 
	n = n_params(0)
 
	if keyword_set(hlp) then begin
	  print,' Generate and load a random color table (CT).'
	  print,' makevlt'
	  print,' Keywords:'
	  print,'   RED=r     Returned red array.                  out'
	  print,'   GREEN=g   Returned green array.                out'
	  print,'   BLUE=b    Returned blue array.                 out'
	  print,'   SMOOTH=w  smoothing window width (def = 31).   in'
	  print,'   SDEV=s    standard deviation (def = 64).       in'
	  print,'   /WHITE forces top color to be white.'
	  print,'   WHITE=N forces color N to be white.'
	  print,'   /RAMP make a table that goes from dark to light.'
	  print,'   /SAWTOOTH make a CT where colors ramp'+$
	    ' from dark to light. 8 teeth.'
	  print,'   SAWTOOTH=N  A sawtooth CT with each '+$
	    'tooth being N values long.'
	  print,'   /NOLOAD inhibits CT load.'
	  print,'   /GETSEED returns the random number seed use to make'
	  print,'      the last CT.  The call is: makevlt, seed, '+$
	    '/GETSEED'
	  print,'   SEED=value sets the color table seed (can use to '+$
	    'remake a CT).'
	  print,'   /RANDOM  A completely random CT but with '+$
	    '0=black, 255=white.'
	  print,'   BRIGHT=nb  Bright line table: all black but nb'+$
	    ' (def=20) bright lines.
	  return
	endif
 
	;-----  Return last color table seed  ----------
	if keyword_set(gs) then begin
	  if n_elements(lstseed) ne 0 then r = lstseed else print,$
	    ' Seed is undefined on first call.'
	  return
	endif
 
	;-----  random color table  -------
	if keyword_set(rndm) then begin
	  r =randomu(i,256)*256 & r(0) = 0  & r(255) = 255
	  g =randomu(i,256)*256 & g(0) = 0  & g(255) = 255
	  b =randomu(i,256)*256 & b(0) = 0  & b(255) = 255
	  if not keyword_set(nl) then tvlct, r, g, b
	  return
	endif
 
	;------  Set up color table parameters  -------
	if n_elements(s) eq 0 then s = 64.0
	if n_elements(w) eq 0 then w = 31
	if keyword_set(rmp) then s = 450
 
	;------  Handle provided seed  ---------
	if keyword_set(sd) then ctseed = sd
 
	;------  Save seed use to generate this table  ------
	if n_elements(ctseed) ne 0 then lstseed = ctseed
 
	;------  Generate color table  --------
	top = !d.table_size
	r = makey(256,w,seed=ctseed)  & r=((r-.5)/sdev(r)*s+top/2)
	g = makey(256,w,seed=ctseed)  & g=((g-.5)/sdev(g)*s+top/2)
	b = makey(256,w,seed=ctseed)  & b=((b-.5)/sdev(b)*s+top/2)
	if not keyword_set(rmp) then begin
	  r_flag = max((r lt 0) or (r gt top-1))
	  g_flag = max((g lt 0) or (g gt top-1))
	  b_flag = max((b lt 0) or (b gt top-1))
	  if r_flag then r = bytscl(r,top=top-1)
	  if g_flag then g = bytscl(g,top=top-1)
	  if b_flag then b = bytscl(b,top=top-1)
	endif
	if not keyword_set(saw) then begin
	  R(0) = 0
	  G(0) = 0
	  B(0) = 0
	endif
 
	;-----  Handle sawtooth table  ----
	if keyword_set(saw) then begin
	  sw = saw
	  if sw eq 1 then sw = 32		; Default sawtooth is 32 long.
	  t = findgen(256) mod sw		; Make sawtooth.
	  w0 = where(t eq 0)			; Find zeroes.
	  for i = 0, n_elements(w0)-1 do begin	; Brighten color
	    mx = r(w0(i))>g(w0(i))>b(w0(i))	;   Find max of r,g,b.
	    f = 255./(mx>1)				;   and set it to 255.
	    r(w0(i)) = f*r(w0(i))
	    g(w0(i)) = f*g(w0(i))
	    b(w0(i)) = f*b(w0(i))
	  endfor
	  for i = 1, sw-1 do begin		; Keep each tooth same color.
	    r(w0+i) = r(w0)
	    g(w0+i) = g(w0)
	    b(w0+i) = b(w0)
	  endfor
	  t = t/max(t)				; Normalize sawtooth.
	  r = r*t				; Now sawtooth colors.
	  g = g*t
	  b = b*t
	endif
 
	;-----  Handle 255 = white  -------
	if keyword_set(wh) then begin
	  iw = wh
	  if iw eq 1 then iw = topc()
	  r(iw) = 255
	  g(iw) = 255
	  b(iw) = 255
	endif
 
	;------  Handle ramp color table --------
	if keyword_set(rmp) then begin
	  r = r/max(r)
	  g = g/max(g)
	  b = b/max(b)
	  nrmp = maken(1., 0. , 256)
	  r = 1. - nrmp*r
	  g = 1. - nrmp*g
	  b = 1. - nrmp*b
	  s = (r+g+b)/3.
	  r = r/s
	  g = g/s
	  b = b/s
	  in = indgen(256)
	  r = r*in
	  g = g*in
	  b = b*in
	endif
 
	;-----  Handle bright line table  -----------
	if n_elements(nbr) ne 0 then begin
	  nbri = nbr
	  if nbr eq 1 then nbri = 20
	  w = randomu(seed,nbri)*256
	  rsv = r(w)
	  gsv = g(w)
	  bsv = b(w)
	  r = r*0
	  g = g*0
	  b = b*0
	  r(w) = rsv
	  g(w) = gsv
	  b(w) = bsv
	endif
 
	;-----  Load color table  --------
	if not keyword_set(nl) then tvlct, r, g, b
 
	return
	end
