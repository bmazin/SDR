;-------------------------------------------------------------
;+
; NAME:
;       GRAB_COMMANDS
; PURPOSE:
;       Grab command line recall commands and save in a text file.
; CATEGORY:
; CALLING SEQUENCE:
;       grab_commands
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         FILE=file  File to save commands in,
;           def=IDL_commands_hhmmss.txt, hhmmss = time tag.
; OUTPUTS:
; COMMON BLOCKS:
;       grab_commands_com
; NOTES:
;       Note a separate file is used for each session of IDL.
;       SETFILE=file  Sets save file and then returns.  Useful
;         to set your own default save file name in your
;         IDL startup file.
;       Note: You may set the number of lines in the recall buffer
;       by setting !EDIT_INPUT=n in your IDL startup file.  n is
;       20 by default but may be set to a large value (like 1000).
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Sep 24
;       R. Sterner, 1998 Sep 30 --- Added time tag to default file.
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro grab_commands, file=file, setfile=setfile, help=hlp
 
	common grab_commands_com, setfile0
 
	if keyword_set(hlp) then begin
	  print,' Grab command line recall commands and save in a text file.'
	  print,' grab_commands'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   FILE=file  File to save commands in,'
	  print,'     def=IDL_commands_hhmmss.txt, hhmmss = time tag.'
	  print,'     Note a separate file is used for each session of IDL.'
	  print,'   SETFILE=file  Sets save file and then returns.  Useful'
	  print,'     to set your own default save file name in your'
	  print,'     IDL startup file.'
	  print,' Note: You may set the number of lines in the recall buffer'
	  print,' by setting !EDIT_INPUT=n in your IDL startup file.  n is'
	  print,' 20 by default but may be set to a large value (like 1000).'
	  return
	endif
 
	;------  Set default save file  ---------------
	if n_elements(setfile) ne 0 then begin
	  setfile0=setfile
	  return
	endif
 
	;------  Force default save file to be defined  -------
	if n_elements(setfile0) eq 0 then setfile0='IDL_commands.txt'
 
	;------  Grab recall buffer  ------------
	r = recall_commands()
	w = where(r ne '', cnt)
	if cnt eq 0 then begin
	  print,' No commands to save.'
	  return
	endif
	r = reverse(r(w))
 
	;------  Save lines in file  ----------------
	if n_elements(file) eq 0 then file=setfile0
	if file eq 'IDL_commands.txt' then begin
	  tag = dt_tm_fromjs(dt_tm_tojs(systime()),form='h$m$s$')
	  file = 'IDL_commands_'+tag+'.txt'
	  setfile0 = file
	  print,' This session of IDL will save commands in '+file
	endif
	putfile, file, r
	n = n_elements(r)
	print,' '+strtrim(n,2)+' command lines saved in '+file
	print,' '
 
	end
