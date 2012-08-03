;-------------------------------------------------------------
;+
; NAME:
;       JD2YMD
; PURPOSE:
;       Find year, month, day from julian day number.
; CATEGORY:
; CALLING SEQUENCE:
;       jd2ymd, jd, y, m, d
; INPUTS:
;       jd = Julian day number (like 2447000).     in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       y = year (like 1987).                      out
;       m = month number (like 7).                 out
;       d = day of month (like 23).                out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  21 Aug, 1986.
;       Johns Hopkins Applied Physics Lab.
;       RES 18 Sep, 1989 --- converted to SUN
;       R. Sterner, 30 Apr, 1993 --- cleaned up and allowed arrays.
;       Theo Brauers, 21 Sep, 1997 long loop index i
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
    pro jd2ymd, jdd, y, m, d, help=hlp
 
    if (n_params(0) lt 4) or keyword_set(hlp) then begin
      print,' Find year, month, day from julian day number.'
      print,' jd2ymd, jd, y, m, d'
      print,'   jd = Julian day number (like 2447000).     in'
      print,'   y = year (like 1987).                      out'
      print,'   m = month number (like 7).                 out'
      print,'   d = day of month (like 23).                out'
      return
    endif
 
    jd = long(jdd)              ; Force long.
    y = fix((jd - 1721029)/365.25)      ; Estimated year.
    jd0 = ymd2jd(y, 1, 0)           ; JD for day 0.
    days = jd - jd0             ; Day of year.
    w = where(days le 0, cnt)       ; Find where year is wrong.
    if cnt gt 0 then begin
      y(w) = y(w) - 1           ; Year was off by 1.
      jd0(w) = ymd2jd( y(w), 1, 0)      ; New JD for day 0.
      days(w) = jd(w) - jd0(w)      ; New day of year.
    endif
 
    ;---  Correct for leap-years.  -----
    ly = (((y mod 4) eq 0) and ((y mod 100) ne 0)) $
            or ((y mod 400) eq 0)
 
    ;---  Days before start of each month.  -----
    ydays = [0,0,31,59,90,120,151,181,212,243,273,304,334,366]
    off   = [0,0, 0, 1, 1,  1,  1,  1,  1,  1,  1,  1,  1,  1]
 
    ;----------------  Find which month.  --------------------------
    ;     Algorithm: ydays has cumulative # days up to start of each month
    ;     (13 elements so month number may be used as an index).
    ;     This number needs 1 added for Mar to Dec if it is a leap year.
    ;     This is done by adding the offset, off, times the leap year flag.
    ;     The larger the day of year (days) the fewer elements of this
    ;     corrected ydays array will be greater than days.  The
    ;     entries in the corrected ydays gt days are located by where and
    ;     counted by n_elements.  Ydays has 13 elements so subtract result
    ;     from 13 to get month number.
    ;---------------------------------------------------------------
    njd = n_elements(jd)    ; # of JDs to convert.
    m = intarr(njd)     ; Set up storage for months.
    d = intarr(njd)     ; Set up storage for day of month.
    ; T.B.  i=0L  (was i=0)
    for i = 0L, njd-1 do begin   ; Loop through each JD.
      ydays2 = ydays+ly(i)*off  ; Correct cumulative days for year.
      dy = days(i)          ; Days into year for i'th JD.
      mn = 13-n_elements(where(dy le ydays2))  ; i'th month number.
      m(i) = mn         ; Store month.
      d(i) = fix(dy - ydays2(mn))   ; Find and store i'th day of month.
    endfor
 
    ;---------  Make sure scalars are returned as scalars  -------
    if n_elements(m) eq 1 then begin
      m = m(0)
      d = d(0)
    endif
 
    return
    end
