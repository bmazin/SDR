;-------------------------------------------------------------
;+
; NAME:
;       WEBCALTAB
; PURPOSE:
;       Generate HTML table code for a calendar.
; CATEGORY:
; CALLING SEQUENCE:
;       webcaltab, mon, yr
; INPUTS:
;       mon = optional month number (def=current).           in
;       yr = optional year (def=year giving nearest month).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=ttl  optional calendar title (short, def=none).
;         CODE=code  Returned HTML table code in text array.
;         LINKS=lnks Text array of Hyperlinks (one per day).
;         STATUS=stat Text array with status images (one per day).
;           Intended for small vertical image aligned on left.
;         BORDER=brd Table border thickness (def=10).
;         FSIZE=fsz  Font size (like 4, +1, ..., def=0).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: If no year is given a default year will be used.
;         The default will be selected to give the nearest calendar.
;         For example: If in Dec a Jan calendar is requested the
;         default year will be next year.  Nov will give current
;         year.
;              LINKS and STATUS are arrays with one more element
;         than days for requested month.  Null entries in this array
;         are ignored.  Array index is month day so element 0 not
;         used.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 May 1
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro webcaltab, mon, yr, links=lnks, status=stat, code=code, $
	  border=border, fsize=fsize, title=ttl, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Generate HTML table code for a calendar.'
	  print,' webcaltab, mon, yr'
	  print,'   mon = optional month number (def=current).           in'
	  print,'   yr = optional year (def=year giving nearest month).  in'
	  print,' Keywords:'
	  print,'   TITLE=ttl  optional calendar title (short, def=none).'
	  print,'   CODE=code  Returned HTML table code in text array.'
	  print,'   LINKS=lnks Text array of Hyperlinks (one per day).'
	  print,'   STATUS=stat Text array with status images (one per day).'
	  print,'     Intended for small vertical image aligned on left.'
	  print,'   BORDER=brd Table border thickness (def=10).'
	  print,'   FSIZE=fsz  Font size (like 4, +1, ..., def=0).'
	  print,' Notes: If no year is given a default year will be used.'
	  print,'   The default will be selected to give the nearest calendar.'
	  print,'   For example: If in Dec a Jan calendar is requested the'
	  print,'   default year will be next year.  Nov will give current'
	  print,'   year.'
	  print,'        LINKS and STATUS are arrays with one more element'
	  print,'   than days for requested month.  Null entries in this array'
	  print,'   are ignored.  Array index is month day so element 0 not'
	  print,'   used.'
	  return
	endif
 
	;-----  Set defaults  -----
	if n_elements(border) eq 0 then border=10
	if n_elements(ttl) eq 0 then ttl=''
	btxt = ' border='+strtrim(border,2)
	if n_elements(fsize) eq 0 then fsize=0
	ftxt = '<font size='+strtrim(fsize,2)+'>'
	ftxt2 = '</font>'
	js2ymds,dt_tm_tojs(systime()),y,m,d	; Find current yr,mon,day.
	if n_elements(mon) eq 0 then mon=m	; Use current month as default.
	if n_elements(yr) eq 0 then begin	; Find default year.
	  jdnow = ymd2jd(y,m,d)			; Today's JD number.
	  ytst = y+[-1,0,1]			; Years to test.
	  jdtst = ymd2jd(ytst,mon,1)		; Test JD numbers.
	  diff = abs(jdtst-jdnow)		; Time from now (fore or back).
	  w = (where(diff eq min(diff)))(0)	; Find closest month to now.
	  yr = ytst(w)
	endif
 
	;------  Find info for calendar  --------------
	wd = weekday(yr, mon, 1, md)		; Find weekday of 1st of month.
	days = monthdays(yr, mon)		; Days in month.
	rows = ceil((days+md-1)/7.)		; Rows in calendar.
	mnam = monthnames()			; Array of month names.
	tt = mnam(mon)+' '+strtrim(yr,2)+ttl	; Calendar Title.
	;------  Deal with links  ---------
	if n_elements(lnks) eq 0 then lnks=strarr(days+1)	; Define lnks.
	ltxt = strarr(days+1)			; Link opening text.
	ltxt2 = ltxt				; Link closing text.
	w = where(lnks ne '', cnt)		; Find all links.
	if cnt gt 0 then begin			; Any?
	  ltxt(w)='<a href="'+lnks(w)+'">'	; Yes.
	  ltxt2(w)='</a>'
	endif
	;------  Deal with status image  ---------
	if n_elements(stat) eq 0 then stat=strarr(days+1)	; Define stat.
	stxt = strarr(days+1)			; Status image text.
	w = where(stat ne '', cnt)		; Find all status images.
	if cnt gt 0 then begin			; Any?
	  stxt(w)='<img src="'+stat(w)+'" align=left>'	; Yes.
	endif
	;-----  Check links and status arrays  ------
	if n_elements(lnks) lt (days+1) then begin
	  bell
	  print,' Fatal error in webtabcal: Given LINKS array has to few'
	  print,'   entries. Must have '+strtrim(days+1,2)+' for '+tt
	  stop
	endif
	if n_elements(stat) lt (days+1) then begin
	  bell
	  print,' Fatal error in webtabcal: Given STATUS array has to few'
	  print,'   entries. Must have '+strtrim(days+1,2)+' for '+tt
	  stop
	endif
 
	;------  Generate HTML Table code  ------------
	;------  Front end  --------
	code = ['<table'+btxt+'>']		; Start table.
	code = [code,'<tr><th colspan=7>'+$
	  ftxt+tt+ftxt2+'</th></tr>']		; Title.
	txt = '<tr>'
	for i=0,6 do txt=txt+$
	  '<td>'+ftxt+(['Sun','Mon','Tue','Wed','Thu','Fri','Sat'])(i)+$
	  ftxt2+'</td>'
	txt = txt+'</tr>'
	code = [code,txt,'<!--- Week 1 --->']
	txt = '<tr align=right>'		; Start first row.
	if md gt 1 then begin			; Deal with blank cells.
	  for i=1,md-1 do txt = txt+'<td></td>'
	endif
	code = [code,txt]			; Add any blank days to code.
	;------  Loop through days of month  -----
	wk = 1
	ix = md					; Column counter.
	for id=1, days do begin			; Loop through month days.
	  txt = ''				; Start day code.
	  if ix mod 7 eq 1 then begin		; New week.
	    wk = wk+1				; Week counter (for comment).
	    code = [code,'<!--- Week '+strtrim(wk,2)+' --->']
	    txt='<tr align=right>'	; Start new table row.
	  endif else txt = '    '
	  dtxt = strtrim(id,2)			; Month day as text.
	  txt = txt+'<td>'+stxt(id)+ftxt+ltxt(id)+dtxt+$  ; Table Cell.
	    ltxt2(id)+ftxt2+'</td>'
	  if ix mod 7 eq 0 then txt=txt+'</tr>'	; Table row done.
	  code = [code,txt]
	  ix = ix+1
	endfor
	;------  Finish up  ---------
	code = [code,'</tr></table>']
 
	return
	end
