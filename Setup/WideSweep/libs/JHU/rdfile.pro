;-------------------------------------------------------------
;+
; NAME:
;       RDFILE
; PURPOSE:
;       Read lines from a text file.
; CATEGORY:
; CALLING SEQUENCE:
;       rdfile, file, rec1, rec2, out
; INPUTS:
;       file = name of text file.                  in
;       rec1, rec2 = file records to read.         in
;         First record is number 1.
;         To read to end of file set rec2 to a large value.
; KEYWORD PARAMETERS:
;       Keywords:
;         ERR = e.  Error flag.  0=ok, 1=file not opened.
; OUTPUTS:
;       out = string array of selected records.    out
;         Out is always an array, even for one line.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 Jan, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro rdfile, file, rec1, rec2, s, help=hlp, err=ee
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Read lines from a text file.'
	  print,' rdfile, file, rec1, rec2, out'
	  print,'   file = name of text file.                  in'
	  print,'   rec1, rec2 = file records to read.         in'
	  print,'     First record is number 1.'
	  print,'     To read to end of file set rec2 to a large value.'
	  print,'   out = string array of selected records.    out'
	  print,'     Out is always an array, even for one line.'
	  print,' Keywords:'
	  print,'   ERR = e.  Error flag.  0=ok, 1=file not opened.'
	  return
	endif
 
	get_lun, lun		; Get a unit number.
	on_ioerror, ioerr
	openr, lun, file	; Open file.
	n = rec2 - rec1 + 1
	lst = n - 1
	s = strarr(n)	; Set up string array to read.
	t = ''
	for i = 1, rec1-1 do readf, lun, t	; Read & skip unwanted records.
	i = 0					; Counter.
	while not eof(lun) do begin		; Loop through file records.
	  readf, lun, t				; Read a record.
	  s(i) = t				; Store it.
	  if i eq lst then goto, jmp
	  i = i + 1				; Count it.
	endwhile
	i = i-1
jmp:	s = s(0:i)		; Trim off un-used space.
	close, lun		; Close file.
	free_lun, lun		; Free unit number.
	ee = 0
	return
 
ioerr:	print,' Error in rdfile: could not open the file '+file
	ee = 1
	free_lun, lun
	return
 
	end
