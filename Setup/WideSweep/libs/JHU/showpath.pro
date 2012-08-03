;-------------------------------------------------------------
;+
; NAME:
;       SHOWPATH
; PURPOSE:
;       Show the path of the calling routine.
; CATEGORY:
; CALLING SEQUENCE:
;       showpath
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ROUTINE=rt  optional routine name (input).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 May 26
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro showpath, routine=rt, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Show the path of the calling routine.'
	  print,' showpath'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   ROUTINE=rt  optional routine name (input).'
	  return
	endif
 
	whocalledme, dir, file
	name = filename(dir,file,/nosym)
	if n_elements(rt) eq 0 then rt='PATH'
 
	print,strupcase(rt)+': '+name
 
	return
	end
