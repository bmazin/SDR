;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_BRK
; PURPOSE:
;       Break a date and time string into separate date and time.
; CATEGORY:
; CALLING SEQUENCE:
;       dt_tm_brk, txt, date, time
; INPUTS:
;       txt = Input date and time string.               in
;         May be an array.
; KEYWORD PARAMETERS:
;       Keywords:
;         FORMAT=fmt Specify format of input.
;           Use the letters y,n,d to in the same positions as year,
;           month, and day in the input string, and the letters h, m,
;           and s for hour, minute, second.  Any other characters may
;           be used as place holders. Case is ignored. For example:
;           for txt='gs_06oct09_0208_multi.png' use
;           fmt='xx_yynndd_hhmm_xxxxx.xxx'
;           If s and/or m are not used they default to 0.
;           Trailing placeholders are not really needed.
;           All input strings must have the same format to use this.
;         DATE_FORMAT=d Returned date format. This will be a
;           structure with {yymmmdd:k,ddmmmyy:1-k} where k is  1 for
;           /YYMMMDD date format.  Intended for use with date2ymd:
;           date2ymd,date,y,m,d,yymmmdd=d.yymmmdd, ddmmmyy=d.ddmmmyy
; OUTPUTS:
;       date = returned date string, null if no date.   out
;       time = returned time string, null if no time.   out
; COMMON BLOCKS:
; NOTES:
;       Note: works for systime: dt_tm_brk, systime(), dt, tm
;         The word NOW (case insensitive) is replaced
;         by the current sysem time.
; MODIFICATION HISTORY:
;       R. Sterner. 21 Nov, 1988.
;       RES 18 Sep, 1989 --- converted to SUN.
;       R. Sterner, 26 Feb, 1991 --- renamed from brk_date_time.pro
;       R. Sterner, 26 Feb, 1991 --- renamed from brk_dt_tm.pro
;       R. Sterner, 1994 Mar 29 --- Allowed arrays.
;       R. Sterner, 2006 Nov 09 --- Added FORMAT=fmt, DATE_FORMAT=dfmt.
;       R. Sterner, 2007 Jan 04 --- Made for loop index long.
;       R. Sterner, 2007 Jul 17 --- Now works if format has no time (hh:mm:ss).
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro dt_tm_brk, txt, dt, tm, help=hlp, format=fmt0, date_format=dfmt
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Break a date and time string into separate date and time.'
	  print,' dt_tm_brk, txt, date, time'
	  print,'   txt = Input date and time string.               in'
	  print,'     May be an array.'
	  print,'   date = returned date string, null if no date.   out'
	  print,'   time = returned time string, null if no time.   out'
	  print,' Keywords:'
	  print,'   FORMAT=fmt Specify format of input.'
	  print,'     Use the letters y,n,d to in the same positions as year,'
	  print,'     month, and day in the input string, and the letters h, m,'
	  print,'     and s for hour, minute, second.  Any other characters may'
	  print,'     be used as place holders. Case is ignored. For example:'
	  print,"     for txt='gs_06oct09_0208_multi.png' use"
	  print,"     fmt='xx_yynndd_hhmm_xxxxx.xxx'"
	  print,'     If s and/or m are not used they default to 0.'
	  print,'     Trailing placeholders are not really needed.'
	  print,'     All input strings must have the same format to use this.'
	  print,'   DATE_FORMAT=d Returned date format. This will be a'
	  print,'     structure with {yymmmdd:k,ddmmmyy:1-k} where k is  1 for'
	  print,'     /YYMMMDD date format.  Intended for use with date2ymd:'
	  print,'     date2ymd,date,y,m,d,yymmmdd=d.yymmmdd, ddmmmyy=d.ddmmmyy'
	  print,' Note: works for systime: dt_tm_brk, systime(), dt, tm'
	  print,'   The word NOW (case insensitive) is replaced'
	  print,'   by the current sysem time.'
	  return
	endif
 
	n = n_elements(txt)
 
	;----  Format case  -----
	if n_elements(fmt0) gt 0 then begin
	  fmt = strupcase(fmt0)
 
	  ylo = strpos(fmt,'Y')			; Date: Year start.
	  yhi = strpos(fmt,'Y',/reverse_search)	; Year end.
	  nlo = strpos(fmt,'N')			; Month start.
	  nhi = strpos(fmt,'N',/reverse_search)	; Month end.
	  dlo = strpos(fmt,'D')			; Day start.
	  dhi = strpos(fmt,'D',/reverse_search)	; Day end.
	  dtlo = [ylo,nlo,dlo]			; List of possible date starts.
	  dtlo = min(dtlo[where(dtlo ge 0)])	; Find min where ne -1.
	  dthi = [yhi,nhi,dhi]			; List of possible date ends.
	  dthi = max(dthi[where(dthi ge 0)])	; Find max where ne -1.
	  dtlen = (dtlo ge 0)?dthi-dtlo+1:0
	  dt = strmid(txt,dtlo,dtlen)		; Pick off date.
	  if dtlo eq ylo then k1=1 else k1=0
	  if dtlo eq dlo then k2=1 else k2=0
	  dfmt = {yymmmdd:k1, ddmmmyy:k2}	; Format for date2ymd.
 
	  hlo = strpos(fmt,'H')			; Time: Hour start.
	  if hlo lt 0 then begin		; No time in format.
	    tm = strarr(n)+'00:00:00'		; Default to 0.
	    return
	  endif
	  hhi = strpos(fmt,'H',/reverse_search)
	  mlo = strpos(fmt,'M')
	  mhi = strpos(fmt,'M',/reverse_search)
	  slo = strpos(fmt,'S')
	  shi = strpos(fmt,'S',/reverse_search)
	  tmlo = [hlo,mlo,slo]
	  tmlo = min(tmlo[where(tmlo ge 0)])
	  tmhi = [hhi,mhi,shi]
	  tmhi = max(tmhi[where(tmhi ge 0)])
	  tmlen = (tmlo ge 0)?tmhi-tmlo+1:0
	  tm = strmid(txt,tmlo,tmlen)		; Pick off time.
 
	  return
	endif
 
	;----  No format  -------
	dt = strarr(n)
	tm = strarr(n)
	dfmt = {yymmmdd:0, ddmmmyy:0}		; Format for date2ymd.
 
	for j = 0L, n-1 do begin
	  tt = strupcase(txt(j))
	  if tt eq 'NOW' then tt = systime()
	  if tt ne '' then begin
	    flag = 0		; Items not found yet.
	    for i = 0, nwrds(tt)-1 do begin
	      if flag eq 0 then begin
	        tim = getwrd(tt, i)
	        if strpos(tim,':') gt -1 then begin
	          dat = strtrim(stress(tt, 'D', 1, tim),2)
	          tm(j) = tim
	    	  dt(j) = dat
		  flag = 1	; Found items.
	        endif
	      endif  ; flag
	    endfor  ; i
	    if flag eq 0 then dt(j) = tt
	  endif
	endfor  ; j
 
	if n eq 1 then begin	; Return scalars if given a scalar.
	  tm = tm(0)
	  dt = dt(0)
	endif
 
	return
 
	end
