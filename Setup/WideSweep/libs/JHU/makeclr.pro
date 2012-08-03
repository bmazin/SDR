;-------------------------------------------------------------
;+
; NAME:
;       MAKECLR
; PURPOSE:
;       Make an array of of 24-bit colors.
; CATEGORY:
; CALLING SEQUENCE:
;       c = makeclr(n)
; INPUTS:
;       n = Number of colors to make.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         H1=h1  Start Hue (def=0).
;         H2=h2    End Hue (def=300).
;         S1=s1  Start Sat (def=1).
;         S2=s2    End Sat (def=1).
;         V1=v1  Start Val (def=1).
;         V2=v2    End Val (def=1).
; OUTPUTS:
;       c = Returned array of colors.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2007 May 03
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function makeclr, n, h1=h1, h2=h2, s1=s1, s2=s2, v1=v1, v2=v2, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Make an array of of 24-bit colors.'
	  print,' c = makeclr(n)'
	  print,'   n = Number of colors to make.  in'
	  print,'   c = Returned array of colors.  out'
	  print,' Keywords:'
	  print,'   H1=h1  Start Hue (def=0).'
	  print,'   H2=h2    End Hue (def=300).'
	  print,'   S1=s1  Start Sat (def=1).'
	  print,'   S2=s2    End Sat (def=1).'
	  print,'   V1=v1  Start Val (def=1).'
	  print,'   V2=v2    End Val (def=1).'
	  return, ''
	endif
 
	if n_elements(h1) eq 0 then h1=0.
	if n_elements(h2) eq 0 then h2=300.
	if n_elements(s1) eq 0 then s1=1.
	if n_elements(s2) eq 0 then s2=1.
	if n_elements(v1) eq 0 then v1=1.
	if n_elements(v2) eq 0 then v2=1.
 
	h = maken(h1,h2,n)
	s = maken(s1,s2,n)
	v = maken(v1,v2,n)
	clr = lonarr(n)
	for i=0,n-1 do clr(i)=tarclr(/hsv,h(i),s(i),v(i))
	return,clr
 
 
	end
