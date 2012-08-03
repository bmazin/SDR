;-------------------------------------------------------------
;+
; NAME:
;       TXTIN
; PURPOSE:
;       txtmenu value entry.
; CATEGORY:
; CALLING SEQUENCE:
;       txtin, ptxt, val
; INPUTS:
;       ptxt = prompt text, string scalar or array. in
; KEYWORD PARAMETERS:
;       Keywords:
;         X=x  Column number to use (def=5).
;         Y=y  Starting line (def=22-# lines in ptxt).
;         DEFAULT=def default value (def=null string).
; OUTPUTS:
;       val = returned value (as a string).         out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 19 Feb, 1992
;	R. Sterner, 26 May, 1992 --- fixed to allow default to be same
;	  string as output result.
;	R. Sterner, 18 Jun, 1992 --- fixed a bug caused by last fix.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro txtin, ptxt, val, x=x, y=y, default=def0, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' txtmenu value entry.'
	  print,' txtin, ptxt, val'
	  print,'   ptxt = prompt text, string scalar or array. in'
	  print,'   val = returned value (as a string).         out'
	  print,' Keywords:'
	  print,'   X=x  Column number to use (def=5).'
	  print,'   Y=y  Starting line (def=22-# lines in ptxt).'
	  print,'   DEFAULT=def default value (def=null string).'
	  return
	endif
 
	;--------  set defaults  -----------
	if n_elements(def0) eq 0 then def0 = ''
	def = def0				; Copy default.
	np = n_elements(ptxt)			; # lines of prompt text.
	if n_elements(x) eq 0 then x = 5	; Default x position=5.
	if n_elements(y) eq 0 then y = 22 - np	; Default bottom y=22.
	if n_elements(def) eq 0 then def = ''	; Default default value=null.
 
	;-------  Clear ? at screen bottom  -----------
	printat, 1, 24, spc(10)			; Erase "? for help" at bottom.
 
	;-------  Prompt text  ------------
	for i = 0, np-1 do printat, x, y+i, ptxt(i)	; Display prompt.
	printat, x, y+np, 'Enter:',/neg		; Entry line.
 
	;-------  Read value  -----------
	val = ''				; Entry is to be a string.
	read,' ',val				; Read it.
 
	;-------  Clean up  -------
	for i = 0, np-1 do printat, x, y+i, spc(strlen(ptxt(i)))
	printat, x, y+np, spc(strlen('Enter: '+val))
	printat,1,24,'? for help' & printat,1,1,''
 
	;-------  Set default  ------------
	if val eq '' then val = def		; Use default value.
 
	return
	end
