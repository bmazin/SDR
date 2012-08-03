;-------------------------------------------------------------
;+
; NAME:
;       YDNS2JS
; PURPOSE:
;       Convert year, day of the year, and seconds to Julian Seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       js = ydns2js(Year, dn, sec)
; INPUTS:
;       Year = year (like 1996).                  in
;       dn = day number of the year.              in
;       sec = optional seconds into day (def=0).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       js = returned Julian Seconds.             out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Mar 19
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ydns2js, yr, dn, sec, help=hlp
 
	if (n_params(0) lt 2) or keyWord_set(hlp) then begin
	  print,' Convert year, day of the year, and seconds to Julian Seconds.'
	  print,' js = ydns2js(Year, dn, sec)'
	  print,'   Year = year (like 1996).                  in'
	  print,'   dn = day number of the year.              in'
	  print,'   sec = optional seconds into day (def=0).  in'
	  print,'   js = returned Julian Seconds.             out'
	  return, -1
	endif
 
	ydn2md,yr,dn,m,d
	if m lt 0 then begin
	  print,' Error in month in dn2js.'
	  m = 0
	endif
	if n_elements(sec) eq 0 then sec = 0.
	return, ymds2js(yr,m,d,sec)
 
	end
