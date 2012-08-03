;-------------------------------------------------------------
;+
; NAME:
;       SECHMS
; PURPOSE:
;       Seconds after midnight to h, m, s, numbers and strings.
; CATEGORY:
; CALLING SEQUENCE:
;       sechms, sec, h, [m, s, sh, sm, ss]
; INPUTS:
;       sec = seconds after midnight.            in
; KEYWORD PARAMETERS:
;       Keywords:
;         FRAC=fr Returned fractional part of seconds.
;         EPS=e  Small amount to add to allow for round off error
;           Values eps < some integer will become integer.
;           Default=1E-12
; OUTPUTS:
;       h, m, s = Hrs, Min, Sec as numbers.      out
;       sh, sm, ss = Hrs, Min, Sec as strings    out
;             (with leading 0s where needed).
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 17 Nov, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       R. Sterner, 27 Sep, 1993 --- modified to handle arrays.
;       R. Sterner, 1998 May 21 --- Fixed a bug found by Dave Watts and
;       Damian Murphy that caused a lost second sometimes.
;       R. Sterner, 2001 Jul 31 --- Added some missing quote marks that
;       caused trouble for Randall Skelton in IDL 2.3.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro sechms, sec, h, m, s, sh, sm, ss, frac=frac, eps=eps, help=hlp
 
	if (keyword_set(hlp)) or (n_params(0) LT 2) then begin
	  print,' Seconds after midnight to h, m, s, numbers and strings.'
	  print,' sechms, sec, h, [m, s, sh, sm, ss]'
	  print,'   sec = seconds after midnight.            in'
	  print,'   h, m, s = Hrs, Min, Sec as numbers.      out'
	  print,'   sh, sm, ss = Hrs, Min, Sec as strings    out'
	  print,'         (with leading 0s where needed).'
	  print,' Keywords:'
	  print,'   FRAC=fr Returned fractional part of seconds.'
	  print,'   EPS=e  Small amount to add to allow for round off error'
	  print,'     Values eps < some integer will become integer.'
	  print,'     Default=1E-12'
	  return
	endif
 
	if n_elements(eps) eq 0 then eps=1E-12
 
	t = sec + eps
	h = long(t/3600)
	t = t - 3600*h
	m = long(t/60)
	t = t - 60*m
	s = floor(t)
	frac = t - s
 
	sh = string(h,form='(i2.2)')
	sm = string(m,form='(i2.2)')
	ss = string(s,form='(i2.2)')
 
	return
 
	end
