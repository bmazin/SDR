;-------------------------------------------------------------
;+
; NAME:
;       FIXANGH
; PURPOSE:
;       Fix angle wraparound using a hysteresis method.
; CATEGORY:
; CALLING SEQUENCE:
;       out = fixangh(in,delta)
; INPUTS:
;       in = input angle in degrees.    in
;       delta = hysteresis value.       in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = fixed angle.              out
; COMMON BLOCKS:
; NOTES:
;       Notes: when angle in varies above 360+delta it is reset
;       to delta.  When it varies below -delta it is reset to
;       360-delta.  This should reduce the annoying jitter when
;       the angle varies about the 0/360 break point.
;       Plot resulting angle for yran=[-delta,360+delta].
; MODIFICATION HISTORY:
;       R. Sterner, 1996 May 12
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function fixangh, in, delta, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Fix angle wraparound using a hysteresis method.'
 	  print,' out = fixangh(in,delta)'
	  print,'   in = input angle in degrees.    in'
	  print,'   delta = hysteresis value.       in'
	  print,'   out = fixed angle.              out'
	  print,' Notes: when angle in varies above 360+delta it is reset'
	  print,' to delta.  When it varies below -delta it is reset to'
	  print,' 360-delta.  This should reduce the annoying jitter when'
	  print,' the angle varies about the 0/360 break point.'
	  print,' Plot resulting angle for yran=[-delta,360+delta].'
	  return,''
	endif
 
	;----  Let angle vary from -delta to 360+delta  -------
	del2 = 2*delta
	md = 360+del2
	a = pmod((fixang(in)+delta), md)
 
	;----  Reset angles that stray beyond limits  ---------
	for i=0, n_elements(a)-2 do begin
	  d = a(i+1)-a(i)
	  if d lt -180 then begin
	    a(i+1)=pmod(a(i+1:*)+del2,md)
	  endif
	  if d gt  180 then begin
	    a(i+1)=pmod(a(i+1:*)-del2,md)
	  endif
	endfor
 
	return,a-delta
	end
