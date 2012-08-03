;-------------------------------------------------------------
;+
; NAME:
;       FINDCMD
; PURPOSE:
;       Find lines in command line recall buffer with given keywords.
; CATEGORY:
; CALLING SEQUENCE:
;       findcmd, [key]
; INPUTS:
;       key = Optional list of keywords.     in
;         Prompts if none given.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: You may set the number of lines in the recall buffer
;       by setting !EDIT_INPUT=n in your IDL startup file.  n is
;       20 by default but may be set to a large value (like 1000).
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Apr 23
;       R. Sterner, 2007 Aug 20 --- Dropped list rverse for last first list.
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro findcmd, key0, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Find lines in command line recall buffer with given keywords.'
	  print,' findcmd, [key]'
	  print,'   key = Optional list of keywords.     in'
	  print,'     Prompts if none given.'
	  print,' Note: You may set the number of lines in the recall buffer'
	  print,' by setting !EDIT_INPUT=n in your IDL startup file.  n is'
	  print,' 20 by default but may be set to a large value (like 1000).'
	  return
	endif
 
	;-----  Make sure keyword list is defined  -----
	if n_elements(key0) eq 0 then begin
	  key0 = ''
	  read,' Enter list of keywords: ',key0
	  if key0 eq '' then return
	endif
 
	;------  Grab recall buffer  ------------
	r = recall_commands()
	w = where(r ne '', cnt)
	if cnt eq 0 then begin
	  print,' No commands found.'
	  return
	endif
;	r = reverse(r(w))
 
	;-------  Search for lines  ----------
	ro = r
	ru = strupcase(ro)		; Ignore case.
	ukey = strupcase(key0)		; Ignore case.
	n = nwrds(ukey)
	for i=0,n-1 do begin
	  strfind, ru, getwrd(ukey,i), /quiet, index=in, count=cnt
	  if cnt eq 0 then break
	  ru = ru[in]
	  ro = ro[in]
	endfor
	if cnt eq 0 then begin
	  print,' No matching lines found.'
	  return
	endif
	more, ro
 
	end
