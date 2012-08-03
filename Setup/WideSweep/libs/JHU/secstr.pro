;-------------------------------------------------------------
;+
; NAME:
;       SECSTR
; PURPOSE:
;       Convert a time string to seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       s = secstr(tstr)
; INPUTS:
;       tstr = time string.          in
;         Scalar or string array.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = seconds after midnight.  out
; COMMON BLOCKS:
; NOTES:
;       Note: time string must have the following format:
;         [DDD/]hh:[mm[:ss[:nnn/ddd]]]
;         where hh=hours, mm=minutes, ss=seconds, DDD=days,
;         nnn/ddd=a fraction.
;         A special case with no colons also allowed:
;           174636 (17:46:36) or 1746 (17:46).  No days allowed.
;         Examples: 12:, 12:34, 12:34:10, 2/12:34:10,
;         2/12:34:10:53/60, 12:34:10:53/60
; MODIFICATION HISTORY:
;       Written R. Sterner, 10 Jan, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       Added day: 21 Feb, 1985.
;       Added negative time: 16 Apr, 1985.
;       RES 18 Sep, 1989 --- converted to SUN.
;       R. Sterner 2 Jan, 1990 --- allowed arrays.
;       R. Sterner 2 Nov, 1992 --- Handled null srtings.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       R. Sterner 9 Feb, 1993 --- Fixed to handle correctly both arrays
;       and null strings.
;       R. Sterner, 12 Feb, 1993 --- returned 1 element arrays as a scalar.
;       R. Sterner, 2001 Jul 23 --- Added no colon time format case.
;       R. Sterner, 2007 Jan 04 --- Made loop index long.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function secstr,tstr0, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a time string to seconds.'
	  print,' s = secstr(tstr)'
	  print,'    tstr = time string.          in'
	  print,'      Scalar or string array.'
	  print,'    s = seconds after midnight.  out'
	  print,' Note: time string must have the following format:'
	  print,'   [DDD/]hh:[mm[:ss[:nnn/ddd]]]'
	  print,'   where hh=hours, mm=minutes, ss=seconds, DDD=days,'
	  print,'   nnn/ddd=a fraction.'
	  print,'   A special case with no colons also allowed:'
	  print,'     174636 (17:46:36) or 1746 (17:46).  No days allowed.'
	  print,'   Examples: 12:, 12:34, 12:34:10, 2/12:34:10,'
	  print,'   2/12:34:10:53/60, 12:34:10:53/60'
	  return, -1
	endif
 
	tstra = tstr0
	w = where(tstra eq '', cnt)	; Look for null strings.
	if cnt gt 0 then tstra(w) = '0:00:00'	; Set null strings to 0.
	nnt = n_elements(tstra)		; Number of elements.
	sa = dblarr(nnt)		; Out array of seconds after midnight.
 
	for ii = 0L, nnt-1 do begin	; Loop through input time strings.
 
	tstr = tstra(ii)		; Pull out ii'th time string.
 
	if strpos(tstr,':') lt 0 then begin
	  ;-------  No colon case  ------------------
	  th = strmid(tstr,0,2)		; Pick off hours.
	  tm = strmid(tstr,2,2)		; Minutes.
	  ts = strmid(tstr,4,2)		; Seconds.
	  s = 3600.d0*th + 60.d0*tm + double(ts)	; Convert to seconds.
	endif else begin
	  ;-------  Time with colons  -----------------
	  ;-------  first search for day  -----------
	  tdy = 0.			; default is none.
	  ioff = 0			; no offset for other items.
	  lminus = strpos(tstr,'-')	; look for negative time.
	  t = stress(tstr,'r',0,'-',' ')  ; replace it by a space.
	  ls = strpos(t,'/')		; look for a '/'
	  t = stress(t,'r',0,':',' ')	; replace ':' with spaces.
	  t = stress(t,'r',0,'/',' ')	; replace '/' with space.
	  if ls gt 0 then t = strep(t,'f',999,'      0')  ; add 0 to end.
	  fndwrd,t,nwds,loc,len		; locate words.
	  if nwds lt 2 then goto, get     ; only 0 or 1 item, assume hrs.
	  if (ls gt loc(0)) and (ls lt loc(1)) then begin   ; found day.
	    tdy = getwrd(t,0)		; get day.
	    ioff = 1			; must offset other items by 1.
	  endif
 
get:	  th = getwrd(t,0+ioff)		; Pick off hours.
	  tm = getwrd(t,1+ioff)		; Pick off minutes.
	  ts = getwrd(t,2+ioff)		; Pick off seconds.
	  tn = getwrd(t,3+ioff)		; Pick off num of fract of a second.
	  td = getwrd(t,4+ioff)		; Pick off den of fract of a second.
	  if td eq 0 then td = 1		; If no denomiator then use 1.
 
	  s = 86400.d0*tdy + 3600.d0*th + 60.d0*tm + $	; convert to seconds.
	        double(ts) + double(tn)/double(td)
	  if lminus ne -1 then s = -s			; was a negative time.
	endelse
 
	sa(ii) = s
 
	endfor
 
	if n_elements(sa) eq 1 then sa = sa(0)	; 1 Elem. array: return scalar. 
 
	return, sa
 
	end
