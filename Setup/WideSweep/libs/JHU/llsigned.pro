;-------------------------------------------------------------
;+
; NAME:
;       LLSIGNED
; PURPOSE:
;       Returns signed value of lat or long given text.
; CATEGORY:
; CALLING SEQUENCE:
;       v = llsigned(txt)
; INPUTS:
;       txt = text string with lat or long. in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       v = returned signed value.          out
; COMMON BLOCKS:
; NOTES:
;       Note: lat or long may have N, S, E, or W
;         in the string, case ignored.  If no such letter
;         then the string is assumed to be signed already.
;         Some example inputs:
;         '-33 27 15.2','33 27 15.2 S','S33 27 15.2','S 33 27 15.2'
;         '-33.454222','33.454222 S','33.454222S','33S 27 15.2'
;         all give the same result.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Sep 08
;       R. Sterner, 2006 Aug 29 --- More help.  Upgraded for D M S form.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function llsigned, txt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Returns signed value of lat or long given text.'
	  print,' v = llsigned(txt)'
	  print,'   txt = text string with lat or long. in'
	  print,'   v = returned signed value.          out'
	  print,' Note: lat or long may have N, S, E, or W'
	  print,'   in the string, case ignored.  If no such letter'
	  print,'   then the string is assumed to be signed already.'
	  print,'   Some example inputs:'
	  print,"   '-33 27 15.2','33 27 15.2 S','S33 27 15.2','S 33 27 15.2'"
	  print,"   '-33.454222','33.454222 S','33.454222S','33S 27 15.2'"
	  print,'   all give the same result.'
	  return,''
	endif
 
	sn = 1.
	t = strupcase(txt)
 
	p = strpos(t,'S')	; Look for the letter S.
	if p ge 0 then begin	; Is it there?
	  sn = -1.		; Use, set sign.
	  strput,t,' ',p	; Remove it.
	endif
 
	p = strpos(t,'N')
	if p ge 0 then begin
	  sn = 1.
	  strput,t,' ',p
	endif
 
	p = strpos(t,'W')
	if p ge 0 then begin
	  sn = -1.
	  strput,t,' ',p
	endif
 
	p = strpos(t,'E')
	if p ge 0 then begin
	  sn = 1.
	  strput,t,' ',p
	endif
 
	return, sn*dms2d(t)
 
	end
 
