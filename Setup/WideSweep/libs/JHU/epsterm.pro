;-------------------------------------------------------------
;+
; NAME:
;       EPSTERM
; PURPOSE:
;       Terminate Encapsulated Postscript plotting.
; CATEGORY:
; CALLING SEQUENCE:
;       epsterm
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /QUIET turns off epsterm messages.
; OUTPUTS:
; COMMON BLOCKS:
;       eps_com,xsv,ysv,psv,dsv
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Aug 2
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro epsterm, q, help=hlp
 
	common eps_com,xsv,ysv,psv,dsv, out
 
	if keyword_set(hlp) then begin
	  print,' Terminate Encapsulated Postscript plotting.'
	  print,' epsterm'
	  print,'   No arguments.
	  print,' Keywords:
	  print,'   /QUIET turns off epsterm messages.'
	  return
	endif
 
	qflg = not keyword_set(qt)
 
	if !d.name ne 'PS' then begin
	  if qflg then print,' Not in postscript mode.'
	  return
	endif
 
	device, /close
 
	if qflg then print,' Encapsulated PostScript file '+out+' terminated.'
 
	;-----  Restore pre-EPS state  ------------
	set_plot, dsv.name
	!x = xsv
	!y = ysv
	!p = psv
 
	return
	end
