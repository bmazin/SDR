;-------------------------------------------------------------
;+
; NAME:
;       DETAB_FILE
; PURPOSE:
;       Convert any tabs in a file to spaces.
; CATEGORY:
; CALLING SEQUENCE:
;       detab_file, file
; INPUTS:
;       file=f name file to process.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /SHOW Just list file showing tabs.  No processing done.
;         CHAR=ch  Character to show for tabs (def='#').
;         /DTSHOW List file as if it were detabbed.  Not changed.
;         ERROR=err Error flag: 0=ok.
;         TAB=tab  Spaces per tab (def=8).
;         /NOBACKUP do not make a backup copy of file (file.bak).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Aug 2003
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro detab_file, file, error=err, tab=tab, nobackup=noback, $
	  show=show, char=char, dtshow=dtshow, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert any tabs in a file to spaces.'
	  print,' detab_file, file'
	  print,'   file=f name file to process.  in'
	  print,' Keywords:'
	  print,'   /SHOW Just list file showing tabs.  No processing done.'
	  print,"   CHAR=ch  Character to show for tabs (def='#')."
	  print,'   /DTSHOW List file as if it were detabbed.  Not changed.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,'   TAB=tab  Spaces per tab (def=8).'
	  print,'   /NOBACKUP do not make a backup copy of file (file.bak).'
	  return
	endif
 
	;----  Read file  ---------
	t = getfile(file,err=err)
	if err ne 0 then return
 
	;----  List file  ----------
	if keyword_set(show) then begin
	  if n_elements(char) eq 0 then char='#'
	  showtabs, t, char=char
	  return
	endif
 
	;----  List file as if detabbed ----------
	if keyword_set(dtshow) then begin
	  more, detab(t,tab=tab)
	  return
	endif
 
	;----  Back up  -----------
	if not keyword_set(noback) then begin
	  bfile = file+'.bak'
	  putfile,bfile,t
	endif
 
	;----  Save detabbed file  ----
	putfile, file, detab(t,tab=tab) 
 
	end
