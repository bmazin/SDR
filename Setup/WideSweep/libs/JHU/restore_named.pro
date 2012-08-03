;-------------------------------------------------------------
;+
; NAME:
;       RESTORE_NAMED
; PURPOSE:
;       Restore variables under given names (saved with save_named).
; CATEGORY:
; CALLING SEQUENCE:
;       restore_named, file, v1,v2,...,v9
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       v1,v2,...,v9 = Up to 9 IDL variables to restore.   out
;       ERR=err Error flag: 0=ok, else error.
; COMMON BLOCKS:
; NOTES:
;       Notes: The normal IDL restore procedure will restore the
;         saved variables under the original names.  This routine
;         will restore the saved variables under the given names
;         v1, v2, ...
;         If called with more variable names than are in the
;         save_named file the extra variables will be undefined.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Mar 30
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro restore_named, file, t1,t2,t3,t4,t5,t6,t7,t8,t9, $
	  error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then  begin
	  print,' Restore variables under given names (saved with save_named).'
	  print,' restore_named, file, v1,v2,...,v9'
	  print,'   file = name of save_named save file.'
	  print,'   v1,v2,...,v9 = Up to 9 IDL variables to restore.   out'
	  print,'   ERR=err Error flag: 0=ok, else error.'
	  print,' Notes: The normal IDL restore procedure will restore the'
	  print,'   saved variables under the original names.  This routine'
	  print,'   will restore the saved variables under the given names'
	  print,'   v1, v2, ...'
	  print,'   If called with more variable names than are in the'
	  print,'   save_named file the extra variables will be undefined.'
	  return
	endif
 
	;-----  Check if save file exists  --------
	f = file_search(file, count=c)
	if c eq 0 then begin
	  print,' Error in restore_named: specified save file not found: '+file
	  err = 1
	  return
	endif
 
	;-----  Set up error handler  ----
	catch, err_status
	if err_status ne 0 then begin
	  print,' Error in restore_named: could not restore specified '+$
	    'save file: '+file
	  err = 1
	  return
	endif
 
	;-----  restore variables  -------
	restore, file
	err = 0
 
	end
