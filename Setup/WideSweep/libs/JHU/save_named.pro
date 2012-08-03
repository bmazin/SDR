;-------------------------------------------------------------
;+
; NAME:
;       SAVE_NAMED
; PURPOSE:
;       Save variables so they can be restored with any name.
; CATEGORY:
; CALLING SEQUENCE:
;       save_named,v1,v2,...,v9
; INPUTS:
;       v1,v2,...,v9 = Up to 9 IDL variables to save.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         FILENAME=file Name of save file (def=idlsave.sav).
;         ERR=err Error flag: 0=ok, else error.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: The normal IDL restore procedure will restore the
;         saved variables under the original names.  It is useful to
;         be able to set the name of the restored variable in the
;         users code.  save_named and restore_named allow this.
;         Use restore_named, file, u1,u2,... to restore the
;         saved variables under the names given for u1,u2,...
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
	pro save_named, filename=file, t1,t2,t3,t4,t5,t6,t7,t8,t9, $
	  error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then  begin
	  print,' Save variables so they can be restored with any name.'
	  print,' save_named,v1,v2,...,v9'
	  print,'   v1,v2,...,v9 = Up to 9 IDL variables to save.   in'
	  print,' Keywords:'
	  print,'   FILENAME=file Name of save file (def=idlsave.sav).'
	  print,'   ERR=err Error flag: 0=ok, else error.'
	  print,' Notes: The normal IDL restore procedure will restore the'
	  print,'   saved variables under the original names.  It is useful to'
	  print,'   be able to set the name of the restored variable in the'
	  print,'   users code.  save_named and restore_named allow this.'
	  print,'   Use restore_named, file, u1,u2,... to restore the'
	  print,'   saved variables under the names given for u1,u2,...'
	  return
	endif
 
	;------  Make sure number of variables ok  --------
	n = n_params(0)
	if n gt 9 then begin
	  print,' Error in save_named: may save no more than 9 variables'
	  print,'   in a call.'
	  err = 1
	  return
	endif
 
	;------  Make sure all given variables are defined  -----
	for i=1, n do begin
	  tmp = execute('nn = n_elements(t'+strtrim(i,2)+')')
	  if nn eq 0 then begin
	    print,' Variable number '+strtrim(i,2)+' is undefined.'
	    print,' save_named aborted.'
	    err = 1
	    return
	  endif
	endfor
 
	;------  Save file name  ------------
	if n_elements(file) eq 0 then file='idlsave.sav'
 
	;------  Save correct number of variables  ------
	case n of
1:	save,filename=file,t1
2:	save,filename=file,t1,t2
3:	save,filename=file,t1,t2,t3
4:	save,filename=file,t1,t2,t3,t4
5:	save,filename=file,t1,t2,t3,t4,t5
6:	save,filename=file,t1,t2,t3,t4,t5,t6
7:	save,filename=file,t1,t2,t3,t4,t5,t6,t7
8:	save,filename=file,t1,t2,t3,t4,t5,t6,t7,t8
9:	save,filename=file,t1,t2,t3,t4,t5,t6,t7,t8,t9
	endcase
 
	err = 0
 
	end
