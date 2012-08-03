;-------------------------------------------------------------
;+
; NAME:
;       DATE2DOY
; PURPOSE:
;       Date to Day of Year conversion.
; CATEGORY:
; CALLING SEQUENCE:
;       date2doy
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         FIRST=date1  Starting date for list of dates.
;         LAST=date2   Ending date for list of dates.
;           Date must be entered using month name, 3 letters
;           or more.  Year, month, and day may be any order
;           but must be separated by spaces, commas, tabs,slashes,
;           or dashes (like 1998-Nov-25, NOT 1998nov25).
;         FILE=file  Optional output file (else screen).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Nov 25
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro date2doy, first=dt1, last=dt2, file=file, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Date to Day of Year conversion.'
	  print,' date2doy'
	  print,'   All args are keywords.  Prompts if needed.'
	  print,' Keywords:'
	  print,'   FIRST=date1  Starting date for list of dates.'
	  print,'   LAST=date2   Ending date for list of dates.'
	  print,'     Date must be entered using month name, 3 letters'
	  print,'     or more.  Year, month, and day may be any order'
	  print,'     but must be separated by spaces, commas, tabs,slashes,'
	  print,'     or dashes (like 1998-Nov-25, NOT 1998nov25).'
	  print,'   FILE=file  Optional output file (else screen).'
	  return
	endif
 
	;----------  Make sure inputs are available  ---------------
	if n_elements(dt1) eq 0 then begin
	  print,' '
	  print,' Date to Day of Year conversion'
	  print,' '
	  print,' Enter the first and last date of a range.'
	  print,' Date have flexible format, one example: 1998 nov 25'
	  dt1 = ''
	  read,' First date: ',dt1
	  if dt1 eq '' then return
	  dt2 = ''
	  read,' Last date: ',dt2
	  if dt2 eq '' then return
	  file = ''
	  read,' Output file (def=screen): ',file
	endif
 
	;--------  Open file  ------------------------
	if n_elements(file) eq 0 then file=''
	if file eq '' then begin
	  lun = -1
	endif else begin
	  openw,lun,file,/get_lun
	  print,' Generating date to day of year file . . .'
	endelse
 
	;--------  Make date list  -------------------
	js1 = dt_tm_tojs(dt1)
	js2 = dt_tm_tojs(dt2)
 
	;--------  Header  ---------------
	printf,lun,' DOY      Date'
	printf,lun,' ---   -----------'
 
	;--------  Output list  --------------------
	for js=js1, js2, 86400D0 do begin
	  printf,lun,dt_tm_fromjs(js,form=' doy$ = Y$ n$ d$')
	endfor
 
	;---------  Close  ---------------------------
	if lun ne -1 then begin
	  free_lun, lun
	  print,' Day of year to date conversion in file '+file
	endif
 
	end
