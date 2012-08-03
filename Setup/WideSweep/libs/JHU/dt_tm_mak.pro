;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_MAK
; PURPOSE:
;       Set up a time and date string from reference JD and offset.
; CATEGORY:
; CALLING SEQUENCE:
;       s = dt_tm_mak(jd0, [sec])
; INPUTS:
;       jd0 = Julian Date of a reference date (0:00 hr).  in
;       sec = Seconds since JD0 at 0:00.                  in
; KEYWORD PARAMETERS:
;       Keywords:
;         NUMBERS=st Structure with numeric values, useful at times.
;         FORMAT = format string.  Allows output date to be customized.
;         The default format string is 'Y$ n$ d$ h$:m$:s$ w$'
;            The following substitutions take place in the format string:
;         Y$ = 4 digit year.
;         y$ = 2 digit year.
;         N$ = full month name.
;         n$ = 3 letter month name.
;         0n$= month as a 2 digit number: Jan=1, Feb=2, Dec=12.
;         d$ = day of month number.
;         0d$= 2 digit day of month number.
;         doy$= 3 digit day of year (see DDECIMAL below).
;         W$ = full weekday name.
;         w$ = 3 letter week day name.
;         0w$ = week day number: Sun=1, Mon=2, ... Sat=7.
;         h$ = hour.
;         m$ = minute.
;         s$ = second.
;         f$ = fraction of second (see DECIMAL, DENOMINATOR below).
;         I$ = time interval in days to 2 decimal places.
;         i$ = time interval in days as an integer.
;           I$ and i$ apply to sec in dt_tm_mak only.
;         H$ = time interval in integer hours.
;         sam$ = Time in seconds after midnight (DECIMAL works here).
;         @  = Carriage Return.
;         !  = Line feed.
;        DECIMAL=dp  Number of decimal places to use for fraction of
;          second (def=3) for f$ in format.  f$ will include dec pt.
;          Also applies to fraction shown in sam$.
;        DENOMINATOR=den If given then fraction is listed as nnn/ddd
;          ddd is given by den.  Over-rides DECIMAL keyword.  Ex:
;          DENOM=1000 might give 087/1000 for f$ in format.
;        DDECIMAL=ddp Num of dec places in Day of Year (def=none).
; OUTPUTS:
;       s = resulting string.                             out
; COMMON BLOCKS:
; NOTES:
;       Notes: Some examples: 'h$:m$:s$' -> 09:12:04,
;         'd$ n$ Y$' -> 12 Jan 1991, 'd$D h$h' -> 3D 2h, ...
; MODIFICATION HISTORY:
;       R. Sterner.  17 Nov, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES  20 Apr, 1989 --- 2 digit year.
;       R. Sterner, 26 Feb, 1991 --- Renamed from time_date_str.pro
;       R. Sterner, 27 Feb, 1991 --- Renamed from tm_dt_str.pro
;       R. Sterner, 28 Feb, 1991 --- changed format.
;       R. Sterner, 17 Jun, 1992 --- fixed a bug for large sec.
;       R. Sterner, 27 Sep, 1993 --- Modified to handle arrays.
;       R. Sterner,  2 Dec, 1993 --- Slightly modified def format.
;       R. Sterner, 1994 Jun 15 --- Added fraction of second.
;       R. Sterner, 1995 Mar  8 --- Added i$ format.
;       R. Sterner, 1995 Jul  6 --- Added 0d$ format.
;       R. Sterner, 1997 Feb  3 --- Added new keywords 0n$ and doy$ to
;       give month as 2 digit number and day of year.
;       Matthew Savoie, Systems Technology Associates --- 1997 Feb 5
;       fixed a bug by adding floor to: days = long(floor(idays)).
;       R. Sterner, 1997 Dec 18 --- Added DDECIMAL=ddec for number of
;       decimal places in Day of Year.
;       R. Sterner, 1998 Apr 14 --- added sam$ format.
;       R. Sterner, 1998 Apr 15 --- Added returned numeric structure.
;       R. Sterner, 1998 May 21 --- Fixed a bug found by Dave Watts and
;       Damian Murphy that caused a lost second sometimes.
;       R. Sterner, 1998 Jul 15 --- A bug was fixed by Tami Kovalick,
;       Raytheon STX, 2 digit years failed beyond 1999.
;       R. Sterner, 1998 Aug 10 --- Fixed a bug in the way structures are
;       indexed for single values.
;       R. Sterner, 2000 Jan 03 --- Fixed a problem that came up when year
;       ended in 0.  Might even be a touch faster.
;       R. Sterner, 2007 Jan 04 --- Made for loop indices long.  Reported
;       by David Sahnow <sahnow@jhu.edu> 29 Dec 2006.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;-------------------------------------------------------------
;	Routine to substitute values for format codes.
;-------------------------------------------------------------
 
	pro dt_tm_mak_sub, fmt, txt, code, sub
 
	p = -1				; Format search start.
	len = 1				; Code length.
	pt = 0				; Search start in text.
 
	;-------  Loop through format looking for code occurances  -----
	repeat begin
	  p = p + len			; Next search.
	  p = strpos(fmt,code,p)	; Look for code in format.
	  ;-----  Deal with code occurance in format  ----------
	  if p ge 0 then begin		; Yes, update text.
	    pt = strpos(txt,code,pt)	; Look for same code in text.
	    if pt lt 0 then return	; No such code in text.
	    len = strlen(code)		; Length of code.
	    if pt gt 0 then begin	; Grab front of text if any.
	      frnt = strmid(txt,0,pt) 
	    endif else begin
	      frnt = ''
	    endelse
	    bck = strmid(txt,pt+len,9999) ; Grab back of text.
	    txt = frnt + sub + bck	; Text with substitution.
	    pt = pt + strlen(sub)	; Next txt search start.
	  endif
	  ;-----------------------------------------------------
	endrep until p lt 0
	;-------  End of loop through format  ----------------------------
 
	end
 
 
;-------------------------------------------------------------
;	Main routine.
;-------------------------------------------------------------
 
	function dt_tm_mak, jd0, sec, format=frmt, decimal=dec, $
	  denominator=den, ddecimal=ddec, numbers=st, help=hlp
 
	if (n_params(0) lt 1) or (keyword_set(hlp)) then begin
	  print,' Set up a time and date string from reference JD and offset.'
	  print,' s = dt_tm_mak(jd0, [sec])'
	  print,'   jd0 = Julian Date of a reference date (0:00 hr).  in'
	  print,'   sec = Seconds since JD0 at 0:00.                  in'
	  print,'   s = resulting string.                             out'
          print,' Keywords:'
	  print,'   NUMBERS=st Structure with numeric values, useful at times.'
          print,'   FORMAT = format string.  Allows output date to be '+$
            'customized.'
          print,"   The default format string is 'Y$ n$ d$ h$:m$:s$ w$'"
          print,'      The following substitutions take place in the '+$
            'format string:'
          print,'   Y$ = 4 digit year.'
          print,'   y$ = 2 digit year.'
          print,'   N$ = full month name.'
          print,'   n$ = 3 letter month name.'
          print,'   0n$= month as a 2 digit number: Jan=1, Feb=2, Dec=12.'
          print,'   d$ = day of month number.'
          print,'   0d$= 2 digit day of month number.'
	  print,'   doy$= 3 digit day of year (see DDECIMAL below).'
          print,'   W$ = full weekday name.'
          print,'   w$ = 3 letter week day name.'
          print,'   0w$ = week day number: Sun=1, Mon=2, ... Sat=7.'
	  print,'   h$ = hour.'
	  print,'   m$ = minute.'
	  print,'   s$ = second.'
	  print,'   f$ = fraction of second (see DECIMAL, DENOMINATOR below).'
	  print,'   I$ = time interval in days to 2 decimal places.'
	  print,'   i$ = time interval in days as an integer.'
	  print,'     I$ and i$ apply to sec in dt_tm_mak only.'
	  print,'   H$ = time interval in integer hours.'
	  print,'   sam$ = Time in seconds after midnight (DECIMAL works here).'
	  print,'   @  = Carriage Return.'
	  print,'   !  = Line feed.'
	  print,'  DECIMAL=dp  Number of decimal places to use for fraction of'
	  print,'    second (def=3) for f$ in format.  f$ will include dec pt.'
	  print,'    Also applies to fraction shown in sam$.'
	  print,'  DENOMINATOR=den If given then fraction is listed as nnn/ddd'
	  print,'    ddd is given by den.  Over-rides DECIMAL keyword.  Ex:'
	  print,'    DENOM=1000 might give 087/1000 for f$ in format.'
          print,'  DDECIMAL=ddp Num of dec places in Day of Year (def=none).'
	  print," Notes: Some examples: 'h$:m$:s$' -> 09:12:04,"
	  print,"   'd$ n$ Y$' -> 12 Jan 1991, 'd$D h$h' -> 3D 2h, ..."
	  return, -1
	endif
 
	if n_params(0) lt 2 then sec = 0.	; Default seconds are 0.
	num = n_elements(sec)			; Number of strings to make.
 
	;-----  Set up output structure with numeric values  --------
	st = make_array(num,val={year:0,month:0,day:0,hour:0,minute:0,$
	  second:0d0,day_of_year:0d0,sec_after_midnight:0d0,weekday:0, $
	  JD:0L})
	in = 0					; Subscript, only needed
	if num gt 1 then in=lindgen(num)	; for scalar values.
	numj = n_elements(jd0)			; May have different # elem.
	inj = 0
	if numj gt 1 then inj=lindgen(numj)
 
        ;-----  format string  ------
        fmt = 'Y$ n$ d$ h$:m$:s$ w$'		; Default format.
        if keyword_set(frmt) then fmt = frmt	; Use given format.
 
        ;-----  Get all the allowed parts  -----
	idays = sec/86400d0			; Seconds to interval in days
	days = long(floor(idays))		; Interval to integer days
	rem = sec - days*86400d0		;   and left over seconds.
	st(*).sec_after_midnight = rem(in)	; Save value.
	sam = strtrim(long(rem),2)		; Seconds after midnight.
	if n_elements(dec) eq 0 then dec=0	; Default for sec is integer.
	if dec gt 0 then begin                  ; If sam fraction requested.
	  samfrm = '(F'+strtrim(2+dec,2)+'.'+strtrim(dec,2)+')'
	  samfrac = string(pmod(rem,1.d0),form=samfrm)  ; Frac of sec.
	  sam = sam + strmid(samfrac,1,99)      ; Concatenate on fraction.
	endif
	jd2ymd, jd0+days, y, m, d		; Find Yr, Mon, Day.
	st(*).jd = jd0(inj)+days(in)		; Save value.
	st(*).year=y(in) & st(*).month=m(in) & st(*).day=d(in)	; Save values.
	if n_elements(ddec) eq 0 then ddec=0	; Default for doy is integer.
	tmp = ymd2dn(y,m,d)			; Day of year.
	st(*).day_of_year = tmp(in) + rem(in)/86400d0	; Save value.
	doy = string(tmp,form='(I3.3)')  ; Day of year.
	if ddec gt 0 then begin			; If DOY fraction requested.
	  doyfrm = '(F'+strtrim(2+ddec,2)+'.'+strtrim(ddec,2)+')'
	  doyfrac = string(sec/86400d0,form=doyfrm)	; Find fraction of day.
	  doy = doy + strmid(doyfrac,1,99)	; Concatenate on fraction.
	endif
        yu = strtrim(y,2)			; 4 Digit year.
;-------------------------------------------------------------------------
;	Tami Kovalick, Raytheon STX fixed the following since it doesn't work
;	for years past 1999.  July 13, 1998
;       yl = strtrim(fix(y-100*fix(y/100)),2)	; 2 digit year.
;-------------------------------------------------------------------------
	yl = strmid(strtrim(y,2),2,2)     ;get the last two digits of the yr.
        mnames = monthnames()			; List of names.
        mu = mnames(m)				; Long month name.
        ml = strmid(mu,0,3)			; 3 letter month name.
	mn = string(m,form='(I2.2)')		; Month as a 2-digit number.
        dl = strtrim(d,2)			; Day of month.
	dl0 = dl				;   Leading 0 form.
	w = where(d lt 10, cnt)			; Look for day<10.
	if cnt gt 0 then begin
	  dl(w)=' '+dl(w)			;   Leading space form.
	  dl0(w) = '0'+dl0(w)			;   Leading 0 form.
	endif
        wu = weekday(y,m,d,nwd)			; Long weekday name.
	tnwd = strtrim(nwd,2)			; Weekday number as a string.
        wl = strmid(wu,0,3)			; 3 letter weekday name.
	st(*).weekday = nwd(in)			; Save value.
 
	sechms, rem, h, m, s, hh, mm, ss, frac=frac	; Find Hr, Min, Sec.
	st(*).hour=h(in) & st(*).minute=m(in) & st(*).second=s(in); Save values.
	ii = strtrim(string(idays,format='(f20.2)'),2)
	ii2 = strtrim(days,2)
	hh2 = string(idays*24.,format='(I0)')
 
	;-------  Handle fraction of second  ---------
;	frac = s - floor(s)
	if keyword_set(den) then begin		; nnn/ddd
	  wid = strtrim(ceil(alog10(den)),2)
	  dn = strtrim(den,2)
	  fm2 = '(I'+wid+'.'+wid+')'
	endif else begin			; .fff
	  dp = 3
	  if dec gt 0 then dp = dec
	  fm1 = '(f'+strtrim(dp+2,2)+'.'+strtrim(dp,2)+')'
	endelse
	ff = strarr(num)
	for i = 0L, num-1 do begin
	  if keyword_set(den) then begin
	    ff(i) = string(den*frac(i),form=fm2)+'/'+dn    ; Add denominator.
	  endif else begin
	    ff(i) = strmid(string(frac(i),form=fm1),1,99)  ; Keep dec. point.
	  endelse
	endfor
 
	;------  Replacements  -------
	out = strarr(num)
	for i = 0L, num-1 do begin
	  tmp = fmt
	  dt_tm_mak_sub, fmt, tmp, '0n$',mn(i)   ; Month as 2-digit number.
	  dt_tm_mak_sub, fmt, tmp, 'n$', ml(i)   ; 3 letter month name.
	  dt_tm_mak_sub, fmt, tmp, 'I$', ii(i)   ; Interval in days (2 dp).
	  dt_tm_mak_sub, fmt, tmp, 'i$', ii2(i)  ; Interval in days (int).
	  dt_tm_mak_sub, fmt, tmp, 'H$', hh2(i)  ; Interval in integer hours.
	  dt_tm_mak_sub, fmt, tmp, 'sam$',sam(i) ; Seconds after midnight.
	  dt_tm_mak_sub, fmt, tmp, 'doy$',doy(i) ; 3 digit day of year.
	  dt_tm_mak_sub, fmt, tmp, 'Y$', yu(i)   ; 4 digit year.
	  dt_tm_mak_sub, fmt, tmp, 'y$', yl(i)   ; 2 digit year.
	  dt_tm_mak_sub, fmt, tmp, 'N$', mu(i)   ; Long month name.
	  dt_tm_mak_sub, fmt, tmp, 'W$', wu(i)   ; Long weekday name.
	  dt_tm_mak_sub, fmt, tmp, '0w$',tnwd(i) ; Weekday number (1-7).
	  dt_tm_mak_sub, fmt, tmp, 'w$', wl(i)   ; 3 letter weekday name.
	  dt_tm_mak_sub, fmt, tmp, '0d$',dl0(i)  ; Day of month (leading 0).
	  dt_tm_mak_sub, fmt, tmp, 'd$', dl(i)   ; Day of month.
	  dt_tm_mak_sub, fmt, tmp, 'h$', hh(i)   ; Hour.
	  dt_tm_mak_sub, fmt, tmp, 'm$', mm(i)   ; Minute.
	  dt_tm_mak_sub, fmt, tmp, 's$', ss(i)   ; Second.
	  dt_tm_mak_sub, fmt, tmp, 'f$', ff(i)   ; Fraction of second.
	  tmp = repchr(tmp, '@', string(13B))	   ; <CR>
	  tmp = repchr(tmp, '!', string(10B))	   ; <LF>
	  out(i) = tmp
	endfor
 
	if n_elements(out) eq 1 then return, out(0)
	return, out
	end
