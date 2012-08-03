;-------------------------------------------------------------
;+
; NAME:
;       HLP
; PURPOSE:
;       Variant of HELP.  Gives array min, max.
; CATEGORY:
; CALLING SEQUENCE:
;       hlp, a1, [a2, ..., a9]
; INPUTS:
;       a1, [...] = input variables.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /STRUCTURE expand structures (for IDL6.1 or later).
;         OUT=txt Returned list as text array (for IDL6.1 or later).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Minimal for pre IDL6.1, but IDL6.1 or later this
;       routine will list expanded structures, including nested
;       structures, giving min and max for any arrays.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Apr 29
;       R. Sterner, 2005 May 16 --- Added OUT=txt and /QUIET keywords.
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro hlp, a1, a2, a3, a4, a5, a6, a7, a8, a9, $
	  out=out, quiet=quiet, structure=struct, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Variant of HELP.  Gives array min, max.'
	  print,' hlp, a1, [a2, ..., a9]'
	  print,'   a1, [...] = input variables.    in'
	  print,' Keywords:'
	  print,'   /STRUCTURE expand structures (for IDL6.1 or later).'
	  print,'   OUT=txt Returned list as text array (for IDL6.1 or later).'
	  print,' Note: Minimal for pre IDL6.1, but IDL6.1 or later this'
	  print,' routine will list expanded structures, including nested'
	  print,' structures, giving min and max for any arrays.'
	  return
	endif
 
	np = n_params(0)			    ; How many args?
 
	if float(!version.release) ge 6.1 then begin
	  hlp2, a1, a2, a3, a4, a5, a6, a7, a8, a9, $
	    out=out, quiet=quiet, struct=struct, np=np
	endif else begin
	  hlp1, a1, a2, a3, a4, a5, a6, a7, a8, a9, np=np
	endelse
 
	end
