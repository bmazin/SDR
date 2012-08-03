;-------------------------------------------------------------
;+
; NAME:
;       NEXTNUM
; PURPOSE:
;       Return next number using the arrow keys.
; CATEGORY:
; CALLING SEQUENCE:
;       n = nextnum(m)
; INPUTS:
;       m = input number.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         STEPS=s  give list of allowed step sizes.
;           Ex: STEPS=[1,5,10].  Use Up and down arrows to select.
;         LIMITS=l gives lower and upper limits on n.
;           Ex: LIMITS=[0,100] allows numbers from 0 to 100.
;         /MENU gives menu selection of a number in the limit range.
;           If returned value is 1 less than lower limit then quit
;           was selected. Best for a small range of values.
;         EXIT=e  returns character typed on keyboard.
; OUTPUTS:
;       n = output number.          out
;         n is + or - 1 step from m.
; COMMON BLOCKS:
;       nextnum_com
; NOTES:
;       Notes: a number may also be directly typed in, a non-digit
;         terminates the number entry and returns the number.
;         The ENTER key gives a menu to select from.
;         Best for a small range.
; MODIFICATION HISTORY:
;       R. Sterner, 21 Mar, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function nextnum, n, help=hlp, steps=steps, limits=limits,$
	  exit=k, menu=menu
 
	common nextnum_com, csteps, sind, climits
 
	if keyword_set(hlp) then begin
	  print,' Return next number using the arrow keys.'
	  print,' n = nextnum(m)'
	  print,'   m = input number.           in'
	  print,'   n = output number.          out'
	  print,'     n is + or - 1 step from m.'
	  print,' Keywords:'
	  print,'   STEPS=s  give list of allowed step sizes.'
	  print,'     Ex: STEPS=[1,5,10].  Use Up and down arrows to select.'
	  print,'   LIMITS=l gives lower and upper limits on n.'
	  print,'     Ex: LIMITS=[0,100] allows numbers from 0 to 100.'
	  print,'   /MENU gives menu selection of a number in the limit range.'
	  print,'     If returned value is 1 less than lower limit then quit'
	  print,'     was selected. Best for a small range of values.'
	  print,'   EXIT=e  returns character typed on keyboard.'
	  print,' Notes: a number may also be directly typed in, a non-digit'
	  print,'   terminates the number entry and returns the number.'
	  print,'   The ENTER key gives a menu to select from.'
	  print,'   Best for a small range.'
	  return, -1
	endif
 
	if n_elements(steps) gt 0 then csteps = steps
	if n_elements(limits) gt 0 then climits = limits
	if n_elements(csteps) eq 0 then csteps = [1,10]
	if n_elements(climits) eq 0 then climits = [0,100]
	if n_elements(sind) eq 0 then sind = 0
	if n_params(0) lt 1 then n = 0
 
	if keyword_set(menu) then begin
men:	  t = ['Select #','Quit']
	  for i = climits(0), climits(1) do t = [t,strtrim(i,2)]
	  n = n>climits(0)<climits(1)
	  in = wmenu(t, title=0, init=n+2-climits(0))
	  n = in - 2 + climits(0)
	  return, n
	endif
 
	tmp = 0
 
loop:	k = getkey()
	if k eq 'RIGHT' then begin
	  n = (n + csteps(sind))<climits(1)
	  return, n
	endif
	if k eq 'LEFT' then begin
	  n = (n - csteps(sind))>climits(0)
	  return, n
	endif
	if k eq 'UP' then begin
	  sind = (sind + 1)<(n_elements(csteps)-1)
	  print,' Step size = '+strtrim(csteps(sind),2)
	  goto, loop
	endif
	if k eq 'DOWN' then begin
	  sind = (sind - 1)>0
	  print,' Step size = '+strtrim(csteps(sind),2)
	  goto, loop
	endif
	if k eq 'ENTER' then begin
	  if (climits(1)-climits(0)) gt 250 then begin
	    print,' Range too big for menu selection.'
	    goto, loop
	  endif
	  goto, men
	endif
	if (k ge '0') and (k le '9') then begin
	  tmp = tmp*10 + k
	  goto, loop
	endif
	return, tmp<climits(1)>climits(0)
 
	end
