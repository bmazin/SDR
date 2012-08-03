;-------------------------------------------------------------
;+
; NAME:
;       GETFILE
; PURPOSE:
;       Read a text file into a string array.
; CATEGORY:
; CALLING SEQUENCE:
;       s = getfile(f)
; INPUTS:
;       f = text file name.      in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  error flag: 0=ok, 1=file not opened,
;           2=no lines in file.
;         /QUIET means give no error message.
;         LINES=n  Number of lines to read (def=all).
;           Much faster if number of lines is known.
;           Automatic for IDL 5.6 or later.
; OUTPUTS:
;       s = string array.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 20 Mar, 1990
;       R. Sterner, 1999 Apr 14 --- Added LINES=n keyword.
;       R. Sterner, 2003 Aug 29 --- Automatic lines if IDL 5.6+.
;       R. Sterner, 2003 Sep 02 --- Check if file exists first.
;       R. Sterner, 2003 Sep 04 --- Fixed error in number of lines in file.
;       R. Sterner, 2003 Oct 10 --- Fixed error when no lines.
;       R. Sterner, 2004 Jan 27 --- Fixed to work in IDL as old as vers 4.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function getfile, file, error=err, help=hlp, quiet=quiet, lines=lines
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Read a text file into a string array.'
	  print,' s = getfile(f)'
	  print,'   f = text file name.      in'
	  print,'   s = string array.        out'
	  print,' Keywords:'
	  print,'   ERROR=err  error flag: 0=ok, 1=file not opened,'
	  print,'     2=no lines in file.'
	  print,'   /QUIET means give no error message.'
	  print,'   LINES=n  Number of lines to read (def=all).'
	  print,'     Much faster if number of lines is known.'
	  print,'     Automatic for IDL 5.6 or later.'
	  return, -1
	endif
 
	if (!version.release+0. ge 5.5) then begin
	  f = call_function('file_search',file,count=c)
	endif else begin
	  f = findfile(file,count=c)
	endelse
	if c eq 0 then begin
	  err = 1
	  return,''
	endif
 
	if n_elements(line) eq 0 and (!version.release+0. ge 5.6) then begin
	  lines = file_lines(file)
	  if lines eq 0 then begin
	    if not keyword_set(quiet) then print,' No lines in file.'
	    err = 2
	    return,-1
	  endif
	  minlines = 0
	endif else minlines=1
 
	get_lun, lun
	on_ioerror, err
	openr, lun, file
 
	if n_elements(lines) ne 0 then begin
	  s = strarr(lines)
	  readf,lun,s
	endif else begin
	  s = [' ']
	  t = ''
	  while not eof(lun) do begin
	    readf, lun, t
	    s = [s,t]
	  endwhile
	endelse
 
	close, lun
	free_lun, lun
	if n_elements(s) eq minlines then begin
	  if not keyword_set(quiet) then print,' No lines in file.'
	  err = 2
	  return,-1
	endif
	if minlines eq 1 then s=s(1:*)
 
	err = 0
	return, s
 
err:	if !err eq -168 then begin
	  if not keyword_set(quiet) then print,' Non-standard text file format.'
	  free_lun, lun
	  return, s
	endif
	if not keyword_set(quiet) then print,$
	  ' Error in getfile: File '+file+' not opened.'
	free_lun, lun
	err = 1
	return, -1
 
	end
