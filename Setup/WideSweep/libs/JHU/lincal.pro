;-------------------------------------------------------------
;+
; NAME:
;       LINCAL
; PURPOSE:
;       Plot a multimonth linear calendar on one page.
; CATEGORY:
; CALLING SEQUENCE:
;       lincal, dates
; INPUTS:
;       dates = string array of dates.   in
;         Ex: dates=['dec 1995','jan 1996','feb 1996']
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=title  Optional main title.
;         /HARD        Make hard copy.
;         /NODAYS      Suppress day of the week.
;         CHARSIZE=csz Character size (def=1).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Nov 20
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro lincal, dates, hard=hard, title=title, nodays=nodays, $
	  charsize=charsize, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot a multimonth linear calendar on one page.'
	  print,' lincal, dates'
	  print,'   dates = string array of dates.   in'
	  print,"     Ex: dates=['dec 1995','jan 1996','feb 1996']"
	  print,' Keywords:'
	  print,'   TITLE=title  Optional main title.'
	  print,'   /HARD        Make hard copy.'
	  print,'   /NODAYS      Suppress day of the week.'
	  print,'   CHARSIZE=csz Character size (def=1).'
	  return
	endif
 
	if n_elements(charsize) eq 0 then charsize=1.
	n = n_elements(dates)		; List of months to display.
	chinit, hard=hard
 
	if n_elements(title) ne 0 then $
	  xyouts,/norm,.5,.96,chars=1.5,title,align=.5
	dx = .8/n			; Month width.
	dy = .8/31			; Day height.
	x0 = .1
	y0 = .9
	chy = !d.y_ch_size*charsize/float(!d.y_size)
	chx = !d.x_ch_size*charsize/float(!d.x_size)
	wd = [' S',' M',' T',' W',' T',' F',' S']	; Week days.
	fnt = ''
	if keyword_set(nodays) then wd=['','','','','','','']
	if (not keyword_set(nodays)) and keyword_set(hard) then begin
	  device,/courier,/bold		; Set to courier
	endif
 
	for i=0,n-1 do begin		; Loop through months.
	  xx0 = x0+i*dx
	  txt = getwrd(dates(i))+'!C'+getwrd('',1)
	  xyouts,xx0+dx/2.,y0+1.5*chy,/norm,align=.5,upcase1(txt)
	  dt = dates(i)+' 1'		; Pick off date (add day).
	  date2ymd,dt,y,m,d		; Find year and month.
	  days = monthdays(y,m)		; Number of days in month.
	  wday = weekday(y,m,d,nwd)  ; Weekday number.
	  nwd = nwd-2
	  plots,/norm,[xx0,xx0+dx,xx0+dx,xx0,xx0],$
		[y0,y0,y0-days*dy,y0-days*dy,y0]
	  for j=1,days do begin		; Loop through days.
	    plots,/norm,[xx0,xx0+dx],[y0,y0]-j*dy
	    xyouts,/norm,xx0+dx-.2*chx,y0-j*dy+.3*chy,$
	      strtrim(j,2)+wd((j+nwd) mod 7),align=1.,chars=charsize
	  endfor
	endfor
 
	plots,/norm,[x0,x0+dx*n+dx,x0+dx*n+dx,x0,x0]<.995,$
	  [y0,y0,y0-dy,y0-dy,y0]-33*dy
	for i=1,n+1 do begin		; Month totals.
	  xx0 = (x0+i*dx)<.995
	  plots,/norm,[xx0,xx0],[y0,y0-dy]-33*dy
	endfor
 
	if keyword_set(hard) then psterm
 
	return
	end
