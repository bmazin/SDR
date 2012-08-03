;-------------------------------------------------------------
;+
; NAME:
;       CREATED
; PURPOSE:
;       Return file creation host, user, and time stamp or tag.
; CATEGORY:
; CALLING SEQUENCE:
;       txt = created()
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         VERB=verb First word to use (def=Created).
;         /BY return text describing the calling routine.
;           Can say BY=n to look back n levels.  Example text:
;           IDL routine: test_res in /d1/lib on system_7.
; OUTPUTS:
;       txt = returned text.        out
;       Ex: Created on tesla by Sterner on Tue Jul  1 14:22:15 1997
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Jul 1
;       R. Sterner, 2004 May 28 --- Added /BY.
;       R. Sterner, 2004 Sep 28 --- Now handles interactive IDL case.
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function created, verb=verb, by=by, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return file creation host, user, and time stamp or tag.'
	  print,' txt = created()'
	  print,'   txt = returned text.        out'
	  print,'   Ex: Created on tesla by Sterner on Tue Jul  1 14:22:15 1997'
	  print,' Keywords:'
	  print,'   VERB=verb First word to use (def=Created).'
	  print,'   /BY return text describing the calling routine.'
	  print,'     Can say BY=n to look back n levels.  Example text:'
	  print,'     IDL routine: test_res in /d1/lib on system_7.'
	  return,''
	endif
 
	host = getenv2('HOST')
 
	if n_elements(by) eq 0 then begin
	  if n_elements(verb) eq 0 then verb='Created'
	  user = upcase1(getenv2('USER'))
	  time = systime()
	  txt = ' '+verb+' on '+host+' by '+user+' on '+time
	endif else begin
	  whocalledme, dir, file, back=by
	  if dir eq '' then begin
	    cd,curr=dir
	    txt = ' Interactively in IDL in '+dir
	  endif else begin
	    txt = ' IDL routine: '+file+' in '+dir+' on '+host
	  endelse
	endelse
 
	return, txt
	end
