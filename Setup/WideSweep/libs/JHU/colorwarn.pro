;-------------------------------------------------------------
;+
; NAME:
;       COLORWARN
; PURPOSE:
;       Warn if available IDL colors too few.
; CATEGORY:
; CALLING SEQUENCE:
;       colorwarn
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         MINIMUM=n  Alert if below this value.
;         /QUIET     Suppress information message.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Feb 23
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro colorwarn, minimum=min, quiet=quiet, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Warn if available IDL colors too few.'
	  print,' colorwarn'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   MINIMUM=n  Alert if below this value.'
	  print,'   /QUIET     Suppress information message.'
	  return
	endif
 
	n = !d.table_size
	if not keyword_set(quiet) then print,$
	  ' '+strtrim(n,2)+' colors available.'
 
	if n_elements(min) ne 0 then begin
	  if n lt min then begin
	    print,' ******************************************************
	    print,' * Warning: number of colors below minimum threshold. *'
	    print,' ******************************************************
	    bell
	  endif
	endif
 
	return
	end
