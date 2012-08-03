;-------------------------------------------------------------
;+
; NAME:
;       STRSEC
; PURPOSE:
;       Convert seconds after midnight to a time string.
; CATEGORY:
; CALLING SEQUENCE:
;       tstr = strsec(sec, [d])
; INPUTS:
;       sec = seconds after midnight.             in
;         Scalar or array.
;       d = optional denominator for a fraction.  in
; KEYWORD PARAMETERS:
;       Keywords:
;          /HOURS forces largest time unit to be hours instead of days.
; OUTPUTS:
;       tstr = resulting text string.             out
; COMMON BLOCKS:
; NOTES:
;       Notes: Output is of the form: [DDD/]hh:mm:ss[:nnn/ddd]
;         where DDD=days, hh=hours, mm=minutes, ss=seconds,
;         nnn/ddd=fraction of a sec given denominator ddd in call.
;         If sec is double precision then 1/10 second can be
;         resolved in more than 10,000 days.  Use double precision when
;         possible. Time is truncated, so to round to nearest second,
;         when not using fractions, add .5 to sec.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 8 Jan, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES --- Added day: 21 Feb, 1985.
;       RES 19 Sep, 1989 --- converted to SUN
;       RES 18 Mar, 1990 --- allowed arrays.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       R. Sterner, 12 Feb, 1993 --- returned 1 element array as a scalar.
;       also cleaned up.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function strsec,sec0,d, help=hlp, hours=hrs
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert seconds after midnight to a time string.'
	  print,' tstr = strsec(sec, [d])'
	  print,'    sec = seconds after midnight.             in'
	  print,'      Scalar or array.
	  print,'    d = optional denominator for a fraction.  in'
	  print,'    tstr = resulting text string.             out'
	  print,' Keywords:'
	  print,'    /HOURS forces largest time unit to be hours '+$
	    'instead of days.'
	  print,' Notes: Output is of the form: [DDD/]hh:mm:ss[:nnn/ddd]'
	  print,'   where DDD=days, hh=hours, mm=minutes, ss=seconds,'
	  print,'   nnn/ddd=fraction of a sec given denominator ddd in call.'
	  print,'   If sec is double precision then 1/10 second can be'
	  print,'   resolved in more than 10,000 days.  Use double precision'+$
	    ' when'
	  print,'   possible. Time is truncated, so to round to nearest '+$
	    'second,'
	  print,'   when not using fractions, add .5 to sec.'
	  return, -1
	endif
 
	seca = sec0
	nn = n_elements(seca)		; Number of elements in input array.
	out = strarr(nn)		; Output string array.
 
	;-------------------------------------------------------------------
	for ii = 0, nn-1 do begin	; Loop through all input elements.
	sec = seca(ii)			; Pull out the ii'th element.
	t = double(sec)			; Convert to double.
	dy = long(t/86400)		; # days.
	t = t - 86400*dy		; Time without days.
	h = long(t/3600)		; # hours.
	t = t - 3600*h			; Time without hours.
	if keyword_set(hrs) then begin	; If /HOURS then convert days to hours.
	  h = h + 24*dy
	  dy = 0
	endif
	m = long(t/60)			; # minutes.
	t = t - 60*m			; Time without minutes.
	s = long(t)			; Seconds.
	f = t - s			; Time without seconds (=fraction).
 
	;------  Make days string  --------
	sdy = ''				; Day part of string, def=null.
	if dy gt 0 then begin
	  if dy lt 1000 then begin		; 3 digit day.
	    sdy = string(dy,form='(I3.3,"/")')  ; Convert days to string.
	  endif else begin
	    sdy = strtrim(dy,2)+'/'		; GE 3 digit day.
	  endelse
	endif
	;------  Make hours string (may be big)  -----
	if h lt 10 then begin
	  hh = string(h,form='(I2.2)')		; 2 digit hour.
	endif else begin
	  hh = strtrim(h,2)			; GE 2 digit hour.
	endelse
	;------  Make mm:ss string  ----------
	fmt = '(I2.2,":",I2.2)' 	; hh:mm:ss format like 12:34:32
	shms = sdy + hh + ':' + string(m,s,form=fmt)
 	;------  Make fraction of second string  ----------
	if n_params(0) ge 2 then begin		; Also want fraction of second.
	  sd = strtrim(string(d),2)		; Convert denom. to string.
	  ln = strtrim(strlen(strtrim(d-1,2)),2)  ; Length of numerator as str.
	  n = long(d*f+.5)			; Find numerator.
	  fmt = '(I'+ln+'.'+ln+')'		; Numerator format.
	  sn = string(n,form=fmt)		; Convert numerator to string.
	  shms = shms+':'+sn+'/'+sd		; Tack on fraction as a string.
	endif
 
	out(ii) = shms
 
	endfor
	;-------------------------------------------------------------------
 
	if n_elements(out) eq 1 then out=out(0)	; 1 elem: return as a scalar.
 
	return, out
 
	end
