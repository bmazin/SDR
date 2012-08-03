;-------------------------------------------------------------
;+
; NAME:
;       MOREFILE
; PURPOSE:
;       Display a specified text file using more.
; CATEGORY:
; CALLING SEQUENCE:
;       morefile, file
; INPUTS:
;       file = full name of text file to display.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  error flag: 0=OK, 1=error.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: useful as an optional user procedure in
;         the procedure TXTGETFILE.
; MODIFICATION HISTORY:
;       R. Sterner, 21 Jan, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro morefile, file, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display a specified text file using more.'
	  print,' morefile, file'
	  print,'   file = full name of text file to display.  in'
	  print,' Keywords:'
	  print,'   ERROR=err  error flag: 0=OK, 1=error.'
	  print,' Notes: useful as an optional user procedure in'
	  print,'   the procedure TXTGETFILE.'
	  return
	endif
 
	txt = getfile(file, error=err)
	if err ne 0 then return
	printat,1,1,/clear
	more, txt
	txt = ''
	read,' Press RETURN to continue', txt
	return
	
	end
