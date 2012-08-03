;-------------------------------------------------------------
;+
; NAME:
;       YY2YYYY
; PURPOSE:
;       Convert a 2 digit year to a 4 digit year.
; CATEGORY:
; CALLING SEQUENCE:
;       yyyy = yy2yyyy( yy)
; INPUTS:
;       yy = 2 digit year.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         /PAST means 4 digit year is current or past.
;           Use this for birthdates or any dates known to be past.
;           By default closest 4 digit year is returned.
;         BASE=base  Use the year given in base instead of the
;           current year to figure out the 4 digit years.
; OUTPUTS:
;       yyyy = 4 digit year.        out
;         On error returns -1.
; COMMON BLOCKS:
; NOTES:
;       Notes: 2 digit years will always be useful, so a
;        good way to convert them to 4 digit years is also
;        useful.  This routine should not break in the future.
;        If incoming value is a string, returned value will be
;        a string with no spaces on ends.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Aug 2
;       R. Sterner, 2001 Jan 05 --- Added special check for string values.
;       R. Sterner, 2003 Aug 27 --- Better error checking.
;       R. Sterner, 2007 Jan 04 --- Made for loop index long.
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function yy2yyyy, yy0, past=past, base=base, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a 2 digit year to a 4 digit year.'
	  print,' yyyy = yy2yyyy( yy)'
	  print,'   yy = 2 digit year.          in'
	  print,'   yyyy = 4 digit year.        out'
	  print,'     On error returns -1.'
	  print,' Keywords:'
	  print,'   /PAST means 4 digit year is current or past.'
	  print,'     Use this for birthdates or any dates known to be past.'
	  print,'     By default closest 4 digit year is returned.'
	  print,'   BASE=base  Use the year given in base instead of the'
	  print,'     current year to figure out the 4 digit years.'
	  print,' Notes: 2 digit years will always be useful, so a'
	  print,'  good way to convert them to 4 digit years is also'
	  print,'  useful.  This routine should not break in the future.'
	  print,'  If incoming value is a string, returned value will be'
	  print,'  a string with no spaces on ends.'
	  return,''
	endif
 
	;------  Set flag if incoming value is a string  -----------
	sz = size(yy0)
	str_flag = sz(sz(0)+1) eq 7
 
	yy = yy0 + 0				; Force input to be numeric.
	if min(yy) lt 0 then begin
	  print,' Error in yy2yyyy: input year must be > 0.'
	  return, -1
	endif
 
	;-------------------------------------------------------------
	;  Find current year (or working year from BASE)
	;-------------------------------------------------------------
	if n_elements(base) ne 0 then begin
	  yn = base+0			  ; Work with year given in base.
	endif else begin
	  t = systime()			  ; Current time.
	  yn = strmid(t,strlen(t)-4,4)+0  ; Pick off year.
	endelse
 
	;-------------------------------------------------------------
	;  Current century
	;-------------------------------------------------------------
	cn = 100*fix(yn/100)		  ; Current century.
 
	;-------------------------------------------------------------
	;  Make list of potential centuries
	;-------------------------------------------------------------
	list = [cn-100,cn]		  ; List of last and current centuries.
	if not keyword_set(past) then $	  ; If not restricted to past years
	  list = [cn+100,list]		  ;   then include next century.
 
	;-------------------------------------------------------------
	;  Set up storage for output
	;-------------------------------------------------------------
	yy4 = yy			  ; Copy input to output variable.
 
	;-------------------------------------------------------------
	;  Loop through all input years
	;-------------------------------------------------------------
	for i=0L,n_elements(yy)-1 do begin
	  t = yy(i)			  ; Grab i'th year.
	  if t lt 100 then begin	  ; 2 digits?
	    lst = list + t		  ; Possible 4 digit years.
	    d = abs(yn-lst)		  ; Years away from now.
	    w = where(d eq min(d))	  ; Look for closest to now (or base).
	    t = lst(w(0))		  ; Pull it from list.
	  endif
	  yy4(i) = t			  ; Insert 4 digit year.
	endfor
 
	if str_flag eq 1 then yy4 = strtrim(yy4,2)	; Convert to string.
 
	return, yy4			  ; Return 4 digit year.
 
	end
