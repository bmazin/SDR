;-------------------------------------------------------------
;+
; NAME:
;       EVENT_LOG
; PURPOSE:
;       Enter an event into the latest event log file.
; CATEGORY:
; CALLING SEQUENCE:
;       event_log, txt
; INPUTS:
;       txt = Short text string to enter into event log.   in
;         May also have multiple lines (Time tag will be on
;         the preceding line, same as /TWOLINE).
; KEYWORD PARAMETERS:
;       Keywords:
;         /TWOLINE  Use two lines: time and txt (def=one line).
;         /ADD means add given text to entry for last time tag.
;            Any number of additional lines may be added.
;         /SCREEN means also display given text on terminal screen.
;         /LIST means display current event log.
;         /FILE means display log file name.
;         GETFILE=evfile Return event log file name.
;         /NEW  means start a new event log.
;         SETFILE=file  Optionally specified event file name.
;         DIRECTORY=dir  Event log directory (def=current).
;         /DIFFERENCE gives time difference between last two entries.
;         /LOG Enter the time difference in log file (with /DIFF).
;         TAG=tag  Look for the first occurance of TAG in the last
;           line of the log file.  Return the matching word in VALUE.
;         VALUE=val First word in last log file line containing TAG.
;           Example: if last log line is:
;              DK processing complete: dk_191_1.res
;           and TAG='dk_' then VALUE returns 'dk_191_1.res'
;           TAG could also have been '.res' with same results.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: To have an event entered into the latest event
;         log just call with the desired event text.  If an event
;         log file does not exist one will be created.
;         To start a new event file just use the keyword /NEW.
;         The event file names are always of the form:
;           yymmmdd_hhmm.event_log like 95May15_1242.event_log
;           except when SETFILE=file is used to override this.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 May 15
;       R. Sterner, 1995 Jul 10 --- Added /DIFFERENCE keyword.
;       R. Sterner, 1995 Aug  7 --- Added SETFILE keyword.
;       R. Sterner, 2002 Aug 16 --- Made SETFILE work better.
;       R. Sterner, 2002 Dec 16 --- Fixed a dir problem in SETFILE.
;       R. Sterner, 2002 Dec 17 --- Made undefined dir be a null string.
;       R. Sterner, 2006 Apr 27 --- Added GETFILE=file.
;       R. Sterner, 2007 Aug 22 --- Made SETFILE work better.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	;----------------------------------------------------------------
	;  event_log_new = Start a new event log file
	;    dir=output directory, set=given name, file=returned name.
	;----------------------------------------------------------------
 
	pro event_log_new, dir=dir, setfile=set, file=file
 
	tm = systime()				; Current time.
	js = dt_tm_tojs(tm)			; Time in JS.
	file = dt_tm_fromjs(js,form='y$n$0d$_h$m$.event_log') ; Make filename.
	dir0 = ''				; Assume no dir in set.
	if n_elements(set) ne 0 then begin
	  filebreak, set, dir=dir0,ext=ext	; See if dir & extension given.
	  if ext eq '' then file=set+'.event_log'  ; No ext, add one.
	endif
	name = file
	if dir0 eq '' then name=filename(dir,file,/nosym)  ; No directory, add one.
	openw,lun,name,/get_lun			; Open new log file.
	printf,lun,'Event log started '+tm	; Write start time.
	close, lun				; Close log file.
	free_lun, lun				; Old code.
	file = name				; Return final name.
 
	return
	end
 
	;----------------------------------------------------------------
	;  event_log.pro = Enter an event into the latest event log file
	;----------------------------------------------------------------
 
	pro event_log, text, new=new, list=list, file=lfile, screen=screen, $
	  directory=dir, twoline=twoline, difference=diff, log=log, $
	  tag=tag, value=value, setfile=set, add=add, help=hlp, getfile=file
 
	if keyword_set(hlp) then begin
help:	  print,' Enter an event into the latest event log file.'
	  print,' event_log, txt'
	  print,'   txt = Short text string to enter into event log.   in'
	  print,'     May also have multiple lines (Time tag will be on'
	  print,'     the preceding line, same as /TWOLINE).'
	  print,' Keywords:'
	  print,'   /TWOLINE  Use two lines: time and txt (def=one line).'
	  print,'   /ADD means add given text to entry for last time tag.'
	  print,'      Any number of additional lines may be added.'
	  print,'   /SCREEN means also display given text on terminal screen.'
	  print,'   /LIST means display current event log.'
	  print,'   /FILE means display log file name.'
	  print,'   GETFILE=evfile Return event log file name.'
	  print,'   /NEW  means start a new event log.'
	  print,'   SETFILE=file  Optionally specified event file name.'
	  print,'   DIRECTORY=dir  Event log directory (def=current).'
	  print,'   /DIFFERENCE gives time difference between last two entries.'
	  print,'   /LOG Enter the time difference in log file (with /DIFF).'
	  print,'   TAG=tag  Look for the first occurance of TAG in the last'
	  print,'     line of the log file.  Return the matching word in VALUE.'
	  print,'   VALUE=val First word in last log file line containing TAG.'
	  print,'     Example: if last log line is:'
	  print,'        DK processing complete: dk_191_1.res'
	  print,"     and TAG='dk_' then VALUE returns 'dk_191_1.res'"
	  print,"     TAG could also have been '.res' with same results."
	  print,' Notes: To have an event entered into the latest event'
	  print,'   log just call with the desired event text.  If an event'
	  print,'   log file does not exist one will be created.'
	  print,'   To start a new event file just use the keyword /NEW.'
	  print,'   The event file names are always of the form:'
	  print,'     yymmmdd_hhmm.event_log like 95May15_1242.event_log'
	  print,'     except when SETFILE=file is used to override this.'
	  return
	endif
 
	time = systime()			; Get current time.
 
	if n_elements(dir) eq 0 then cd,curr=dir  ; Default to current directory.
 
	;-----  New log requested  -----------------
	if keyword_set(new) then event_log_new, dir=dir, setfile=set, file=file
 
	;------  Find latest event log file  -------
	if n_elements(set) gt 0 then begin	; Given event file name.
	  filebreak, set, dir=dir0, ext=ext	; See if dir & extension given.
	  name = set
	  if ext eq '' then name=set+'.event_log' ; No ext, add one.
	  file = name
	  if dir0 eq '' then file=filename(dir,name,/nosym) ; No directory, add one.
	  f = findfile(file,count=nf)		; Check if exists.
	  if nf eq 0 then begin			; No.
	    event_log_new, dir=dir, setfile=set	; Start it.
	  endif
	endif else begin			; Find event file name.
	  wild = filename(dir,'*.event_log',/nosym)
	  f = findfile(wild,count=nf)		; List of all *.event_log files.
	  if nf eq 0 then begin			; No current log files.
	    event_log_new, dir=dir		; Start one.
	    f = findfile(wild,count=nf)		; Find it.
	  endif
	  ff = strarr(nf)			; Array for filenames.
	  for i=0,nf-1 do begin			; Loop through event log files.
	    filebreak,f(i),name=tmp		; Grab just the name.
	    if isnumber(strmid(tmp,0,2)) then ff(i)=tmp ; Save name if not ''.
	  endfor
	  w = where(ff ne '', cnt)		; Look for non-null names.
	  if cnt gt 0 then begin		; Found some.
	    ff = ff(w)				; Keep only non-null names.
	    yr = strmid(ff,0,2)			; Deal with 2 digit year.
	    yr2 = yy2yyyy(yr)			; Convert to 4 digit years.
	    tm = yr2+' '+strmid(ff,2,3)+' '+strmid(ff,5,2)+' '+$  ; Form date.
	       strmid(ff,8,2)+':'+strmid(ff,10,2)
	    js = dt_tm_tojs(tm)			; Convert dates to JS.
	    w = where(js eq max(js))		; Find latest file.
	    file = f(w(0))			; Get its name.
	  endif else begin
	    event_log_new, dir=dir, file=file	; Need a new event log.
	  endelse
	endelse
 
	;-------  Display log file name  --------
	if keyword_set(lfile) then print,' Event log file: '+file
 
	;-------  Add new log entry (if text given) -----------
	if n_elements(text) ne 0 then begin
	  ntxt = n_elements(text)		; Lines in text.
	  if ntxt gt 1 then twoline=1		; Automatic multiline entry.
	  if keyword_set(screen) then begin	; Display text on screen.
	    for i=0,ntxt-1 do print,' '+text(i)
	  endif
	  openu,lun,file,/append,/get_lun	; Open log file.
	  if keyword_set(add) then begin	; Add a line (no time tag).
	    for i=0,ntxt-1 do printf,lun,'  '+text(i) ;   Write added entry.
	  endif else begin			; Normal 1 or 2 line log entry.
	    if keyword_set(twoline) then begin		; Two line format.
	      printf,lun,time				;   Write time.
	      for i=0,ntxt-1 do printf,lun,'  '+text(i)	;   Write entry.
	    endif else begin				; One line format.
	      printf,lun,time+' --- '+text		;   Write time & entry.
	    endelse
	  endelse
	  close, lun
	  free_lun, lun
	endif
 
	;------  List  ----------
	if keyword_set(list) then begin
	  txt = getfile(file)
	  more,txt
	endif
 
	;------  Difference  ----------
	if keyword_set(diff) then begin
	  txt = getfile(file)
	  one = strmid(txt,0,1)
	  w = where(one ne ' ', cnt)
	  if cnt eq 0 then return
	  txt = txt(w)
	  n = n_elements(txt)
	  t1 = dt_tm_tojs(strmid(txt(n-2),0,24))
	  t2 = dt_tm_tojs(strmid(txt(n-1),0,24))
	  d = long(t2-t1)
	  s = strtrim(d,2)
	  m = strtrim(string(d/60.,form='(G13.4)'),2)
	  h = strtrim(string(d/3600.,form='(G13.4)'),2)
	  dy = strtrim(string(d/86400.,form='(G13.6)'),2)
	  print,' Time difference between last two entries:'
	  print,' '+s+' seconds = '+m+' minutes = '+$
	    h+' hours = '+dy+' days.' 
	  if keyword_set(log) then begin
	    openu,lun,file,/append,/get_lun		; Open log file.
	    printf,lun,' Time difference between last two entries:'
	    printf,lun,' '+s+' seconds = '+m+' minutes = '+$
	      h+' hours = '+dy+' days.' 
	    free_lun, lun
	  endif
	endif
 
	;------  TAG/VALUE  ----------
	if n_elements(tag) then begin
	  txt = getfile(file)
	  txt = txt(n_elements(txt)-1)	; Last line.
	  wordarray,txt,ww
	  w=where(strpos(ww,tag) ge 0, cnt)
	  if cnt eq 0 then value='' else value=ww(w(0))
	endif
 
	return
	end
