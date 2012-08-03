;-------------------------------------------------------------
;+
; NAME:
;       TXTMETER
; PURPOSE:
;       Display a 0 to 100% meter on a text screen.
; CATEGORY:
; CALLING SEQUENCE:
;       txtmeter, fr
; INPUTS:
;       fr = fraction, 0 to 1.00 to display as %.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /INITIALIZE must be called to start meter.
;         /CLEAR will erase the specified meter.
;         TITLE=txt set meter title (def=no title). Only on /INIT.
;         Y=y set meter screen line (def = line 15). Only in /INIT.
;         NUMBER=n selects meter number, 0 to 9 (def=0).
;         /ALTERNATE  use alternate symbol (instead of space)
;           to indicate percent.
; OUTPUTS:
; COMMON BLOCKS:
;       txtmeter_com
; NOTES:
;       Notes: A meter will look something like this:
;                    Process status
;         **********|**.......|.........|...   24%
;         0%        20%       40%       60%
;         Except negative spaces will be used in place of *.
; MODIFICATION HISTORY:
;       R. Sterner, 21 Feb, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro txtmeter, fr, initialize=init, title=tt, y=y, $
	  number=num, clear=clear, alternate=alt, help=hlp
 
	common txtmeter_com, last, y0, tt0, off, on, on2
 
	if keyword_set(hlp) then begin
	  print,' Display a 0 to 100% meter on a text screen.'
	  print,' txtmeter, fr'
	  print,'   fr = fraction, 0 to 1.00 to display as %.  in'
	  print,' Keywords:'
	  print,'   /INITIALIZE must be called to start meter.'
	  print,'   /CLEAR will erase the specified meter.'
	  print,'   TITLE=txt set meter title (def=no title). Only on /INIT.'
	  print,'   Y=y set meter screen line (def = line 15). Only in /INIT.'
	  print,'   NUMBER=n selects meter number, 0 to 9 (def=0).'
	  print,'   /ALTERNATE  use alternate symbol (instead of space)'
	  print,'     to indicate percent.'
	  print,' Notes: A meter will look something like this:'
	  print,'              Process status'
	  print,'   **********|**.......|.........|...   24%'
	  print,'   0%        20%       40%       60%'
	  print,'   Except negative spaces will be used in place of *.'
	  return
	end
 
	;--------  start common  --------
	if n_elements(last) eq 0 then begin
	  last = intarr(10)-1		; Last meter positions turned on.
	  y0 = intarr(10)		; Meter y positions.
	  tt0 = strarr(10)		; Meter titles (for /CLEAR).
	  off = bytarr(51)+46B		; Meter off string, dots (.).
	  off(indgen(6)*10) = 124B	;   Verticals (|).
	  on = bytarr(51)+32B		; Meter on string, spaces.
	  on(indgen(6)*10) = 124B	;   Verticals (|).
	  on2 = bytarr(51)+79B		; Meter on string, spaces.
	  on2(indgen(6)*10) = 124B	;   Verticals (|).
	endif
 
	;--------  Make sure needed values exist  ---------
	if n_elements(fr) eq 0 then fr = 0.	; Default fraction is 0.
	if n_elements(num) eq 0 then num = 0	; Default meter number is 0.
 
	;--------  Clear meter  ----------
	if keyword_set(clear) then begin	; Clear a meter.
	  y = y0(num)
	  tt = tt0(num)
	  printat,35-strlen(tt)/2,y,spc(strlen(tt))	; Clear title.
	  printat,10,y+1,spc(61)		; Clear meter.
	  printat,10,y+2,spc(53)		; Clear labels.
	  return
	endif
 
	;--------  Start meter  ----------
	if keyword_set(init) then begin		; Start a new meter.
	  if n_elements(tt) eq 0 then tt = ''	; Default title = no title.
	  if n_elements(y) eq 0 then y = 15	; Default position is line 15.
	  y0(num) = y				; Save y.
	  tt0(num) = tt
	  last(num) = -1			; Start meter all off.
	  ;---------  Display starting meter  -----------
	  lab = '0%       20%       40%       60%       80%       100%'
	  printat,35-strlen(tt)/2,y,tt		; Display title.
	  printat,10,y+1,string(off)		; Display meter all off.
	  printat,10,y+2,lab			; display labels.
	endif
 
	;--------  Update meter  ------------
	pct = (fr>0<1.)*100.			; Compute percent.
	next = fix(.5+pct/2.)			; Next meter endpoint.
	;--------  Meter went up  --------
	if next gt last(num) then begin		; If next > last:
	  sym = on
	  if keyword_set(alt) then sym = on2
	  printat,11+last(num), y0(num)+1, string(sym(last(num)+1:next)), /neg
	endif
	;--------  Meter went down  --------
	if next lt last(num) then begin		; If next < last:
	  printat,11+next, y0(num)+1, string(off(next+1:last(num)))
	endif
	;--------  Update %  ----------
	txt = strtrim(fix(.5+pct),2)+'%'	; New percent string.
	printat,65,y0(num)+1,txt+spc(4,txt)	; Display it.
	last(num) = next			; Remember next as last.
 
	return
	end
